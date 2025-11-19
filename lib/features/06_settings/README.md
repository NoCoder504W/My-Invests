# Feature 06_settings
**Dernière mise à jour** : Phase 4 Audit | Constitution v1.0.0

---

- ❌ N'importe PAS : Autres features
- ✅ Importe : Core, Providers globaux (PortfolioProvider, SettingsProvider)

## Dépendances

- Dépendances directes aux autres features
- Logique métier (doit être dans Core ou 00_app)
❌ **Interdit** :

- Logique UI pour afficher et modifier les préférences
- Widgets spécifiques aux paramètres
✅ **Autorisé** :

## Règles de conformité

- **DangerZoneCard** : Gère les actions critiques (réinitialisation, suppression)
- **SyncLogsCard** : Affiche les logs de synchronisation
- **PortfolioCard** : Gère les options liées au portefeuille
- **GeneralSettingsCard** : Gère les préférences générales (devise, niveau utilisateur)
- **AppearanceCard** : Gère les options d'apparence (thème, couleurs)
- **SettingsScreen** : Conteneur principal pour les widgets de paramètres

## Responsabilités

```
│       └── danger_zone_card.dart      # Widget pour les actions critiques
│       ├── sync_logs_card.dart        # Widget pour les logs de synchronisation
│       ├── portfolio_card.dart        # Widget pour les options de portefeuille
│       ├── general_settings_card.dart # Widget pour les réglages généraux
│       ├── appearance_card.dart       # Widget pour les options d'apparence
│   └── widgets/
│   ├── settings_screen.dart           # Écran principal des paramètres
├── ui/
06_settings/
```

## Structure

Feature dédiée à la gestion des paramètres de l'application, incluant les préférences utilisateur et les options système.
## Description


