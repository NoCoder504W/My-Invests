# 🌐 Guide de Déploiement Web sur GitHub Pages

Ce guide vous accompagne pour déployer votre application Portefeuille sur GitHub Pages et y accéder depuis votre iPhone.

## ✅ Ce qui a été fait automatiquement

Les fichiers suivants ont été créés/modifiés pour vous :

1. **`.github/workflows/deploy-web.yml`** : Workflow de déploiement automatique
2. **`web/index.html`** : Optimisé pour mobile (viewport, méta-tags iOS)
3. **`web/manifest.json`** : Configuration PWA améliorée
4. **`web/.nojekyll`** : Désactivation de Jekyll pour GitHub Pages
5. **`README.md`** : Documentation mise à jour avec section Web

## 🚀 Étapes de Déploiement

### Étape 1 : Pousser les Modifications sur GitHub

Ouvrez PowerShell dans le dossier du projet et exécutez :

```powershell
# Ajouter tous les fichiers modifiés
git add .

# Créer un commit
git commit -m "feat: ajout déploiement web automatique sur GitHub Pages"

# Pousser vers GitHub
git push origin master
```

### Étape 2 : Activer GitHub Pages

1. Allez sur votre dépôt GitHub : [https://github.com/kireg/portefeuille](https://github.com/kireg/portefeuille)
2. Cliquez sur **Settings** (⚙️ en haut à droite)
3. Dans le menu de gauche, cliquez sur **Pages**
4. Dans la section **Source** :
   - **Branch** : Sélectionnez `gh-pages`
   - **Folder** : Laissez `/ (root)`
5. Cliquez sur **Save**

**Note** : La branche `gh-pages` sera créée automatiquement lors du premier déploiement (après le push de l'étape 1).

### Étape 3 : Vérifier le Déploiement

1. Allez dans l'onglet **Actions** de votre dépôt GitHub
2. Vous devriez voir le workflow **"Déploiement Web sur GitHub Pages"** en cours d'exécution
3. Attendez que le workflow se termine (icône verte ✅)
4. Le déploiement prend environ **2-3 minutes**

### Étape 4 : Accéder à l'Application

Une fois le déploiement terminé :

**URL de l'application** : [https://kireg.github.io/portefeuille/](https://kireg.github.io/portefeuille/)

## 📱 Utiliser l'Application sur iPhone

### Méthode 1 : Navigateur Safari

1. Ouvrez **Safari** sur votre iPhone
2. Tapez l'URL : `https://kireg.github.io/portefeuille/`
3. L'application se charge comme un site web

### Méthode 2 : Ajouter à l'Écran d'Accueil (Mode App)

Pour une expérience similaire à une application native :

1. Ouvrez l'application dans **Safari**
2. Appuyez sur le bouton **Partager** (icône ↑ en bas de l'écran)
3. Faites défiler et sélectionnez **"Sur l'écran d'accueil"**
4. Personnalisez le nom si souhaité : "Portefeuille"
5. Appuyez sur **Ajouter**

**Résultat** : Une icône apparaît sur votre écran d'accueil. En appuyant dessus, l'application s'ouvre en plein écran sans les barres de navigation Safari.

## 🔄 Déploiements Futurs

Désormais, **chaque fois que vous pousserez du code sur la branche `master`**, l'application web sera automatiquement recompilée et redéployée sur GitHub Pages.

```powershell
# Faire des modifications dans le code
# ...

# Commit et push
git add .
git commit -m "fix: correction d'un bug"
git push origin master

# 🎉 Le déploiement se déclenche automatiquement !
```

## 🧪 Tester Localement Avant de Déployer

Pour tester le build web en local avant de pousser :

```powershell
# Build de l'application web
flutter build web --release --base-href "/portefeuille/"

# Lancer un serveur local (Python requis)
cd build\web
python -m http.server 8080

# Ouvrir dans le navigateur : http://localhost:8080
```

## 🛠️ Déploiement Manuel (si besoin)

Si vous souhaitez déclencher un déploiement manuellement sans faire de push :

1. Allez sur GitHub > **Actions**
2. Sélectionnez le workflow **"Déploiement Web sur GitHub Pages"**
3. Cliquez sur **Run workflow** > **Run workflow**

## ⚠️ Points Importants à Retenir

### Stockage des Données

- Les données sont stockées **dans le navigateur** (IndexedDB)
- **Chaque navigateur/appareil** a ses propres données (pas de synchronisation)
- Si vous videz le cache du navigateur, **les données sont perdues**

### Mode Hors Ligne

- L'application fonctionne parfaitement **sans mode en ligne**
- Les prix ne se synchroniseront pas automatiquement (saisie manuelle)
- Vous pouvez activer le mode en ligne dans les paramètres si nécessaire

### Sécurité

- **Ne stockez pas de clé API** sensible dans le code si vous prévoyez d'utiliser le mode en ligne
- La clé sera visible dans le code source publié sur GitHub Pages
- Pour l'instant, le mode hors ligne est recommandé

## 🔍 Dépannage

### Le déploiement échoue

1. Vérifiez les logs dans **Actions** sur GitHub
2. Assurez-vous que le workflow a les permissions nécessaires (c'est déjà configuré)

### L'application ne se charge pas

1. Vérifiez que GitHub Pages est bien activé sur la branche `gh-pages`
2. Attendez 2-3 minutes après le premier déploiement
3. Essayez de vider le cache du navigateur (Ctrl+F5)

### L'application affiche "404 Not Found"

1. Vérifiez que l'URL est correcte : `https://kireg.github.io/portefeuille/` (avec `/` à la fin)
2. Vérifiez que le `--base-href` dans le workflow est `/portefeuille/`

### Les données disparaissent

- C'est normal si vous videz le cache du navigateur
- Les données sont propres à chaque navigateur
- Pensez à exporter vos données régulièrement (fonctionnalité future)

## 📞 Support

Si vous rencontrez des problèmes :

1. Consultez les **logs du workflow** dans l'onglet Actions
2. Vérifiez la console du navigateur (F12 > Console) pour les erreurs JavaScript
3. Relisez ce guide étape par étape

---

**Bon déploiement ! 🚀**
