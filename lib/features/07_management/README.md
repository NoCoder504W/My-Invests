# Feature 07_management

## Description
Feature dédiée à la gestion avancée des portefeuilles, incluant les outils d'analyse et de modification.

## Structure

```
07_management/
├── ui/
│   ├── management_screen.dart         # Écran principal de gestion
│   └── widgets/
│       ├── portfolio_editor.dart      # Widget pour éditer les portefeuilles
│       ├── risk_analysis_card.dart    # Widget pour l'analyse des risques
│       └── allocation_optimizer.dart  # Widget pour optimiser les allocations
```

## Responsabilités

- **ManagementScreen** : Conteneur principal pour les outils de gestion
- **PortfolioEditor** : Permet de modifier les portefeuilles existants
- **RiskAnalysisCard** : Affiche une analyse des risques
- **AllocationOptimizer** : Propose des optimisations pour les allocations

## Règles de conformité

✅ **Autorisé** :
- Widgets spécifiques à la gestion avancée
- Logique UI pour les outils d'analyse et de modification

❌ **Interdit** :
- Logique métier (doit être dans Core ou 00_app)
- Dépendances directes aux autres features

## Dépendances

- ✅ Importe : Core, Providers globaux (PortfolioProvider, SettingsProvider)
- ❌ N'importe PAS : Autres features

---

**Dernière mise à jour** : Phase 4 Audit | Constitution v1.0.0

