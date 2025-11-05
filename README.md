# Portefeuille  gestionnaire de finances personnelles (Flutter)

Une application Flutter pour agréger et analyser vos comptes et investissements (banques, courtiers, cryptos).

## Résumé

- Langage : Dart / Flutter
- Point d'entrée : `lib/features/00_app/main.dart`
- Stockage local : Hive
- Principales dépendances : provider, hive, hive_flutter, fl_chart, intl

## Prérequis

- Flutter SDK (compatible avec Dart >=3.4.0). Installez depuis https://flutter.dev
- Un appareil ou émulateur (Android / iOS / Windows / macOS / Linux). Utilisez par exemple :

```powershell
flutter run -d <device>
```

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

- Le point d'entrée est `lib/features/00_app/main.dart`. Le `main` initialise Hive, enregistre les adapters et ouvre la box principale avant d'instancier le repository.
- En mode debug, le code appelle `Hive.deleteFromDisk()` (voir `main.dart`), ce qui supprime les données locales à chaque exécution  pratique pour le développement mais à désactiver en production.
- Pour générer ou regénérer les fichiers `.g.dart` liés à Hive, utilisez `build_runner` (commande ci-dessus).

## Compilation  APK (Android) et EXE (Windows)

Voici les commandes et prérequis pour compiler des binaires pour Android (APK / AAB) et Windows (EXE).

Pré-requis généraux :
- Avoir le SDK Flutter installé et configuré (exécutez `flutter doctor` pour vérifier).

### Android (APK / App Bundle)

- Pré-requis : Android SDK et Android Studio (installe Java/Gradle), un device ou un émulateur.
- Commande (APK release) :

```powershell
flutter build apk --release
```

- Pour générer des APKs séparés par ABI (réduit la taille) :

```powershell
flutter build apk --split-per-abi --release
```

- Pour générer un Android App Bundle (AAB) destiné au Play Store :

```powershell
flutter build appbundle --release
```

- Signature : pour créer un APK signé, configurez un keystore et la section `signingConfigs` dans `android/app/build.gradle`. Placez vos informations de keystore dans `android/key.properties` puis build.

### Windows (EXE)

- Pré-requis : machine Windows avec Visual Studio (Desktop development with C++) installé. Activez le support desktop si nécessaire :

```powershell
flutter config --enable-windows-desktop
flutter doctor
```

- Commande de build :

```powershell
flutter build windows --release
```

- L'exécutable généré se trouve typiquement dans :

```
build\windows\runner\Release\
```

Recommandations :
- Testez d'abord en mode `debug`, puis en `profile`/`release`.
- Sur Android, vérifiez les permissions et la configuration du `android/app/src/main/AndroidManifest.xml` avant publication.
- Sur Windows, vérifiez les dépendances runtime (VC++ redistribuables) si vous distribuez l'exécutable.


## Structure détaillée de l'application

Ci-dessous une arborescence commentée des dossiers et fichiers les plus importants. Elle reflète l'organisation actuelle du projet et aide à localiser la logique, les modèles et l'UI.

```
lib/
├── features/
│   ├── 00_app/
│   │   ├── main.dart                    # Point d'entrée de l'application (initialisation Hive, providers)
│   │   ├── providers/                    # Providers (ChangeNotifier) utilisés globalement
│   │   └── ...                           # Autres fichiers liés à l'initialisation
│   ├── 01_launch/                        # Écran(s) de lancement / onboarding
│   ├── 02_dashboard/                     # Écran principal : dashboard et ses composants
│   │   └── ui/                           # UI spécifiques au dashboard
│   ├── 03_overview/                      # Fonctionnalité "Overview" (rapports, synthèse)
│   ├── 04_correction/                    # Outils de correction / import manuel
│   ├── 05_planner/                       # Planification / simulateur
│   └── 06_settings/                      # Écran de paramètres

├── core/
│   ├── data/
│   │   ├── models/                       # Modèles persistés (Hive adapters .dart + .g.dart)
│   │   │   ├── portfolio.dart
│   │   │   ├── institution.dart
│   │   │   ├── account.dart
│   │   │   ├── asset.dart
│   │   │   └── account_type.dart
│   │   └── repositories/                 # Accès aux données et logique de persistence (PortfolioRepository...)
│   ├── ui/
│   │   ├── splash_screen.dart           # Splash / routage initial
│   │   └── theme/                        # Thème, styles (ex: app_theme.dart)
│   └── utils/                            # Constantes, formatters, helpers (currency_formatter, constants)

├── widgets/                              # Widgets réutilisables (charts, lists, cards)
│   ├── analysis/
│   ├── charts/
│   └── portfolio/

└── main.dart (historique)                # Note : le vrai point d'entrée dans ce projet est `lib/features/00_app/main.dart`

android/                                  # Code et configuration Android (Gradle, keystore, manifest)
ios/                                      # Projet iOS (Xcode workspace, Info.plist)
windows/                                  # Projet Windows (CMake, runner)
linux/                                    # Projet Linux (si présent)
macos/                                    # Projet macOS (si présent)

pubspec.yaml                              # Dépendances et assets
build/                                    # Artefacts de build (générés)

```

Description rapide des principaux éléments
- `lib/features/00_app/main.dart` : initialise Hive, enregistre les adapters, ouvre la box principale et instancie le `PortfolioRepository`, puis démarre `MyApp` avec les providers.
- `lib/core/data/models/` : contient les modèles métiers persistés (avec leurs fichiers générés `.g.dart` par Hive). Toute modification de ces classes nécessite de relancer `build_runner`.
- `lib/core/data/repositories/` : encapsule la logique d'accès/écriture des données (abstraction du stockage Hive).
- `lib/core/ui/` : composants UI partagés (thème, splash screen, widgets réutilisables).
- `lib/features/*` : chaque dossier `features/XX_name` contient la logique UI et les widgets spécifiques à une fonctionnalité (dashboard, overview, planner...).

Conseils pour naviguer dans le code
- Cherchez le point d'entrée avec `main.dart` sous `lib/features/00_app/` pour comprendre l'ordre d'initialisation.
- Utilisez la recherche sur les types principaux (`Portfolio`, `PortfolioRepository`, `PortfolioProvider`) pour tracer la logique métier et les mises à jour de l'UI.
- Les modèles Hive ont des adapters enregistrés dans `main.dart` — vérifiez la présence des `.g.dart` générés lors d'erreurs de sérialisation.

Si vous voulez, je peux :
- Générer une arborescence plus complète (tous les fichiers présents) ;
- Ajouter un diagramme simple (mermaid) montrant les relations Portfolio -> Institution -> Account -> Asset ;
- Créer un fichier `DEVELOPMENT.md` séparé avec commandes utiles (build, test, codegen, debug).


## Dépendances importantes

- `provider`  gestion d'état
- `hive`, `hive_flutter`  stockage local
- `hive_generator`, `build_runner`  génération de code pour Hive (dev_dependencies)
- `fl_chart`  graphiques
- `intl`  formatage des montants

Consultez `pubspec.yaml` pour la liste complète et versions.

## Conseils et bonnes pratiques

- Désactivez la suppression automatique de la base Hive (appel `Hive.deleteFromDisk()` en debug) si vous voulez conserver des données entre relances.
- Ajoutez/validez les adapters Hive dès que vous modifiez un modèle pour éviter des erreurs de sérialisation.

## Contribuer

Soumettez des PRs sur la branche principale du dépôt (voir le workflow du projet). Incluez des tests pour la logique métier si possible.

---

Si vous souhaitez que j'ajoute des sections supplémentaires au README (ex. capture d'écran, diagramme de l'architecture, commandes CI, ou instructions pour Windows/macOS spécifiques), dites-le et je l'ajouterai.
