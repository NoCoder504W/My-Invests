# Portefeuille - Application de Suivi Financier

Ce projet vise à créer une application mobile pour le suivi de portefeuille financier, en se basant sur une architecture Flutter moderne et maintenable.

## État d'Avancement (au 28/05/2024)

La structure de base de l'application est en place, incluant les modèles de données, la gestion d'état et le squelette de l'interface utilisateur. Le projet est maintenant prêt pour l'implémentation des fonctionnalités dynamiques.

### Ce qui est terminé (Fondations Techniques) :

- **Squelette de l'Interface Utilisateur (UI) :** Les écrans principaux ont été implémentés de manière statique (Welcome, Dashboard, Overview, Planner, Correction, Settings) et affichent des données d'exemple.
- **Modèles de Données (`models`) :** La structure des données (`Portfolio`, `Account`, `Asset`, etc.) est définie, préparant l'application à gérer les informations du portefeuille.
- **Gestion d'État (`providers`) :** Le socle de gestion d'état est configuré avec `Provider` pour une architecture réactive.
- **Thème Visuel (`utils`) :** Le thème global de l'application (Dark Mode, couleurs, typographie) est implémenté et centralisé.
- **Données de Test :** Une fonctionnalité de chargement de portefeuille de démonstration est disponible pour les tests et le développement de l'UI.

### Problèmes Techniques Résolus :

- **Configuration de l'Environnement de Build :** Correction des problèmes de compatibilité entre Flutter et l'environnement de développement Windows (Visual Studio).
- **Résolution des Dépendances :** Ajout et configuration des librairies externes nécessaires au projet (`provider`, `fl_chart`).
- **Correction du Code Initial :** Révision et correction des erreurs de syntaxe, des chemins d'importation et des configurations de thème dans le code de base.

## Prochaines Étapes (Implémentation des Fonctionnalités)

Voici la liste des tâches à accomplir pour rendre l'application fonctionnelle. Vous pouvez demander à démarrer une tâche en utilisant son numéro.

- **1. Persistance des Données**
  - **Objectif :** Implémenter le stockage local pour que les données de l'utilisateur soient conservées entre les sessions.

- **2. Implémentation de la Logique UI**
  - **Objectif :** Rendre l'interface utilisateur dynamique et interactive.
  - **Tâches :**
    - **2.1.** Activer l'onglet **"Correction"** pour permettre la modification des données du portefeuille.
    - **2.2.** Connecter les **graphiques** aux données réelles du `PortfolioProvider`.
    - **2.3.** Développer la logique de l'onglet **"Planificateur"** (création/gestion des plans).

- **3. Intégration des Services Externes**
  - **Objectif :** Connecter l'application à des API externes.
  - **Tâches :**
    - **3.1.** Implémenter l'appel à l'API Google Gemini pour la fonctionnalité d'**Analyse IA**.
    - **3.2.** (Optionnel) Intégrer une API financière pour la **mise à jour automatique des prix**.

- **4. Amélioration de l'Expérience Utilisateur (UX)**
  - **Objectif :** Finaliser le parcours utilisateur et ajouter des fonctionnalités de confort.
  - **Tâches :**
    - **4.1.** Implémenter le flux de **création d'un nouveau portefeuille**.
    - **4.2.** Implémenter la logique d'affichage des **bulles d'aide** (Tooltips) en fonction du niveau de l'utilisateur.

---
*Note : À la fin de chaque modification, une proposition de message de commit pour GitHub sera fournie en français.*
