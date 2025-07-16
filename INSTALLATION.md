# 🔧 Installation FDM Community sur NAS Synology DS218+

## 📋 Étapes d'installation

### 1. Préparation du NAS
```bash
# Connexion SSH à votre NAS
ssh Fofo@teamfdm

# Aller dans le dossier web
cd /volume1/web/FDM
```

### 2. Installation des dépendances Node.js
```bash
# Installer les dépendances
npm install --production

# Ou avec yarn si préféré
yarn install --production
```

### 3. Configuration
```bash
# Vérifier le fichier .env
cat .env

# Doit contenir :
# DISCORD_TOKEN=MTM5MzQwNjQwNjg2NTk3NzQ3Nw.GVXMXj.apuAo9qscEnDI2G_5XoRpc1oEiGN6jygSb7LQ4
# DISCORD_GUILD_ID=681602280893579342
# ADMIN_PASSWORD=fdm2024admin
# PORT=3001
```

### 4. Démarrage du serveur
```bash
# Méthode 1 : Script de démarrage simple
./start_fdm.sh

# Méthode 2 : Système de monitoring (recommandé)
./monitor_fdm.sh start
```

### 5. Vérification
```bash
# Vérifier le statut
./monitor_fdm.sh status

# Vérifier les logs
tail -f server.log
```

## 🌐 Accès aux interfaces

Une fois le serveur démarré, vous pouvez accéder à :

- **Site principal** : http://teamfdm:3001
- **Panel admin** : http://teamfdm:3001/admin.html
- **Configuration** : http://teamfdm:3001/config.html

## 🤖 Automatisation

### Démarrage automatique au boot
```bash
# Ajouter au crontab
crontab -e

# Ajouter cette ligne :
@reboot /volume1/web/FDM/monitor_fdm.sh start

# Surveillance automatique (toutes les 5 minutes)
*/5 * * * * /volume1/web/FDM/monitor_fdm.sh monitor
```

### Maintenance automatique
```bash
# Redémarrage quotidien à 4h du matin
0 4 * * * /volume1/web/FDM/monitor_fdm.sh restart

# Nettoyage des logs anciens
0 2 * * 0 find /volume1/web/FDM -name "*.log" -type f -mtime +7 -delete
```

## 🔧 Administration

### Commandes utiles
```bash
# Démarrer le serveur
./monitor_fdm.sh start

# Arrêter le serveur
./monitor_fdm.sh stop

# Redémarrer le serveur
./monitor_fdm.sh restart

# Vérifier le statut
./monitor_fdm.sh status

# Mise à jour
./update_fdm.sh
```

### Logs
```bash
# Logs du serveur
tail -f server.log

# Logs de monitoring
tail -f monitor.log

# Logs en temps réel
./monitor_fdm.sh status
```

## 🗄️ Base de données

### Sauvegarde
```bash
# Sauvegarde manuelle
cp fdm_database.db backup_$(date +%Y%m%d_%H%M%S).db

# Sauvegarde automatique (incluse dans update_fdm.sh)
./update_fdm.sh
```

### Restauration
```bash
# Arrêter le serveur
./monitor_fdm.sh stop

# Restaurer la base
cp backup_YYYYMMDD_HHMMSS.db fdm_database.db

# Redémarrer
./monitor_fdm.sh start
```

## 🎮 Utilisation

### Panel Admin
1. Aller sur : http://teamfdm:3001/admin.html
2. Mot de passe : `fdm2024admin`
3. Gérer les événements, voir les téléchargements

### Stats Discord
- Mises à jour automatiques toutes les 2 minutes
- Affichage en temps réel sur la page d'accueil

### Événements
- Création/modification via le panel admin
- Participation enregistrée en base de données
- Système de téléchargement avec tracking

## 🔒 Sécurité

### Changement du mot de passe admin
```bash
# Modifier dans .env
ADMIN_PASSWORD=nouveau_mot_de_passe

# Redémarrer le serveur
./monitor_fdm.sh restart
```

### Permissions
```bash
# Vérifier les permissions des fichiers
ls -la *.sh

# Rendre exécutable si nécessaire
chmod +x *.sh
```

## 🚨 Dépannage

### Problèmes courants

#### Port déjà utilisé
```bash
# Vérifier quel processus utilise le port
lsof -i :3001

# Tuer le processus
kill -9 PID

# Ou changer le port dans .env
PORT=3002
```

#### Bot Discord non connecté
```bash
# Vérifier les logs
tail -f server.log

# Vérifier le token et l'ID du serveur dans .env
# Redémarrer le serveur
./monitor_fdm.sh restart
```

#### Base de données corrompue
```bash
# Restaurer depuis une sauvegarde
./monitor_fdm.sh stop
cp backups/fdm_database_YYYYMMDD_HHMMSS.db fdm_database.db
./monitor_fdm.sh start
```

## 📊 Monitoring

### Vérification de santé
```bash
# Test API
curl http://localhost:3001/api/discord/stats

# Test événements
curl http://localhost:3001/api/events
```

### Surveillance des ressources
```bash
# Utilisation mémoire
ps aux | grep "node server.js"

# Utilisation disque
du -sh /volume1/web/FDM
```

---

**Support** : En cas de problème, vérifiez les logs et le statut du serveur avec `./monitor_fdm.sh status`