# Portefeuille — Gestionnaire de Finances Personnelles (Flutter)

Une application Flutter moderne pour agréger et analyser vos comptes et investissements (banques, courtiers, cryptos). Suivez votre patrimoine, visualisez vos performances et planifiez votre avenir financier.

## Résumé

- **Langage** : Dart / Flutter
- **Point d'entrée** : `lib/features/00_app/main.dart`
- **Stockage local** : Hive (base de données NoSQL légère et rapide)
- **Architecture** : Organisation par fonctionnalités (feature-first)
- **Gestion d'état** : Provider
- **Principales dépendances** : provider, hive, hive_flutter, fl_chart, intl, uuid, shimmer, animated_text_kit, http, flutter_secure_storage

## Fonctionnalités Principales

- **Multi-portefeuilles** : Créez et gérez plusieurs portefeuilles d'investissement
- **Synchronisation en ligne** : Récupération automatique des prix en temps réel (FMP et Yahoo Finance)
- **Recherche intelligente** : Auto-complétion des tickers et ISIN lors de l'ajout d'actifs
- **Types de comptes supportés** :
  - PEA (Plan d'Épargne en Actions)
  - CTO (Compte-Titres Ordinaire)
  - Assurance Vie
  - PER (Plan Épargne Retraite)
  - Crypto-monnaies
  - Autres comptes personnalisés
- **Suivi en temps réel** : Visualisez la valeur totale de vos actifs
- **Analyse de performance** : Calcul automatique des plus/moins-values (P/L) et rendements
- **Graphiques interactifs** : Visualisations avec fl_chart pour suivre l'évolution de votre patrimoine
- **Mode démo** : Découvrez l'application avec des données de démonstration
- **Personnalisation** : Choix de couleurs pour l'interface
- **Gestion complète** :
  - Ajout/modification/suppression d'institutions financières
  - Gestion de comptes et d'actifs
  - Correction manuelle des données
- **Planificateur** : Simulez vos investissements futurs
- **Persistance des données** : Sauvegarde automatique locale avec Hive

## 🌐 Mode En Ligne et Synchronisation des Prix

L'application propose un **mode en ligne optionnel** qui permet de synchroniser automatiquement les prix de vos actifs et de bénéficier d'une aide à la saisie lors de l'ajout de nouveaux actifs.

### Activation du Mode En Ligne

1. Ouvrez l'écran des **Paramètres** (icône ⚙️ en haut à droite)
2. Activez l'option **"Mode en ligne"**
3. L'indicateur de statut dans l'AppBar affiche maintenant **"En ligne"**

### Fonctionnement

#### Récupération des Prix

L'application utilise une **stratégie de fallback intelligente** :

1. **Financial Modeling Prep (FMP)** : Si vous avez configuré une clé API (optionnel)
   - Plus fiable et complète
   - Requiert une inscription gratuite sur [financialmodelingprep.com](https://financialmodelingprep.com)
   
2. **Yahoo Finance** : Utilisé automatiquement en fallback ou si aucune clé FMP n'est configurée
   - Gratuit et sans inscription
   - Fonctionne pour la majorité des tickers (actions, ETF, cryptos)

#### Cache Intelligent

Pour optimiser les performances et limiter les appels API :
- **Prix** : Mis en cache pendant **15 minutes**
- **Recherche de tickers** : Mise en cache pendant **24 heures**

### Configuration de la Clé API FMP (Optionnel)

Pour améliorer la fiabilité de la synchronisation, vous pouvez configurer une clé API Financial Modeling Prep :

1. Créez un compte gratuit sur [financialmodelingprep.com](https://financialmodelingprep.com)
2. Récupérez votre clé API depuis votre tableau de bord
3. Dans l'application :
   - Ouvrez **Paramètres** > **Paramètres de l'Application**
   - Activez le **Mode en ligne**
   - Dans le champ **"Clé API FMP (Optionnel)"**, saisissez votre clé
   - Cliquez sur l'icône 💾 pour sauvegarder

**Sécurité** : La clé API est stockée de manière sécurisée dans le Keystore (Android) / Keychain (iOS) / Credential Manager (Windows).

### Recherche de Tickers et Auto-complétion

Lors de l'ajout d'un actif (écran "Ajouter un actif") :

1. Commencez à taper un **ticker** (ex: "AAPL") ou un **ISIN** dans le champ dédié
2. Après 500ms, des suggestions apparaissent automatiquement (si le mode en ligne est actif)
3. Sélectionnez une suggestion pour :
   - Remplir automatiquement le **nom** de l'actif
   - Récupérer le **prix actuel** en temps réel
   - Pré-remplir le **prix de revient unitaire** (PRU) avec le prix actuel

**Types de résultats supportés** : Actions (EQUITY), ETF, Crypto-monnaies

### Synchronisation Automatique

Les prix sont synchronisés automatiquement dans les cas suivants :
- **Au démarrage** de l'application (si le mode en ligne est actif)
- **À l'activation** du mode en ligne
- L'indicateur **"Synchro..."** s'affiche pendant la mise à jour

**Mode hors ligne** : L'application fonctionne parfaitement sans connexion internet. Les prix restent ceux saisis manuellement ou récupérés lors de la dernière synchronisation.

### Indicateur de Statut

L'AppBar du Dashboard affiche l'état actuel de la connectivité :
- ☁️ **"En ligne"** : Mode en ligne actif, synchronisation disponible
- 🚫 **"Hors ligne"** : Mode hors ligne, pas de synchronisation
- ⏳ **"Synchro..."** : Synchronisation en cours

### Limitations et Bonnes Pratiques

#### API Gratuites
- **Yahoo Finance** : Aucune limitation officielle mais évitez les requêtes excessives
- **FMP (gratuit)** : Généralement limité à 250 requêtes/jour (vérifiez votre plan)

#### Recommandations
- Le cache évite la plupart des appels répétés
- La synchronisation est optimisée (appels en parallèle)
- En cas d'échec, les prix existants sont conservés
- Les erreurs sont loguées dans la console (mode debug)

## Prérequis

- Flutter SDK (compatible avec Dart >=3.4.0 <4.0.0). Installez depuis https://flutter.dev
- Un appareil ou émulateur (Android / iOS / Windows / macOS / Linux)
- Git pour cloner le dépôt

## Installation rapide

1. Clonez le dépôt :

```powershell
git clone <URL_DU_DEPOT_GIT>
cd Portefeuille
```

2. Récupérez les packages :

```powershell
flutter pub get
```

3. Générez les fichiers de sérialisation Hive (codegen) :

```powershell
flutter pub run build_runner build --delete-conflicting-outputs
```

4. Lancez l'application (ex. sur l'émulateur Android par défaut) :

```powershell
flutter run
```

## Notes de développement

- Le point d'entrée est `lib/features/00_app/main.dart`. Le `main` initialise Hive, enregistre les adapters et ouvre les boxes principales avant d'instancier le repository.
- **Important** : Le mode debug ne supprime plus automatiquement la base de données Hive (le `Hive.deleteFromDisk()` est commenté), permettant ainsi de tester la persistance des données.
- Pour générer ou regénérer les fichiers `.g.dart` liés à Hive après modification des modèles, utilisez :

```powershell
flutter pub run build_runner build --delete-conflicting-outputs
```

- L'application utilise deux boxes Hive :
  - `kPortfolioBoxName` : pour les données de portefeuille
  - `kSettingsBoxName` : pour les paramètres de l'application (couleur, etc.)

## Compilation — APK (Android) et EXE (Windows)

Voici les commandes et prérequis pour compiler des binaires pour Android (APK / AAB) et Windows (EXE).

**Prérequis généraux :**
- Avoir le SDK Flutter installé et configuré (exécutez `flutter doctor` pour vérifier)

### Android (APK / App Bundle)

**Prérequis :**
- Android SDK et Android Studio (installe Java/Gradle)
- Un device ou un émulateur configuré

**Commandes de compilation :**

```powershell
# APK release (tous les ABIs)
flutter build apk --release

# APKs séparés par ABI (réduit la taille)
flutter build apk --split-per-abi --release

# Android App Bundle (AAB) pour le Play Store
flutter build appbundle --release
```

**Signature :** Pour créer un APK signé, configurez un keystore et la section `signingConfigs` dans `android/app/build.gradle`. Placez vos informations de keystore dans `android/key.properties`.

### Windows (EXE)

**Prérequis :**
- Machine Windows avec Visual Studio (Desktop development with C++) installé
- Support desktop activé :

```powershell
flutter config --enable-windows-desktop
flutter doctor
```

**Commande de build :**

```powershell
flutter build windows --release
```

L'exécutable généré se trouve dans : `build\windows\x64\runner\Release\`

**Recommandations :**
- Testez d'abord en mode `debug`, puis en `profile`/`release`
- Sur Android, vérifiez les permissions et la configuration du `AndroidManifest.xml` avant publication
- Sur Windows, vérifiez les dépendances runtime (VC++ redistribuables) si vous distribuez l'exécutable


## Structure Détaillée de l'Application

Le projet suit une architecture **feature-first**, où chaque fonctionnalité est organisée dans son propre dossier.

```
lib/
├── features/                             # Organisation par fonctionnalités
│   ├── 00_app/                           # Configuration de l'application
│   │   ├── main.dart                     # Point d'entrée (initialisation Hive, providers)
│   │   └── providers/                    # Providers globaux
│   │       ├── portfolio_provider.dart   # Gestion d'état du portefeuille
│   │       └── settings_provider.dart    # Gestion des paramètres (couleur, etc.)
│   │
│   ├── 01_launch/                        # Écran de lancement
│   │   └── ui/
│   │       └── launch_screen.dart        # Onboarding (démo ou portefeuille vide)
│   │
│   ├── 02_dashboard/                     # Écran principal
│   │   └── ui/
│   │       └── dashboard_screen.dart     # Vue d'ensemble avec onglets
│   │
│   ├── 03_overview/                      # Vue d'ensemble détaillée
│   │   └── ui/
│   │       └── overview_tab.dart         # Rapports et synthèse
│   │
│   ├── 04_correction/                    # Correction manuelle des données
│   │   └── ui/
│   │       └── correction_tab.dart       # Formulaires de correction
│   │
│   ├── 05_planner/                       # Planification financière
│   │   └── ui/
│   │       └── planner_tab.dart          # Simulateur d'investissements
│   │
│   ├── 06_settings/                      # Paramètres de l'application
│   │   └── ui/
│   │       ├── settings_screen.dart      # Écran principal des paramètres
│   │       └── widgets/                  # Composants de paramètres
│   │           ├── appearance_settings.dart
│   │           ├── app_settings.dart
│   │           ├── portfolio_management_settings.dart
│   │           └── reset_app_section.dart
│   │
│   └── 07_management/                    # Gestion des entités
│       └── ui/
│           └── screens/                  # Écrans de gestion
│               ├── add_institution_screen.dart
│               ├── add_account_screen.dart
│               └── add_asset_screen.dart
│
├── core/                                 # Fondations de l'application
│   ├── data/                             # Couche données
│   │   ├── models/                       # Modèles Hive avec génération de code
│   │   │   ├── portfolio.dart            # Portefeuille principal
│   │   │   ├── institution.dart          # Institution financière
│   │   │   ├── account.dart              # Compte d'investissement
│   │   │   ├── asset.dart                # Actif/Position
│   │   │   ├── account_type.dart         # Enum des types de comptes
│   │   │   ├── savings_plan.dart         # Plans d'épargne
│   │   │   └── *.g.dart                  # Fichiers générés par Hive
│   │   ├── repositories/                 # Logique d'accès aux données
│   │   │   └── portfolio_repository.dart # Repository principal
│   │   └── services/                     # Services externes
│   │       └── api_service.dart          # Service de récupération des prix (FMP, Yahoo)
│   │
│   ├── ui/                               # Composants UI partagés
│   │   ├── splash_screen.dart            # Écran de démarrage
│   │   └── theme/
│   │       └── app_theme.dart            # Thème et styles
│   │
│   └── utils/                            # Utilitaires
│       ├── constants.dart                # Constantes globales
│       └── currency_formatter.dart       # Formatage des montants

android/                                  # Configuration Android (Gradle, manifest)
ios/                                      # Configuration iOS (Xcode)
windows/                                  # Configuration Windows (CMake)
linux/                                    # Configuration Linux
macos/                                    # Configuration macOS

pubspec.yaml                              # Dépendances et assets
analysis_options.yaml                     # Configuration Dart analyzer
```

### Description des Principaux Éléments

- **`lib/features/00_app/main.dart`** : Initialise Hive, enregistre les adapters TypeId (Portfolio, Institution, Account, Asset, AccountType), ouvre les boxes et démarre l'application avec les providers

- **`lib/core/data/models/`** : Contient les modèles métiers annotés avec `@HiveType` et `@HiveField`. Toute modification nécessite de relancer `build_runner` pour regénérer les fichiers `.g.dart`

- **`lib/core/data/repositories/`** : Encapsule la logique d'accès et d'écriture des données, abstrayant le stockage Hive du reste de l'application

- **`lib/features/00_app/providers/`** : Providers (ChangeNotifier) qui gèrent l'état global :
  - `PortfolioProvider` : Opérations CRUD sur les portefeuilles, institutions, comptes et actifs + synchronisation des prix en ligne
  - `SettingsProvider` : Gestion des préférences utilisateur (couleur de thème, mode en ligne, clé API FMP, etc.)

- **`lib/core/data/services/api_service.dart`** : Service centralisé pour les appels réseau (FMP, Yahoo Finance) avec cache intelligent et gestion des fallbacks

- **`lib/features/07_management/`** : Écrans dédiés à l'ajout et la modification d'institutions, comptes et actifs avec formulaires validés

### Navigation dans le Code

1. **Point d'entrée** : Commencez par `lib/features/00_app/main.dart` pour comprendre l'initialisation
2. **Modèles de données** : Consultez `lib/core/data/models/` pour la structure des données
3. **Logique métier** : Recherchez `PortfolioRepository` et `PortfolioProvider` pour les opérations principales
4. **Interface utilisateur** : Explorez `lib/features/02_dashboard/` pour l'écran principal et naviguez dans les autres features selon vos besoins


## Dépendances Importantes

### Dépendances de Production

- **`provider`** (^6.1.2) : Gestion d'état réactive et injection de dépendances
- **`hive`** (^2.2.3) : Base de données NoSQL légère et rapide pour le stockage local
- **`hive_flutter`** (^1.1.0) : Intégration de Hive avec Flutter
- **`fl_chart`** (^1.1.1) : Bibliothèque de graphiques interactifs pour les visualisations financières
- **`intl`** (^0.19.0) : Internationalisation et formatage (dates, devises)
- **`uuid`** (^4.4.0) : Génération d'identifiants uniques pour les entités
- **`shimmer`** (^3.0.0) : Effets de chargement élégants
- **`animated_text_kit`** (^4.2.2) : Animations de texte pour l'interface
- **`http`** (^1.2.1) : Client HTTP pour les appels API
- **`flutter_secure_storage`** (^9.1.1) : Stockage sécurisé pour les clés API (Keystore/Keychain)

### Dépendances de Développement

- **`hive_generator`** (^2.0.1) : Génération de code pour les adapters Hive
- **`build_runner`** (^2.4.9) : Outil de génération de code
- **`flutter_lints`** (^5.0.0) : Règles de lint recommandées pour Flutter

Consultez `pubspec.yaml` pour la liste complète et les versions exactes.

## Conseils et Bonnes Pratiques

### Développement

- **Persistance des données** : Le `Hive.deleteFromDisk()` est désormais commenté en mode debug pour permettre de tester la persistance des données entre les relances
- **Génération de code** : Après toute modification des modèles annotés avec `@HiveType`, relancez :
  ```powershell
  flutter pub run build_runner build --delete-conflicting-outputs
  ```
- **Adapters Hive** : Vérifiez que tous les TypeId sont uniques et que les adapters sont bien enregistrés dans `main.dart`
- **Multi-portefeuilles** : L'application supporte désormais plusieurs portefeuilles simultanés avec des identifiants UUID uniques

### Performance

- Utilisez `flutter run --profile` pour tester les performances réelles
- Les graphiques fl_chart peuvent être gourmands : limitez les points de données si nécessaire
- Hive est optimisé pour les lectures fréquentes, évitez les écritures massives en boucle

### Tests

- Testez d'abord en mode debug : `flutter run`
- Validez en mode profile : `flutter run --profile`
- Compilez en release pour distribution : `flutter build <platform> --release`

### Production

- Configurez correctement la signature Android (keystore) avant publication
- Vérifiez les permissions dans `AndroidManifest.xml`
- Sur Windows, incluez les redistributables Visual C++ si nécessaire
- Activez les analytics/crash reporting pour suivre les erreurs en production

## Contribuer

Les contributions sont les bienvenues ! Pour contribuer :

1. Forkez le projet
2. Créez une branche pour votre fonctionnalité (`git checkout -b feature/AmazingFeature`)
3. Commitez vos changements (`git commit -m 'Add some AmazingFeature'`)
4. Pushez vers la branche (`git push origin feature/AmazingFeature`)
5. Ouvrez une Pull Request

### Guidelines

- Respectez l'architecture feature-first existante
- Ajoutez des commentaires pour les logiques complexes
- Testez vos modifications sur plusieurs plateformes si possible
- Mettez à jour la documentation si nécessaire

---

## Licence

Ce projet est un projet personnel. Consultez le fichier LICENSE pour plus d'informations.

## Contact

Pour toute question ou suggestion, n'hésitez pas à ouvrir une issue sur le dépôt.

---

**Dernière mise à jour** : Novembre 2025
