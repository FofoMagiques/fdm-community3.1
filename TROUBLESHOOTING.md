# 🚨 Guide de Dépannage - FDM Community

## Problèmes Résolus ✅

### 1. ❌ "Cannot GET /admin" - RÉSOLU
**Problème :** Le panneau admin n'était pas accessible
**Solution :** Ajout des routes manquantes dans server.js
```javascript
app.get('/admin', (req, res) => {
    res.sendFile(path.join(__dirname, 'admin.html'));
});
```

### 2. ❌ CSS et JS ne se chargent pas - RÉSOLU
**Problème :** Les fichiers style.css et script.js n'étaient pas servis
**Solution :** Correction du chemin des fichiers statiques
```javascript
// Avant (incorrect):
app.use(express.static(path.join(__dirname, 'frontend')));

// Après (correct):
app.use(express.static(path.join(__dirname)));
```

### 3. ❌ Docker qui plante - RÉSOLU
**Problème :** Le Dockerfile cherchait un dossier 'frontend' inexistant
**Solution :** Correction du Dockerfile et docker-compose.yml

## Scripts de Réparation 🔧

### Démarrage Normal
```bash
chmod +x start.sh
./start.sh
```

### Test Complet
```bash
chmod +x test-site.sh
./test-site.sh
```

### Réparation Docker
```bash
chmod +x fix-docker.sh
./fix-docker.sh
```

## Vérification Rapide 🚀

1. **Le serveur fonctionne-t-il ?**
   ```bash
   curl http://localhost:3001
   ```

2. **Les fichiers CSS/JS sont-ils accessibles ?**
   ```bash
   curl http://localhost:3001/style.css
   curl http://localhost:3001/script.js
   ```

3. **Le panel admin est-il accessible ?**
   ```bash
   curl http://localhost:3001/admin
   ```

4. **L'API fonctionne-t-elle ?**
   ```bash
   curl http://localhost:3001/api/events
   ```

## Structure Correcte du Projet 📁

```
fdm-community/
├── server.js          # ✅ Serveur principal
├── index.html         # ✅ Page d'accueil
├── admin.html         # ✅ Panel admin
├── config.html        # ✅ Configuration
├── style.css          # ✅ Styles CSS
├── script.js          # ✅ JavaScript
├── package.json       # ✅ Dépendances
├── Dockerfile         # ✅ Configuration Docker
├── docker-compose.yml # ✅ Services Docker
├── .env              # ✅ Variables d'environnement
└── data/             # ✅ Base de données
```

## Commandes Utiles 🛠️

### Démarrage
```bash
# Démarrage normal
node server.js

# Démarrage avec Docker
docker compose up -d

# Démarrage avec script
./start.sh
```

### Debug
```bash
# Voir les logs
tail -f server.log

# Voir les logs Docker
docker compose logs -f

# Tester les connexions
./test-site.sh
```

### Arrêt
```bash
# Arrêter le serveur Node
pkill -f "node server.js"

# Arrêter Docker
docker compose down
```

## Problèmes Potentiels et Solutions 🔍

### Problème : Port 3001 déjà utilisé
**Solution :**
```bash
# Trouver le processus
lsof -i :3001

# Arrêter le processus
kill -9 <PID>
```

### Problème : Base de données corrompue
**Solution :**
```bash
# Supprimer la base de données
rm -f data/fdm_database.db fdm_database.db

# Redémarrer le serveur (recréera la DB)
./start.sh
```

### Problème : Dépendances manquantes
**Solution :**
```bash
# Réinstaller les dépendances
rm -rf node_modules package-lock.json
npm install
```

### Problème : Token Discord invalide
**Solution :**
1. Vérifier le token dans `.env`
2. Renouveler le token sur Discord Developer Portal
3. Redémarrer le serveur

## URLs Importantes 🔗

- **Site principal :** http://localhost:3001
- **Panel admin :** http://localhost:3001/admin
- **Configuration :** http://localhost:3001/config
- **API Événements :** http://localhost:3001/api/events
- **API Discord :** http://localhost:3001/api/discord/stats

## Support 💬

Si vous rencontrez encore des problèmes :

1. **Vérifiez les logs** : `tail -f server.log`
2. **Lancez le test** : `./test-site.sh`
3. **Vérifiez la config** : `.env`
4. **Redémarrez tout** : `./start.sh`

---

*Tous les problèmes mentionnés ont été résolus ! 🎉*