import 'package:flutter/foundation.dart';
import 'package:portefeuille/core/data/models/portfolio.dart';
import 'package:portefeuille/core/data/models/transaction.dart';
import 'package:portefeuille/core/data/models/transaction_type.dart';
import 'package:portefeuille/core/data/models/portfolio_value_history_point.dart';

class HistoryReconstructionService {
  
  /// Reconstruit l'historique de valeur du portefeuille basé sur les transactions.
  /// 
  /// Stratégie :
  /// - On parcourt les jours depuis la première transaction.
  /// - On maintient l'état du portefeuille (quantités d'actifs).
  /// - Pour le prix :
  ///   - On utilise le prix de la transaction comme "prix connu".
  ///   - Entre deux transactions, on garde le dernier prix connu (Step).
  ///   - C'est une approximation, mais c'est le mieux qu'on puisse faire sans API historique.
  ///   - Pour le Cash, le prix est toujours 1.0 (dans la devise du compte).
  List<PortfolioValueHistoryPoint> reconstructHistory(Portfolio portfolio) {
    debugPrint("--- 📜 Reconstruction de l'historique (Interpolée) ---");
    
    // 1. Récupérer toutes les transactions à plat
    final allTransactions = portfolio.institutions
        .expand((inst) => inst.accounts)
        .expand((acc) => acc.transactions)
        .toList();

    if (allTransactions.isEmpty) {
      debugPrint("  -> Aucune transaction, historique vide.");
      return [];
    }

    // Trier par date
    allTransactions.sort((a, b) => a.date.compareTo(b.date));

    // 2. Préparer les points de prix connus pour chaque actif
    final Map<String, List<MapEntry<DateTime, double>>> pricePoints = {};
    for (final tx in allTransactions) {
      if (tx.price != null && tx.price! > 0) {
        final ticker = tx.assetTicker ?? tx.assetName ?? 'UNKNOWN';
        pricePoints.putIfAbsent(ticker, () => []).add(MapEntry(tx.date, tx.price!));
      }
    }

    final startDate = allTransactions.first.date;
    final endDate = DateTime.now();
    
    // État courant
    final Map<String, double> quantities = {}; // Ticker -> Quantity
    
    final List<PortfolioValueHistoryPoint> history = [];
    
    // Index de transaction courant
    int txIndex = 0;

    // On itère jour par jour
    for (var day = startDate; day.isBefore(endDate) || day.isAtSameMomentAs(endDate); day = day.add(const Duration(days: 1))) {

      // Appliquer les transactions du jour (Mise à jour des quantités)
      while (txIndex < allTransactions.length && _isSameDay(allTransactions[txIndex].date, day)) {
        final tx = allTransactions[txIndex];
        _applyTransactionQuantities(tx, quantities);
        txIndex++;
      }

      // Calculer la valeur totale ce jour-là avec interpolation des prix
      double totalValue = 0.0;
      quantities.forEach((ticker, qty) {
        final price = _getInterpolatedPrice(ticker, day, pricePoints);
        totalValue += qty * price;
      });

      history.add(PortfolioValueHistoryPoint(date: day, value: totalValue));
    }

    debugPrint("  -> Historique reconstruit : ${history.length} points.");
    return history;
  }

  double _getInterpolatedPrice(String ticker, DateTime date, Map<String, List<MapEntry<DateTime, double>>> pricePoints) {
    final points = pricePoints[ticker];
    if (points == null || points.isEmpty) return 0.0;

    // Trouver le point précédent et le point suivant
    MapEntry<DateTime, double>? prev;
    MapEntry<DateTime, double>? next;

    for (final point in points) {
      if (point.key.isBefore(date) || _isSameDay(point.key, date)) {
        prev = point;
      } else {
        next = point;
        break; // On a trouvé le premier point futur
      }
    }

    if (prev == null) return next?.value ?? 0.0; // Avant tout historique connu
    if (next == null) return prev.value; // Après le dernier historique connu (plateau)

    // Interpolation linéaire
    final totalDuration = next.key.difference(prev.key).inMilliseconds;
    if (totalDuration == 0) return prev.value;

    final currentDuration = date.difference(prev.key).inMilliseconds;
    final t = currentDuration / totalDuration;

    return prev.value + (next.value - prev.value) * t;
  }

  bool _isSameDay(DateTime d1, DateTime d2) {
    return d1.year == d2.year && d1.month == d2.month && d1.day == d2.day;
  }

  void _applyTransactionQuantities(Transaction tx, Map<String, double> quantities) {
    final ticker = tx.assetTicker ?? tx.assetName ?? 'UNKNOWN';
    
    // Mise à jour de la quantité
    final currentQty = quantities[ticker] ?? 0.0;
    
    switch (tx.type) {
      case TransactionType.Buy:
        quantities[ticker] = currentQty + (tx.quantity ?? 0.0);
        break;
      case TransactionType.Sell:
        quantities[ticker] = currentQty - (tx.quantity ?? 0.0);
        break;
      case TransactionType.Deposit:
        break;
      case TransactionType.Withdrawal:
        break;
      default:
        break;
    }
    
    // Nettoyage des quantités nulles (optionnel)
    if ((quantities[ticker] ?? 0).abs() < 0.000001) {
      quantities.remove(ticker);
    }
  }
}
