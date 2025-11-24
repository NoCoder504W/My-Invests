part of '../api_service.dart';

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
  // NOUVEAU : Prix actuel de l'actif
  final double? price;

  TickerSuggestion({
    required this.ticker,
    required this.name,
    required this.exchange,
    required this.currency,
    this.isin,
    this.price,
  });
}

// Objets de résultat pour un meilleur feedback
enum ApiSource { Fmp, Yahoo, Google, Cache, None }

class PriceResult {
  final double? price;
  final String currency; // Ex: "USD", "EUR"
  final ApiSource source;
  final String ticker;
  final Map<String, String>? errorDetails; // Source -> Error Message

  PriceResult({
    required this.price,
    required this.currency,
    required this.source,
    required this.ticker,
    this.errorDetails,
  });

  // Constructeur d'échec
  PriceResult.failure(this.ticker, {String? currency, this.errorDetails})
      : price = null,
        currency = currency ??
            'EUR', // Utilise la devise fournie, sinon EUR par défaut
        source = ApiSource.None;
}
