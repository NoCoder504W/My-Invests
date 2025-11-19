# Feature 04_journal

## Description
Feature dédiée à la gestion et à l'affichage des journaux financiers, incluant les transactions et les synthèses.

## Structure

```
04_journal/
├── ui/
│   ├── journal_screen.dart            # Écran principal du journal
│   └── views/
│       ├── transactions_view.dart     # Vue des transactions
│       └── synthese_view.dart         # Vue des synthèses
```

## Responsabilités

- **JournalScreen** : Conteneur principal pour les vues du journal
- **TransactionsView** : Affiche la liste des transactions
- **SyntheseView** : Affiche les synthèses financières

## Règles de conformité

✅ **Autorisé** :
- Widgets spécifiques au journal
- Logique UI pour afficher les transactions et synthèses

❌ **Interdit** :
- Logique métier (doit être dans Core ou 00_app)
- Dépendances directes aux autres features

## Dépendances

- ✅ Importe : Core, Providers globaux (PortfolioProvider, SettingsProvider)
- ❌ N'importe PAS : Autres features

---

**Dernière mise à jour** : Phase 4 Audit | Constitution v1.0.0

