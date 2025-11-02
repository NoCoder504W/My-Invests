# Portefeuille - Application de Suivi Financier

Ce projet vise à créer une application mobile pour le suivi de portefeuille financier. L'objectif est de proposer une application simple, complète et agréable à utiliser.

## État d'Avancement (au 28/05/2024)

Les fondations de l'application sont posées. C'est comme avoir les plans et le gros œuvre d'une maison, mais sans encore avoir aménagé l'intérieur ni branché l'électricité.

### Ce qui est terminé (Les Fondations) :

- **Maquettes des Écrans :** Tous les écrans principaux ont été créés et sont visibles (Bienvenue, Tableau de bord, Vue d'ensemble, Planificateur, Correction, Paramètres). Pour l'instant, ils affichent des données d'exemple.
- **Définition des Données :** L'application sait ce que sont un "Portefeuille", un "Compte" ou un "Actif". La structure est prête à accueillir de vraies informations.
- **Thème Visuel :** L'identité visuelle de l'application (thème sombre, couleurs, style des cartes) est définie et appliquée.
- **Portefeuille de Démonstration :** Il est possible de charger un portefeuille d'exemple pour avoir un aperçu de l'application remplie.

### Problèmes Techniques Résolus :

Durant la mise en place initiale, nous avons rencontré et résolu plusieurs problèmes techniques :

- **Compatibilité Windows :** Un souci qui empêchait l'application de démarrer sur Windows a été corrigé.
- **Installation d'Outils :** Des "briques logicielles" externes nécessaires au projet manquaient ; elles ont été ajoutées.
- **Nettoyage du Code Initial :** Plusieurs erreurs de frappe et bugs mineurs dans le code de base ont été résolus pour assurer une fondation stable.

## Prochaines Étapes (Les Fonctionnalités à Construire)

Maintenant que les bases sont saines, voici la liste des fonctionnalités à développer. Vous pouvez demander à démarrer une tâche en utilisant son numéro.

- **1. Sauvegarder les Données**
  - **Objectif :** Faire en sorte que l'application se souvienne du portefeuille de l'utilisateur, même après avoir fermé et rouvert l'application.

- **2. Rendre les Écrans Interactifs**
  - **Objectif :** Connecter les boutons et les formulaires à la logique de l'application pour qu'ils fonctionnent pour de vrai.
  - **Tâches :**
    - **2.1.** Activer l'onglet **"Correction"** pour permettre de modifier les quantités et les prix des actifs.
    - **2.2.** Relier les **graphiques** aux vraies données du portefeuille pour qu'ils reflètent la situation de l'utilisateur.
    - **2.3.** Faire fonctionner l'onglet **"Planificateur"** pour créer et gérer des plans d'investissement.

- **3. Connecter l'Application à Internet**
  - **Objectif :** Permettre à l'application de communiquer avec des services externes.
  - **Tâches :**
    - **3.1.** Activer l'**Analyse par IA** pour envoyer les données du portefeuille à l'IA de Google et afficher un résultat pertinent.
    - **3.2.** (Optionnel) Créer un système pour **mettre à jour automatiquement le prix** des actifs.

- **4. Finaliser l'Expérience Utilisateur**
  - **Objectif :** Polir l'application pour qu'elle soit facile et agréable à utiliser de A à Z.
  - **Tâches :**
    - **4.1.** Permettre à un nouvel utilisateur de **créer son propre portefeuille** à partir d'un écran vide.
    - **4.2.** Activer ou désactiver les **bulles d'aide** selon le niveau de confort de l'utilisateur (Novice/Expert).
