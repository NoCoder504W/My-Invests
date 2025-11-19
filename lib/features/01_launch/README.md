# Feature 01_launch

## Description
Feature responsable de l'écran de lancement et de la configuration initiale de l'application.

## Structure

```
01_launch/
├── ui/
│   ├── launch_screen.dart             # Écran principal de lancement
│   └── widgets/
│       └── initial_setup_wizard.dart  # Assistant de configuration initiale
```

## Responsabilités

- **LaunchScreen** : Point d'entrée pour les nouveaux utilisateurs ou après réinitialisation
- **InitialSetupWizard** : Assistant guidant l'utilisateur dans la configuration initiale (portefeuille, devise, etc.)

## Règles de conformité

✅ **Autorisé** :
- Widgets spécifiques à la configuration initiale
- Logique UI pour guider l'utilisateur

❌ **Interdit** :
- Logique métier (doit être dans Core ou 00_app)
- Dépendances directes aux autres features

## Dépendances

- ✅ Importe : Core, Providers globaux (PortfolioProvider, SettingsProvider)
- ❌ N'importe PAS : Autres features

---

**Dernière mise à jour** : Phase 4 Audit | Constitution v1.0.0

