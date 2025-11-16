// lib/core/data/services/api_service.dart
// REMPLACEZ LE FICHIER COMPLET

import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:portefeuille/features/00_app/providers/settings_provider.dart';
import 'dart:convert';

/// Cache pour les prix (15 minutes)
class _CacheEntry {
  // MODIFIÉ : Le cache stocke le PriceResult complet
  final PriceResult value;
  final DateTime timestamp;

  _CacheEntry(this.value) : timestamp = DateTime.now();

  bool get isStale =>
      DateTime.now().difference(timestamp) > const Duration(minutes: 15);
}

/// Modèle pour les suggestions de recherche
class TickerSuggestion {
  final String ticker;
  final String name;
  final String exchange;
  // NOUVEAU : Ajouter la devise à la suggestion de recherche
  final String currency;
  // NOUVEAU : Code ISIN de l'actif (si disponible)
  final String? isin;

  TickerSuggestion({
    required this.ticker,
    required this.name,
    required this.exchange,
    required this.currency,
    this.isin,
  });
}

// Objets de résultat pour un meilleur feedback
enum ApiSource { Fmp, Yahoo, Cache, None }

class PriceResult {
  final double? price;
  final String currency; // Ex: "USD", "EUR"
  final ApiSource source;
  final String ticker;

  PriceResult({
    required this.price,
    required this.currency,
    required this.source,
    required this.ticker,
  });

  // Constructeur d'échec
  PriceResult.failure(this.ticker, {String? currency})
      : price = null,
        currency = currency ??
            'EUR', // Utilise la devise fournie, sinon EUR par défaut
        source = ApiSource.None;
}

/// Service responsable des appels réseau pour les données financières.
/// Gère la logique de cache et la stratégie FMP > Yahoo.
class ApiService {
  final SettingsProvider _settingsProvider;
  // MODIFIÉ : Le cache stocke <String, _CacheEntry>
  final Map<String, _CacheEntry> _priceCache = {};
  final http.Client _httpClient;

  // Cache pour la recherche (24h)
  final Map<String, List<TickerSuggestion>> _searchCache = {};
  final Map<String, DateTime> _searchCacheTimestamps = {};

  // Cache pour les taux de change (24h)
  final Map<String, double> _exchangeRateCache = {};
  final Map<String, DateTime> _exchangeRateCacheTimestamps = {};

  ApiService({
    required SettingsProvider settingsProvider,
    http.Client? httpClient,
  })  : _settingsProvider = settingsProvider,
        _httpClient = httpClient ?? http.Client();

  /// Récupère le prix pour un ticker.
  Future<PriceResult> getPrice(String ticker) async {
    try {
      // 1. Vérifier le cache
      final cached = _priceCache[ticker];
      if (cached != null && !cached.isStale) {
        return cached.value; // Retourne le PriceResult mis en cache
      }

      // 2. Si le cache est vide ou obsolète, appeler le réseau
      PriceResult? result;
      final bool hasFmpKey = _settingsProvider.hasFmpApiKey;

      if (hasFmpKey) {
        result = await _fetchFromFmp(ticker);
        if (result != null) {
          _priceCache[ticker] = _CacheEntry(result);
          return result;
        }
      }

      // 3. Stratégie 2 : Yahoo (Fallback ou si FMP n'a pas de clé)
      result = await _fetchFromYahoo(ticker);

      // 4. Mettre à jour le cache et retourner
      if (result != null) {
        _priceCache[ticker] = _CacheEntry(result);
        return result;
      }

      // 5. Échec complet
      return PriceResult.failure(ticker,
          currency: _settingsProvider.baseCurrency);
    } catch (e) {
      debugPrint(
          "⚠️ Erreur inattendue lors de la récupération du prix pour $ticker : $e");
      return PriceResult.failure(ticker,
          currency: _settingsProvider.baseCurrency);
    }
  }

  /// Tente de récupérer un prix via FMP (Financial Modeling Prep)
  Future<PriceResult?> _fetchFromFmp(String ticker) async {
    if (!_settingsProvider.hasFmpApiKey) return null;
    final apiKey = _settingsProvider.fmpApiKey!;

    final uri = Uri.parse(
        'https://financialmodelingprep.com/api/v3/quote/$ticker?apikey=$apiKey');

    try {
      final response =
          await _httpClient.get(uri).timeout(const Duration(seconds: 5));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data is List && data.isNotEmpty) {
          final price = data[0]['price'];
          // FMP ne semble pas fournir la devise dans cet endpoint,
          // nous allons donc devoir la déduire ou la supposer.
          // Pour l'instant, supposons "USD" pour les tickers non-européens
          // et "EUR" pour ceux finissant par .PA, .F, .DE, etc.
          // C'est une simplification, Yahoo est meilleur pour ça.
          // NOTE : FMP fournit parfois la devise dans sa réponse.
          // Si elle est absente, on utilise la devise de base configurée par l'utilisateur.
          final currency =
              data[0]['currency'] ?? _settingsProvider.baseCurrency;

          if (price is num) {
            return PriceResult(
              price: price.toDouble(),
              currency: currency,
              source: ApiSource.Fmp,
              ticker: ticker,
            );
          }
        }
      }
      debugPrint(
          "Erreur FMP pour $ticker (Status: ${response.statusCode}): ${response.body}");
      return null;
    } catch (e) {
      debugPrint("Erreur FMP pour $ticker: $e");
      return null;
    }
  }

  /// Tente de récupérer un prix via Yahoo Finance (API 'spark')
  Future<PriceResult?> _fetchFromYahoo(String ticker) async {
    final yahooUrl = Uri.parse(
        'https://query1.finance.yahoo.com/v7/finance/spark?symbols=$ticker&range=1d&interval=1d');
    try {
      final response = await _httpClient.get(yahooUrl, headers: {
        'User-Agent': 'Mozilla/5.0'
      }).timeout(const Duration(seconds: 8));

      if (response.statusCode != 200) {
        debugPrint(
            'Erreur de l\'API Yahoo Finance (spark) pour $ticker: ${response.body}');
        return null;
      }

      final jsonData = jsonDecode(response.body);
      final List<dynamic>? results = jsonData['spark']?['result'];

      if (results != null && results.isNotEmpty) {
        final result = results[0];
        final String? resultSymbol = result['symbol'];
        final num? newPriceNum =
            result['response']?[0]?['meta']?['regularMarketPrice'];
        // NOUVEAU : Récupérer la devise
        final String currency =
            result['response']?[0]?['meta']?['currency'] ?? 'EUR';

        if (resultSymbol == ticker && newPriceNum != null) {
          return PriceResult(
            price: newPriceNum.toDouble(),
            currency: currency,
            source: ApiSource.Yahoo,
            ticker: ticker,
          );
        }
      }
      debugPrint("Yahoo (spark) n'a pas retourné de prix pour $ticker");
      return null;
    } catch (e) {
      debugPrint("Erreur http Yahoo (spark) pour $ticker: $e");
      return null;
    }
  }

  /// Récupère le taux de change réel depuis l'API Frankfurter (BCE)
  ///
  /// Frankfurter fournit des taux de change officiels de la Banque Centrale Européenne
  /// 100% gratuit, pas de clé API requise, données fiables
  ///
  /// Exemple : _fetchExchangeRateFromFrankfurter('USD', 'EUR') → 0.92
  Future<double?> _fetchExchangeRateFromFrankfurter(
      String from, String to) async {
    final url =
        Uri.parse('https://api.frankfurter.app/latest?from=$from&to=$to');

    try {
      debugPrint("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");
      debugPrint("💱 FRANKFURTER: Récupération taux $from → $to");
      debugPrint("🌐 URL: $url");
      debugPrint("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");

      final response =
          await _httpClient.get(url).timeout(const Duration(seconds: 5));

      debugPrint("📡 Réponse HTTP: ${response.statusCode}");

      if (response.statusCode != 200) {
        debugPrint("❌ Erreur Frankfurter (${response.statusCode})");
        debugPrint("📄 Body: ${response.body}");
        return null;
      }

      final jsonData = jsonDecode(response.body);
      debugPrint("📦 JSON reçu: $jsonData");

      final rates = jsonData['rates'];

      if (rates != null && rates[to] != null) {
        final rate = (rates[to] as num).toDouble();
        debugPrint("✅ SUCCÈS: 1 $from = $rate $to (source: BCE)");
        debugPrint("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");
        return rate;
      }

      debugPrint("⚠️ Frankfurter n'a pas retourné de taux pour $from→$to");
      debugPrint("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");
      return null;
    } on SocketException catch (e) {
      debugPrint("❌ ERREUR RÉSEAU Frankfurter pour $from→$to");
      debugPrint("📋 Détails: $e");
      debugPrint("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");
      return null;
    } on TimeoutException catch (e) {
      debugPrint("⏱️ TIMEOUT Frankfurter pour $from→$to (>5s)");
      debugPrint("📋 Détails: $e");
      debugPrint("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");
      return null;
    } catch (e) {
      debugPrint("❌ ERREUR INCONNUE Frankfurter pour $from→$to");
      debugPrint("📋 Détails: $e");
      debugPrint("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");
      return null;
    }
  }

  /// Récupère le taux de change entre deux devises.
  /// Utilise l'API Frankfurter (données BCE) avec mise en cache de 24h
  Future<double> getExchangeRate(String from, String to) async {
    debugPrint("\n🔄 getExchangeRate appelé: $from → $to");

    // Si les devises sont identiques, le taux est 1
    if (from == to) {
      debugPrint("✅ Devises identiques ($from = $to), taux = 1.0");
      return 1.0;
    }

    // Vérifier le cache (24h)
    final cacheKey = '$from->$to';
    final cachedTimestamp = _exchangeRateCacheTimestamps[cacheKey];
    if (cachedTimestamp != null &&
        DateTime.now().difference(cachedTimestamp) <
            const Duration(hours: 24)) {
      final cachedRate = _exchangeRateCache[cacheKey];
      if (cachedRate != null) {
        final age = DateTime.now().difference(cachedTimestamp);
        debugPrint(
            "💾 CACHE HIT: Taux $from→$to = $cachedRate (âge: ${age.inMinutes}min)");
        return cachedRate;
      }
    }

    debugPrint("🌐 CACHE MISS: Appel API Frankfurter...");

    // Appeler Frankfurter
    final rate = await _fetchExchangeRateFromFrankfurter(from, to);

    if (rate != null) {
      // Mettre en cache
      _exchangeRateCache[cacheKey] = rate;
      _exchangeRateCacheTimestamps[cacheKey] = DateTime.now();
      debugPrint("💾 Taux $from→$to mis en cache: $rate (valide 24h)");
      return rate;
    }

    // Fallback : retourner 1.0 si échec (évite les crashs)
    debugPrint("⚠️ FALLBACK: Taux $from→$to = 1.0 (Frankfurter indisponible)");
    debugPrint("💡 Les conversions ne seront pas exactes!");
    return 1.0;
  }

  /// Recherche un ticker ou un ISIN
  Future<List<TickerSuggestion>> searchTicker(String query) async {
    final timestamp = _searchCacheTimestamps[query];
    if (timestamp != null &&
        DateTime.now().difference(timestamp) < const Duration(hours: 24)) {
      return _searchCache[query] ?? [];
    }

    final url = Uri.parse(
        'https://query1.finance.yahoo.com/v1/finance/search?q=$query&lang=fr-FR&region=FR');
    try {
      debugPrint("🔍 Recherche de ticker: '$query' - URL: $url");
      final response = await _httpClient.get(url, headers: {
        'User-Agent': 'Mozilla/5.0'
      }).timeout(const Duration(seconds: 5));
      debugPrint("✅ Réponse reçue - Status: ${response.statusCode}");

      if (response.statusCode != 200) {
        debugPrint("❌ Erreur HTTP ${response.statusCode}: ${response.body}");
        throw Exception(
            "Erreur de l'API de recherche Yahoo: ${response.statusCode}");
      }

      final jsonData = jsonDecode(response.body);
      final List<dynamic> quotes = jsonData['quotes'] ?? [];
      final List<TickerSuggestion> suggestions = [];

      debugPrint("📊 ${quotes.length} résultats trouvés");

      // OPTION C : Récupérer la devise réelle pour chaque résultat via getPrice()
      for (final quote in quotes) {
        final String? ticker = quote['symbol'];
        final String? name = quote['longname'] ?? quote['shortname'];
        final String? exchange = quote['exchDisp'];

        // NOUVEAU : Récupérer l'ISIN si disponible dans la réponse API
        // NOTE IMPORTANTE : L'API Yahoo Finance Search ne fournit PAS l'ISIN dans sa réponse.
        // Ce champ restera null jusqu'à ce qu'une autre source (FMP, API dédiée) soit utilisée.
        // La structure est néanmoins prête pour une future implémentation.
        final String? isin = quote['isin'];

        if (ticker != null && name != null && exchange != null) {
          if (quote['quoteType'] == 'EQUITY' ||
              quote['quoteType'] == 'ETF' ||
              quote['quoteType'] == 'CRYPTOCURRENCY') {
            // OPTION C : Appel getPrice() pour obtenir la vraie devise
            String currency = '???';
            try {
              final priceResult = await getPrice(ticker);
              if (priceResult.price != null) {
                currency = priceResult.currency;
                debugPrint("💱 Devise récupérée pour $ticker: $currency");
              }
            } catch (e) {
              debugPrint(
                  "⚠️ Impossible de récupérer la devise pour $ticker: $e");
            }

            suggestions.add(TickerSuggestion(
              ticker: ticker,
              name: name,
              exchange: exchange,
              currency: currency,
              isin: isin,
            ));
          }
        }
      }

      debugPrint("✅ ${suggestions.length} suggestions valides avec devises");
      _searchCache[query] = suggestions;
      _searchCacheTimestamps[query] = DateTime.now();

      return suggestions;
    } on SocketException catch (e) {
      debugPrint("❌ Erreur réseau (SocketException) pour '$query': $e");
      debugPrint("💡 Vérifiez la permission INTERNET et la connexion réseau");
      return [];
    } on TimeoutException catch (e) {
      debugPrint("❌ Timeout lors de la recherche de '$query': $e");
      return [];
    } catch (e) {
      debugPrint("❌ Erreur lors de la recherche de ticker pour '$query': $e");
      return [];
    }
  }

  /// Vide les caches de prix, recherche et taux de change.
  void clearCache() {
    _priceCache.clear();
    _searchCache.clear();
    _searchCacheTimestamps.clear();
    _exchangeRateCache.clear();
    _exchangeRateCacheTimestamps.clear();
    debugPrint("ℹ️ Caches de l'ApiService vidés (prix, recherche, taux).");
  }
}
