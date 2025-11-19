# Feature 00_app

## Description
Feature système contenant la configuration globale de l'application, les providers centralisés et les services métier transversaux.

## Structure

```
00_app/
├── main.dart                          # Point d'entrée de l'application
├── providers/
│   ├── portfolio_provider.dart        # Provider global du portefeuille (état)
│   └── settings_provider.dart         # Provider global des paramètres (thème, devise, etc.)
├── services/
│   ├── route_manager.dart             # Gestion centralisée des routes nommées
│   ├── modal_service.dart             # Gestion centralisée des BottomSheets
│   ├── api_service.dart               # Service d'appels API
│   ├── calculation_service.dart       # Calculs financiers (P&L, rendement, etc.)
│   ├── hydration_service.dart         # Service d'hydratation Hive
│   ├── demo_data_service.dart         # Génération de données de démo
│   ├── migration_service.dart         # Migrations de schéma Hive
│   ├── transaction_service.dart       # Opérations sur les transactions
│   └── sync_service.dart              # Synchronisation des prix API
└── models/
    └── background_activity.dart       # États d'activité en arrière-plan
```

## Responsabilités

- **main.dart** : Configuration MaterialApp, routing, providers globaux
- **Providers** : État global accessible depuis toutes les features
- **Services** : Logique métier centralisée (API, calculs, migrations, sync)
- **Models** : Types de données transversaux

## Règles de conformité

✅ **Autorisé** :
- Services métier globaux
- Providers d'état global (PortfolioProvider, SettingsProvider)
- Routes centralisées (RouteManager)
- Modales centralisées (ModalService)

❌ **Interdit** :
- UI spécifique à une feature
- Logic métier spécifique à une feature
- Dépendances directes aux features

## Dépendances

- ✅ Importe : Core, Provider, Hive, API externe
- ❌ N'importe PAS : Autres features (sauf refs de navigation)

---

**Dernière mise à jour** : Phase 4 Audit | Constitution v1.0.0

