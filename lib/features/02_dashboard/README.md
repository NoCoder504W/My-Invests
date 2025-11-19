# Feature 02_dashboard

## Description
Feature responsable de l'affichage du tableau de bord principal, où l'utilisateur peut consulter un résumé de ses données financières.

## Structure

```
02_dashboard/
├── ui/
│   ├── dashboard_screen.dart          # Écran principal du tableau de bord
│   └── widgets/
│       ├── summary_card.dart          # Widget pour les résumés financiers
│       └── performance_chart.dart     # Widget pour les graphiques de performance
```

## Responsabilités

- **DashboardScreen** : Conteneur principal pour les widgets du tableau de bord
- **SummaryCard** : Affiche un résumé des données financières (solde, revenus, dépenses)
- **PerformanceChart** : Affiche les graphiques de performance (rendement, historique)

## Règles de conformité

✅ **Autorisé** :
- Widgets spécifiques au tableau de bord
- Logique UI pour afficher les données

❌ **Interdit** :
- Logique métier (doit être dans Core ou 00_app)
- Dépendances directes aux autres features

## Dépendances

- ✅ Importe : Core, Providers globaux (PortfolioProvider, SettingsProvider)
- ❌ N'importe PAS : Autres features

---

**Dernière mise à jour** : Phase 4 Audit | Constitution v1.0.0

