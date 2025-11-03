# Portefeuille - Gestionnaire de Finances Personnelles

Une application Flutter pour suivre et analyser vos investissements sur différentes plateformes (banques, courtiers, crypto-monnaies).

## ✨ Fonctionnalités

*   **Vue d'ensemble centralisée** : Visualisez la valeur totale de votre portefeuille en un coup d'œil.
*   **Suivi multi-comptes** : Agrégez des comptes de différents types (CTO, PEA, Assurance Vie, Crypto) et de différentes institutions.
*   **Calcul de performance** : Suivez vos plus/moins-values et estimez le rendement annuel de vos actifs.
*   **Mode Démo** : Une version de démonstration pré-remplie pour découvrir rapidement les fonctionnalités de l'application.
*   **Personnalisation** : Paramètres pour adapter l'expérience utilisateur.

## 🚀 Démarrer avec le projet

### Prérequis

*   [Flutter SDK](https://flutter.dev/docs/get-started/install) (version 3.x ou supérieure)
*   Un éditeur de code comme [VS Code](https://code.visualstudio.com/) ou [Android Studio](https://developer.android.com/studio).

### Installation

1.  **Clonez le dépôt** :
    ```sh
    git clone <URL_DU_DEPOT_GIT>
    cd Portefeuille
    ```

2.  **Installez les dépendances** :
    ```sh
    flutter pub get
    ```

3.  **Générez les fichiers nécessaires** (pour Hive) :
    ```sh
    flutter pub run build_runner build --delete-conflicting-outputs
    ```

### Lancer l'application

*   **Avec VS Code ou Android Studio** : Lancez l'application en mode "Debug" via l'interface de l'éditeur.
*   **En ligne de commande** :
    ```sh
    flutter run
    ```

> **Note pour le développement** : En mode "debug", toutes les données sont automatiquement effacées à chaque redémarrage pour garantir un environnement de test propre.

## 📂 Structure du projet

```
lib/
├── main.dart               # Point d'entrée de l'application

├── models/                 # Modèles de données (persistés avec Hive)
│   ├── account.dart        # Modèle pour un compte (PEA, CTO, etc.)
│   ├── account.g.dart      # Fichier généré par Hive pour account.dart
│   ├── account_type.dart   # Enum pour les types de comptes
│   ├── account_type.g.dart # Fichier généré par Hive pour account_type.dart
│   ├── asset.dart          # Modèle pour un actif (action, crypto, etc.)
│   ├── asset.g.dart        # Fichier généré par Hive pour asset.dart
│   ├── institution.dart    # Modèle pour une institution financière (banque, courtier)
│   ├── institution.g.dart  # Fichier généré par Hive pour institution.dart
│   ├── portfolio.dart      # Modèle principal qui contient toutes les données
│   └── portfolio.g.dart    # Fichier généré par Hive pour portfolio.dart

├── providers/              # (Vide) Fournisseurs de données (potentiellement pour Riverpod/Provider)

├── screens/                # Écrans principaux de l'application
│   ├── dashboard_screen.dart # Écran principal avec la vue d'ensemble du portefeuille
│   ├── launch_screen.dart    # Écran de chargement initial
│   ├── settings_screen.dart  # Écran des paramètres
│   ├── tabs/                 # Onglets affichés sur le dashboard
│   │   ├── correction_tab.dart # Onglet pour la correction des données
│   │   ├── overview_tab.dart   # Onglet principal de vue d'ensemble
│   │   └── planner_tab.dart    # Onglet pour la planification
│   └── welcome_screen.dart   # Écran d'accueil pour les nouveaux utilisateurs

├── utils/                  # Classes et fonctions utilitaires
│   ├── app_theme.dart        # Thème de l'application (couleurs, polices)
│   └── currency_formatter.dart # Formateur pour les montants monétaires

└── widgets/                # Widgets réutilisables
    ├── analysis/           # Widgets liés à l'analyse
    │   └── ai_analysis_card.dart # Carte d'analyse par IA
    ├── charts/             # Widgets de graphiques
    │   └── allocation_chart.dart # Graphique d'allocation du portefeuille
    ├── common/             # Widgets communs et génériques
    │   └── account_type_chip.dart # Puce pour afficher le type de compte
    └── portfolio/          # Widgets spécifiques à l'affichage du portefeuille
        ├── account_tile.dart     # Tuile pour afficher un compte
        ├── asset_list_item.dart  # Élément de liste pour un actif
        ├── institution_list.dart # Liste des institutions
        ├── institution_tile.dart # Tuile pour afficher une institution
        └── portfolio_header.dart # En-tête du portefeuille
```

### Logique de l'application

L'application s'articule autour du modèle `Portfolio`, qui est l'objet principal persistant dans la base de données locale (Hive).

- Un `Portfolio` contient une liste d'`Institution`.
- Chaque `Institution` (ex: "Boursorama", "Binance") contient une liste d'`Account`.
- Chaque `Account` (ex: "PEA", "CTO") a un `AccountType` et contient une liste d'`Asset`.
- Chaque `Asset` représente un actif financier individuel avec sa quantité, son prix moyen d'achat et son prix actuel.

La logique de calcul (valeur totale, plus-values, rendement) est répartie dans les modèles : chaque modèle calcule ses propres métriques, qui sont ensuite agrégées par le modèle parent. Par exemple, la valeur totale d'une `Institution` est la somme des valeurs de ses `Account`.
