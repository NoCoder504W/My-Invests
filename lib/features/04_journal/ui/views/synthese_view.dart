// lib/features/04_journal/ui/views/synthese_view.dart
// REMPLACEZ LE FICHIER COMPLET

import 'package:flutter/material.dart';
import 'package:portefeuille/core/data/models/asset.dart';
import 'package:portefeuille/core/data/models/asset_type.dart';
import 'package:portefeuille/core/data/models/transaction.dart';
import 'package:portefeuille/core/utils/currency_formatter.dart';
import 'package:portefeuille/features/00_app/providers/portfolio_provider.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

// Classe temporaire pour l'agrégation
class AggregatedAsset {
  final String ticker;
  final String name;
  final double quantity;
  final double averagePrice; // PRU agrégé
  final double currentPrice;
  final double estimatedAnnualYield;

  AggregatedAsset({
    required this.ticker,
    required this.name,
    required this.quantity,
    required this.averagePrice,
    required this.currentPrice,
    required this.estimatedAnnualYield,
  });

  double get totalValue => quantity * currentPrice;
  double get profitAndLoss => (currentPrice - averagePrice) * quantity;
}

class SyntheseView extends StatelessWidget {
  const SyntheseView({super.key});

  /// Logique d'agrégation des actifs
  List<AggregatedAsset> _aggregateAssets(PortfolioProvider provider) {
    final allTransactions = provider.activePortfolio?.institutions
        .expand((inst) => inst.accounts)
        .expand((acc) => acc.transactions)
        .toList() ??
        [];

    final allAssets = provider.activePortfolio?.institutions
        .expand((inst) => inst.accounts)
        .expand((acc) => acc.assets) // Utilise le getter 'assets'
        .toList() ??
        [];

    // 1. Grouper les transactions d'achat/vente par ticker
    final Map<String, List<Transaction>> groupedTransactions = {};
    for (final tr in allTransactions) {
      if (tr.assetTicker != null) {
        (groupedTransactions[tr.assetTicker!] ??= []).add(tr);
      }
    }

    final List<AggregatedAsset> aggregatedList = [];
    const uuid = Uuid();

    // 2. Calculer les métriques agrégées pour chaque ticker
    groupedTransactions.forEach((ticker, transactions) {
      // 3. Recréer un objet Asset temporaire (comme le fait Account.assets)
      //    pour utiliser ses getters (quantity, averagePrice)
      final lastTx =
      transactions.reduce((a, b) => a.date.isAfter(b.date) ? a : b);
      final tempAsset = Asset(
        id: uuid.v4(),
        name: lastTx.assetName ?? ticker,
        ticker: ticker,
        type: lastTx.assetType ?? AssetType.Other,
        transactions: transactions,
      );

      // 4. Récupérer le prix actuel (déjà synchronisé dans le provider)
      final currentAsset = allAssets.firstWhere(
            (a) => a.ticker == ticker,
        orElse: () => tempAsset, // Fallback si non trouvé
      );

      // N'ajoute pas l'actif si la quantité est nulle
      if (tempAsset.quantity > 0) {
        aggregatedList.add(
          AggregatedAsset(
            ticker: ticker,
            name: currentAsset.name,
            quantity: tempAsset.quantity,
            averagePrice: tempAsset.averagePrice,
            currentPrice: currentAsset.currentPrice,
            estimatedAnnualYield: currentAsset.estimatedAnnualYield,
          ),
        );
      }
    });

    // Trier par valeur totale
    aggregatedList.sort((a, b) => b.totalValue.compareTo(a.totalValue));
    return aggregatedList;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PortfolioProvider>(
      builder: (context, provider, child) {
        final aggregatedAssets = _aggregateAssets(provider);

        if (aggregatedAssets.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.pie_chart_outline, size: 48, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'Aucun actif à agréger',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        }

        // 5. Construire le DataTable
        // MODIFIÉ : Utilisation de LayoutBuilder pour forcer la largeur maximale
        return SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: ConstrainedBox(
                  // Force le DataTable à prendre au moins la largeur de l'écran
                  constraints: BoxConstraints(minWidth: constraints.maxWidth),
                  child: DataTable(
                    columnSpacing: 20.0,
                    columns: const [
                      DataColumn(label: Text('Actif')),
                      DataColumn(label: Text('Quantité'), numeric: true),
                      DataColumn(label: Text('PRU'), numeric: true),
                      DataColumn(label: Text('Valeur'), numeric: true),
                      DataColumn(label: Text('P/L'), numeric: true),
                    ],
                    rows: aggregatedAssets.map((asset) {
                      final pnl = asset.profitAndLoss;
                      final pnlColor =
                      pnl >= 0 ? Colors.green.shade400 : Colors.red.shade400;

                      return DataRow(
                        cells: [
                          // Actif
                          DataCell(
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(asset.name,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold)),
                                Text(asset.ticker,
                                    style: const TextStyle(
                                        fontSize: 12, color: Colors.grey)),
                              ],
                            ),
                          ),
                          // Quantité
                          DataCell(Text(asset.quantity.toStringAsFixed(2))),
                          // PRU
                          DataCell(
                              Text(CurrencyFormatter.format(asset.averagePrice))),
                          // Valeur
                          DataCell(Text(CurrencyFormatter.format(asset.totalValue),
                              style:
                              const TextStyle(fontWeight: FontWeight.bold))),
                          // P/L
                          DataCell(
                            Text(
                              CurrencyFormatter.format(pnl),
                              style: TextStyle(color: pnlColor),
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}