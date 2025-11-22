import 'package:portefeuille/core/data/models/asset.dart';
import 'package:portefeuille/core/data/models/asset_type.dart';
import 'package:portefeuille/core/data/models/repayment_type.dart';
import 'package:portefeuille/core/data/models/transaction_type.dart';

class CrowdfundingProjection {
  final String assetId;
  final String assetName;
  final DateTime date;
  final double amount;
  final TransactionType type; // InterestPayment or CapitalRepayment
  final bool isProjected;

  CrowdfundingProjection({
    required this.assetId,
    required this.assetName,
    required this.date,
    required this.amount,
    required this.type,
    this.isProjected = true,
  });
}

class CrowdfundingService {
  /// Génère les flux futurs pour une liste d'actifs de Crowdfunding
  List<CrowdfundingProjection> generateProjections(List<Asset> assets) {
    final List<CrowdfundingProjection> projections = [];
    final now = DateTime.now();

    for (final asset in assets) {
      if (asset.type != AssetType.RealEstateCrowdfunding) continue;
      if (asset.quantity <= 0) continue; // Actif vendu ou remboursé

      // On se base sur la première transaction d'achat pour déterminer le début
      // Idéalement, on devrait avoir une date de début explicite, mais la date d'achat fait l'affaire.
      final buyTransactions = asset.transactions
          .where((t) => t.type == TransactionType.Buy)
          .toList();
      
      if (buyTransactions.isEmpty) continue;
      
      // On prend la date la plus ancienne comme début du projet
      buyTransactions.sort((a, b) => a.date.compareTo(b.date));
      final startDate = buyTransactions.first.date;

      final durationMonths = asset.targetDuration ?? 0;
      if (durationMonths <= 0) continue;

      final endDate = startDate.add(Duration(days: durationMonths * 30)); // Approx
      
      // Si le projet est censé être fini et qu'on a toujours des parts, 
      // c'est qu'il est en retard. On projette un remboursement "bientôt" (ex: +1 mois)
      // ou on arrête les projections si on considère qu'on ne sait pas.
      // Ici, on va projeter jusqu'à la fin théorique si elle est dans le futur.
      
      if (endDate.isBefore(now)) {
        // Projet en retard : on pourrait ajouter une projection "Retard" ou "Remboursement estimé"
        // Pour l'instant, on ne projette rien de plus si la date cible est passée,
        // sauf si on implémente la logique "Max Duration".
        continue; 
      }

      final investedCapital = asset.quantity; // En supposant prix unitaire = 1
      final yieldRate = (asset.expectedYield ?? 0.0) / 100.0;

      if (asset.repaymentType == RepaymentType.MonthlyInterest) {
        // Intérêts mensuels
        final monthlyInterest = (investedCapital * yieldRate) / 12;
        
        var currentDate = startDate;
        // On avance mois par mois jusqu'à la fin
        while (currentDate.isBefore(endDate)) {
          currentDate = DateTime(currentDate.year, currentDate.month + 1, currentDate.day);
          
          if (currentDate.isAfter(endDate)) break;

          if (currentDate.isAfter(now)) {
             projections.add(CrowdfundingProjection(
               assetId: asset.id,
               assetName: asset.name,
               date: currentDate,
               amount: monthlyInterest,
               type: TransactionType.Interest, // Utilisation de Interest standard
             ));
          }
        }
        
        // Remboursement du capital à la fin
        if (endDate.isAfter(now)) {
           projections.add(CrowdfundingProjection(
             assetId: asset.id,
             assetName: asset.name,
             date: endDate,
             amount: investedCapital,
             type: TransactionType.CapitalRepayment,
           ));
        }

      } else if (asset.repaymentType == RepaymentType.InFine) {
        // Tout à la fin
        if (endDate.isAfter(now)) {
          // Calcul des intérêts totaux (simple pour l'instant : Capital * Taux * (Durée/12))
          final totalInterest = investedCapital * yieldRate * (durationMonths / 12.0);
          
          projections.add(CrowdfundingProjection(
             assetId: asset.id,
             assetName: asset.name,
             date: endDate,
             amount: totalInterest,
             type: TransactionType.Interest,
           ));

           projections.add(CrowdfundingProjection(
             assetId: asset.id,
             assetName: asset.name,
             date: endDate,
             amount: investedCapital,
             type: TransactionType.CapitalRepayment,
           ));
        }
      }
    }

    projections.sort((a, b) => a.date.compareTo(b.date));
    return projections;
  }
}
