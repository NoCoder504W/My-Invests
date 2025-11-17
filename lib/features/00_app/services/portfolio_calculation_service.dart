// lib/features/00_app/services/portfolio_calculation_service.dart
// NOUVEAU FICHIER

import 'package:portefeuille/core/data/models/aggregated_asset.dart';
import 'package:portefeuille/core/data/models/aggregated_portfolio_data.dart';
import 'package:portefeuille/core/data/models/asset.dart';
import 'package:portefeuille/core/data/models/asset_metadata.dart';
import 'package:portefeuille/core/data/models/asset_type.dart';
import 'package:portefeuille/core/data/models/portfolio.dart';
import 'package:portefeuille/core/data/services/api_service.dart';
import 'package:portefeuille/features/00_app/providers/settings_provider.dart';

/// Ce service encapsule toute la logique complexe de calcul
/// pour agréger les données d'un portefeuille dans une devise de base.
class PortfolioCalculationService {
  final ApiService _apiService;

  PortfolioCalculationService({required ApiService apiService})
      : _apiService = apiService;

  /// Recalcule TOUTES les valeurs converties (globales, par compte, par actif, et agrégats)
  /// C'est l'ancienne méthode `_recalculateConvertedTotals` du PortfolioProvider.
  Future<AggregatedPortfolioData> calculate({
    required Portfolio? activePortfolio,
    required SettingsProvider? settingsProvider,
    required Map<String, AssetMetadata> allMetadata,
  }) async {
    final targetCurrency = settingsProvider?.baseCurrency ?? 'EUR';

    if (activePortfolio == null || settingsProvider == null) {
      return AggregatedPortfolioData.empty; // Pas de calcul
    }

    // 1. Collecter toutes les devises de compte uniques
    final Set<String> accountCurrencies = activePortfolio.institutions
        .expand((inst) => inst.accounts)
        .map((acc) => acc.activeCurrency)
        .toSet();

    // 2. Récupérer tous les taux de change nécessaires en parallèle
    final Map<String, double> rates = {}; // Map: "EUR" -> 1.0, "USD" -> 0.92
    final futures = accountCurrencies.map((accountCurrency) async {
      if (accountCurrency == targetCurrency) {
        rates[accountCurrency] = 1.0;
        return;
      }
      rates[accountCurrency] =
      await _apiService.getExchangeRate(accountCurrency, targetCurrency);
    });
    await Future.wait(futures);

    // 3. Itérer, calculer et stocker les valeurs converties
    double totalValue = 0.0;
    double totalPL = 0.0;
    double totalInvested = 0.0;
    Map<String, double> accountValues = {};
    Map<String, double> accountPLs = {};
    Map<String, double> accountInvested = {};
    Map<String, double> assetValues = {};
    Map<String, double> assetPLs = {};

    // Map pour l'agrégation par type
    final Map<AssetType, double> aggregatedValueByType = {};
    // Map pour l'agrégation par ticker
    final Map<String, List<Asset>> assetsByTicker = {};
    final Map<String, List<double>> ratesByTicker = {};

    for (final inst in activePortfolio.institutions) {
      for (final acc in inst.accounts) {
        final rate = rates[acc.activeCurrency] ?? 1.0;

        // --- Calculs par Compte ---
        final accValue = acc.totalValue * rate;
        final accPL = acc.profitAndLoss * rate;
        final accInvested = acc.totalInvestedCapital * rate;
        final accCash = acc.cashBalance * rate;

        totalValue += accValue;
        totalPL += accPL;
        totalInvested += accInvested;

        accountValues[acc.id] = accValue;
        accountPLs[acc.id] = accPL;
        accountInvested[acc.id] = accInvested;

        // --- Agrégation par Type (Cash) ---
        if (accCash > 0) {
          aggregatedValueByType.update(
            AssetType.Cash,
                (value) => value + accCash,
            ifAbsent: () => accCash,
          );
        }

        // --- Calculs par Actif Individuel ---
        for (final asset in acc.assets) {
          final assetValueConverted = asset.totalValue * rate;
          final assetPLConverted = asset.profitAndLoss * rate;

          assetValues[asset.id] = assetValueConverted;
          assetPLs[asset.id] = assetPLConverted;

          // --- Agrégation par Type (Actifs) ---
          aggregatedValueByType.update(
            asset.type,
                (value) => value + assetValueConverted,
            ifAbsent: () => assetValueConverted,
          );

          // --- Préparation pour agrégation par Ticker ---
          (assetsByTicker[asset.ticker] ??= []).add(asset);
          // Stocke le taux de change du compte de cet actif
          (ratesByTicker[asset.ticker] ??= []).add(rate);
        }
      }
    }

    // --- 4. Construire l'agrégation par Ticker (pour SyntheseView) ---
    final List<AggregatedAsset> newAggregatedAssets = [];

    assetsByTicker.forEach((ticker, assets) {
      if (assets.isEmpty) return;
      final ratesForTicker = ratesByTicker[ticker]!;

      double aggQuantity = 0;
      double aggTotalValue = 0;
      double aggTotalPL = 0;
      double aggTotalInvested = 0;
      double aggWeightedPRU = 0;
      double aggWeightedCurrentPrice = 0;

      for (int i = 0; i < assets.length; i++) {
        final asset = assets[i];
        final rate = ratesForTicker[i]; // Taux (AssetCurrency -> BaseCurrency)

        // Convertir toutes les valeurs dans la devise de BASE
        final convertedValue = asset.totalValue * rate;
        final convertedPL = asset.profitAndLoss * rate;
        final convertedInvested = asset.totalInvestedCapital * rate;
        final convertedCurrentPrice =
            asset.currentPrice * asset.currentExchangeRate * rate;
        final convertedAvgPrice =
            asset.averagePrice * asset.currentExchangeRate * rate; // Approximation

        aggQuantity += asset.quantity;
        aggTotalValue += convertedValue;
        aggTotalPL += convertedPL;
        aggTotalInvested += convertedInvested;

        // Pondération par quantité pour les prix
        aggWeightedPRU += convertedAvgPrice * asset.quantity;
        aggWeightedCurrentPrice += convertedCurrentPrice * asset.quantity;
      }

      final finalPRU = (aggQuantity > 0) ? aggWeightedPRU / aggQuantity : 0.0;
      final finalCurrentPrice =
      (aggQuantity > 0) ? aggWeightedCurrentPrice / aggQuantity : 0.0;
      final finalPLPercentage =
      (aggTotalInvested > 0) ? aggTotalPL / aggTotalInvested : 0.0;

      if (aggQuantity > 0) {
        final firstAsset = assets.first;
        newAggregatedAssets.add(AggregatedAsset(
          ticker: ticker,
          name: firstAsset.name,
          quantity: aggQuantity,
          averagePrice: finalPRU,
          currentPrice: finalCurrentPrice,
          totalValue: aggTotalValue,
          profitAndLoss: aggTotalPL,
          profitAndLossPercentage: finalPLPercentage,
          estimatedAnnualYield:
          firstAsset.estimatedAnnualYield, // On prend le premier
          metadata: allMetadata[ticker],
          assetCurrency: firstAsset.priceCurrency,
          baseCurrency: targetCurrency,
        ));
      }
    });

    // Trier la liste agrégée
    newAggregatedAssets.sort((a, b) => b.totalValue.compareTo(a.totalValue));

    // 5. Retourner l'objet de données complété
    return AggregatedPortfolioData(
      baseCurrency: targetCurrency,
      totalValue: totalValue,
      totalPL: totalPL,
      totalInvested: totalInvested,
      accountValues: accountValues,
      accountPLs: accountPLs,
      accountInvested: accountInvested,
      assetTotalValues: assetValues,
      assetPLs: assetPLs,
      aggregatedAssets: newAggregatedAssets,
      valueByAssetType: aggregatedValueByType,
    );
  }
}