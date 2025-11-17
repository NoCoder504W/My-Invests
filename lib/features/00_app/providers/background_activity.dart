// lib/features/00_app/providers/background_activity.dart
// NOUVEAU FICHIER

/// Décrit l'activité de fond non-bloquante du PortfolioProvider.
enum BackgroundActivity {
  /// Aucune activité. L'interface est stable.
  none,

  /// Une synchronisation API (prix) est en cours.
  syncing,

  /// Un recalcul (changement de devise) est en cours.
  recalculating
}