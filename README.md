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
├── models/
│   ├── portfolio.dart      # Modèle racine, contenant la liste des institutions.
│   ├── institution.dart    # Représente une institution financière (banque, courtier).
│   ├── account.dart        # Représente un compte financier (PEA, CTO, etc.).
│   ├── asset.dart          # Représente un actif (action, obligation, crypto).
│   └── account_type.dart   # Énumération des différents types de comptes.
│
├── providers/      # Logique métier et gestion de l'état (ex: PortfolioProvider).
│
├── screens/        # Widgets représentant les écrans complets de l'application.
│   └── tabs/       # Widgets pour les différents onglets du tableau de bord.
│
├── utils/          # Classes utilitaires (formatters, thèmes, etc.).
│
├── widgets/        # Widgets réutilisables (graphiques, cartes, etc.).
│
└── main.dart       # Point d'entrée de l'application.
```

### Logique de l'application

L'application s'articule autour du modèle `Portfolio`, qui est l'objet principal persistant dans la base de données locale (Hive).

- Un `Portfolio` contient une liste d'`Institution`.
- Chaque `Institution` (ex: "Boursorama", "Binance") contient une liste d'`Account`.
- Chaque `Account` (ex: "PEA", "CTO") a un `AccountType` et contient une liste d'`Asset`.
- Chaque `Asset` représente un actif financier individuel avec sa quantité, son prix moyen d'achat et son prix actuel.

La logique de calcul (valeur totale, plus-values, rendement) est répartie dans les modèles : chaque modèle calcule ses propres métriques, qui sont ensuite agrégées par le modèle parent. Par exemple, la valeur totale d'une `Institution` est la somme des valeurs de ses `Account`.
