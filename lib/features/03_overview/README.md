# Feature 03_overview

## Description
Feature dédiée à l'affichage détaillé des données financières, incluant les répartitions et les analyses.

## Structure

```
03_overview/
├── ui/
│   ├── overview_screen.dart           # Écran principal de l'aperçu
│   └── widgets/
│       ├── asset_allocation_chart.dart # Répartition des actifs
│       └── sync_alerts_card.dart      # Alertes de synchronisation
```

## Responsabilités

- **OverviewScreen** : Conteneur principal pour les widgets d'aperçu
- **AssetAllocationChart** : Affiche la répartition des actifs par catégorie
- **SyncAlertsCard** : Affiche les alertes liées à la synchronisation des données

## Règles de conformité

✅ **Autorisé** :
- Widgets spécifiques à l'aperçu des données
- Logique UI pour afficher les répartitions et alertes

❌ **Interdit** :
- Logique métier (doit être dans Core ou 00_app)
- Dépendances directes aux autres features

## Dépendances

- ✅ Importe : Core, Providers globaux (PortfolioProvider, SettingsProvider)
- ❌ N'importe PAS : Autres features

---

**Dernière mise à jour** : Phase 4 Audit | Constitution v1.0.0

