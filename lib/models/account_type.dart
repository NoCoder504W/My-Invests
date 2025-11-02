import 'package:hive/hive.dart';

part 'account_type.g.dart';

/// Enum pour les différents types de comptes financiers.
@HiveType(typeId: 4)
enum AccountType {
  /// Plan d'Épargne en Actions
  @HiveField(0)
  PEA,

  /// Compte-Titres Ordinaire
  @HiveField(1)
  CTO,

  /// Assurance Vie
  @HiveField(2)
  AssuranceVie,

  /// Plan Épargne Retraite
  @HiveField(3)
  PER,

  /// Portefeuille de crypto-monnaies
  @HiveField(4)
  Crypto,

  /// Autre type de compte
  @HiveField(5)
  Autre,
}
