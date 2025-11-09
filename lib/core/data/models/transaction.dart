import 'package:hive/hive.dart';
import 'transaction_type.dart';
import 'asset_type.dart';

part 'transaction.g.dart';

@HiveType(typeId: 7) // IMPORTANT: Utilisez un ID non utilisé (ex: 7)
class Transaction {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String accountId; // Compte parent

  @HiveField(2)
  final TransactionType type;

  @HiveField(3)
  final DateTime date;

  @HiveField(4)
  final String? assetTicker; // Ticker de l'actif (pour Achat/Vente/Dividende)

  @HiveField(5)
  final String? assetName; // Nom de l'actif (pour Afile:///home/runner/work/gemini/gemini/google/generative-ai/backend/user_data/app_data/2025-11-09-1435_Portfeuille-restore-point/lib/features/03_overview/ui/widgets/asset_list_item.dart Achat/Vente)

  @HiveField(6)
  final double? quantity; // Quantité d'actifs (pour Achat/Vente)

  @HiveField(7)
  final double? price; // Prix unitaire (pour Achat/Vente/Dividende)

  @HiveField(8)
  final double amount; // Montant en liquidités (négatif si sortie)

  @HiveField(9)
  final double fees; // Frais (toujours positifs, déduits du montant)

  @HiveField(10)
  final String notes;

  // --- NOUVEAU CHAMP ---
  @HiveField(11)
  final AssetType? assetType; // Pour Achat/Vente
  // --- FIN NOUVEAU ---

  Transaction({
    required this.id,
    required this.accountId,
    required this.type,
    required this.date,
    required this.amount,
    this.assetTicker,
    this.assetName,
    this.quantity,
    this.price,
    this.fees = 0.0,
    this.notes = '',
    this.assetType,
  });

  // Helper pour obtenir le montant total de la transaction (ex: Achat)
  double get totalAmount {
    // Pour un achat, amount = (quantity * price) * -1
    // Pour une vente, amount = (quantity * price)
    // Pour un dépôt, amount = montant
    return amount - fees;
  }
}