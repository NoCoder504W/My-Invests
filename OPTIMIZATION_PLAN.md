# Plan d'Optimisation et de Refactoring

Ce document détaille la feuille de route pour l'optimisation globale de l'application, visant à améliorer la performance, la maintenabilité et le respect de l'architecture "Feature-First".

## Phase 1 : Renforcement de la Qualité et Standards
**Objectif** : Durcir les règles de développement pour garantir un code propre, performant et uniforme.

- [x] **Mise à jour du Linter** : Configurer `analysis_options.yaml` avec des règles strictes (pedantic/lints).
    - Forcer l'utilisation de `const` pour les widgets (gain de performance majeur).
    - Forcer le typage statique.
    - Interdire les `print` en production.
- [x] **Correction des avertissements** : Appliquer les corrections automatiques (`dart fix`) et manuelles sur l'ensemble du projet.
    - [x] Correction automatique (`dart fix --apply`) : 41 corrections.
    - [x] Renommage des champs obsolètes (`stale_` -> `stale`) pour respecter le camelCase.
    - [x] Remplacement complet de `withOpacity` par `withValues` (Core UI & Features).
    - [x] Correction des `use_build_context_synchronously` et autres warnings.
- [x] **Standardisation** : Vérifier que tous les fichiers respectent les conventions de nommage définies dans `ARCHITECTURE.md`.

## Phase 2 : Optimisation du State Management (`PortfolioProvider`)
**Objectif** : Alléger le "God Object" `PortfolioProvider` et optimiser les calculs.

- [x] **Extraction des Calculs** : Déplacer la logique lourde (totaux, performances) hors de la méthode `build` ou des getters synchrones appelés fréquemment.
    - Utiliser des variables mises en cache (`_cachedTotalValue`, etc.) mises à jour uniquement lors de la modification des données.
- [x] **Optimisation des Getters** : Transformer les getters coûteux (ex: `hasCrowdfunding`) en propriétés calculées une seule fois lors du chargement/mise à jour du portefeuille.
- [x] **Séparation des Responsabilités** : Si le provider reste trop gros, extraire certaines logiques (ex: Sync, Migration) dans des services dédiés ou des sous-providers si nécessaire (bien que l'architecture actuelle utilise des services injectés, le provider fait beaucoup de "passe-plat").

## Phase 3 : Optimisation de l'UI et des Rebuilds
**Objectif** : Réduire les reconstructions inutiles de l'interface utilisateur.

- [x] **Utilisation de `Selector`** : Remplacer les `context.watch<PortfolioProvider>()` globaux par des `Selector<PortfolioProvider, T>` dans les widgets qui n'ont besoin que d'une partie spécifique de l'état (ex: `DashboardScreen`).
    - `OverviewTab` : Optimisé avec `Selector` (Record).
    - `PortfolioHistoryChart` : Optimisé avec `Selector`.
    - `SyncAlertsCard` : Optimisé avec `Selector`.
    - `SettingsScreen` : Suppression des `context.watch` inutiles.
    - `PlannerTab` : Optimisé avec `Selector`.
    - `ProjectionSection` : Optimisé avec `Selector` (Record).
    - `SavingsPlansSection` : Optimisé avec `Selector`.
    - `TransactionsView` : Optimisé avec `Selector`.

## Phase 4 : Architecture Cleanup
**Objectif** : Nettoyer le code et finaliser l'architecture.
- [x] **Découpage des Widgets** : Identifier les gros widgets qui rebuildent trop souvent et les découper en composants plus petits et constants (`const`).
    - `DashboardScreen` optimisé avec `Selector` et logique extraite.
- [x] **Lazy Loading** : Vérifier que les onglets ou listes lourdes sont chargés de manière paresseuse si possible.
    - `DashboardScreen` utilise `tabs` qui sont instanciés mais `OverviewTab` etc. sont des widgets. Flutter gère le lazy loading des onglets si `TabBarView` est utilisé (ce qui n'est pas le cas ici, c'est un `IndexedStack` ou switch simple).
    - *Note* : `DashboardScreen` utilise une liste `tabs` simple. Pour l'instant c'est acceptable car les onglets ne sont pas trop lourds à l'initialisation.

## Phase 4 : Nettoyage, Architecture et Maintenance
**Objectif** : Assurer la pérennité du code et le respect strict de l'architecture modulaire.

- [x] **Vérification des Imports** : S'assurer qu'aucune feature n'importe directement le code d'une autre feature (doit passer par `core` ou `RouteManager`).
- [x] **Nettoyage du Code Mort** : Supprimer les fichiers, modèles ou méthodes non utilisés.
    - `PortfolioProvider` nettoyé.
    - `DashboardScreen` nettoyé.
- [x] **Documentation** : Mettre à jour la documentation technique si des changements majeurs ont été effectués.
    - `ARCHITECTURE.md` mis à jour.
