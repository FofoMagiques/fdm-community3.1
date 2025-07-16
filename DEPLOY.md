# 🚀 Guide de Déploiement FDM Community

## 📋 Prérequis

### Sur votre NAS Synology
- Docker installé via Package Center
- SSH activé
- Accès administrateur

### Discord
- Bot Discord créé
- Token du bot
- Bot ajouté à votre serveur FDM
- ID du serveur Discord

## 🐳 Déploiement Docker

### 1. Connexion SSH à votre NAS
```bash
ssh votre-user@votre-nas-ip
```

### 2. Création du répertoire projet
```bash
mkdir -p /volume1/docker/fdm-community
cd /volume1/docker/fdm-community
```

### 3. Téléchargement des fichiers
Transférez tous les fichiers du projet dans ce répertoire, ou clonez depuis Git :
```bash
git clone https://github.com/votre-username/fdm-community.git .
```

### 4. Configuration
```bash
# Copier le fichier de configuration
cp .env.example .env

# Éditer avec vos vraies valeurs
nano .env
```

Configurez votre `.env` :
```env
DISCORD_TOKEN=votre_token_discord_ici
DISCORD_GUILD_ID=votre_id_serveur_discord
ADMIN_PASSWORD=votre_mot_de_passe_admin_securise
PORT=3001
NODE_ENV=production
```

### 5. Permissions des scripts
```bash
chmod +x *.sh
```

### 6. Démarrage
```bash
./docker-start.sh
```

## 🌐 Configuration Réseau

### Port Forwarding (optionnel)
Si vous voulez accéder depuis l'extérieur :
1. Router : Rediriger le port 3001 vers votre NAS
2. Pare-feu NAS : Autoriser le port 3001

### Nom de domaine local
Ajoutez dans votre fichier hosts local :
```
192.168.x.x  fdm.local
```

## 🔧 Configuration Discord

### Permissions du Bot
Le bot a besoin des permissions suivantes :
- `View Channels`
- `Read Message History`

### Intents nécessaires
Dans le Discord Developer Portal :
- `Server Members Intent` : Activé
- `Presence Intent` : Activé

## 📊 Vérification du Déploiement

### 1. Statut du conteneur
```bash
./docker-status.sh
```

### 2. Logs du service
```bash
docker-compose logs -f
```

### 3. Test de connectivité
```bash
curl http://localhost:3001/api/discord/stats
```

### 4. Test web
Ouvrez dans votre navigateur :
- http://votre-nas-ip:3001
- http://votre-nas-ip:3001/admin.html

## 🛠️ Maintenance

### Mise à jour
```bash
./docker-update.sh
```

### Sauvegarde
```bash
# Sauvegarde automatique des données
docker run --rm -v fdm-community_fdm-data:/data -v $(pwd)/backups:/backup alpine tar czf /backup/fdm-backup-$(date +%Y%m%d).tar.gz -C /data .
```

### Restauration
```bash
# Arrêter le conteneur
docker-compose down

# Restaurer les données
docker run --rm -v fdm-community_fdm-data:/data -v $(pwd)/backups:/backup alpine tar xzf /backup/fdm-backup-YYYYMMDD.tar.gz -C /data

# Redémarrer
docker-compose up -d
```

### Redémarrage automatique
Ajoutez au crontab du NAS :
```bash
# Vérification toutes les 5 minutes
*/5 * * * * cd /volume1/docker/fdm-community && ./docker-status.sh > /dev/null 2>&1 || ./docker-start.sh

# Redémarrage quotidien à 4h
0 4 * * * cd /volume1/docker/fdm-community && docker-compose restart
```

## 🔐 Sécurité

### Pare-feu
Configurez le pare-feu Synology :
- Autoriser le port 3001 depuis votre réseau local
- Bloquer l'accès externe si non nécessaire

### Certificats SSL (optionnel)
Pour HTTPS avec Let's Encrypt :
1. Utilisez Nginx Proxy Manager
2. Ou configurez Traefik comme reverse proxy

### Mots de passe
- Utilisez un mot de passe admin fort
- Changez régulièrement le token Discord

## 🚨 Dépannage

### Le conteneur ne démarre pas
```bash
# Vérifier les logs
docker-compose logs

# Vérifier la configuration
cat .env

# Reconstruire l'image
docker-compose build --no-cache
```

### Bot Discord non connecté
1. Vérifiez le token dans `.env`
2. Vérifiez que le bot est sur le serveur
3. Vérifiez les intents dans Discord Developer Portal

### Base de données corrompue
```bash
# Voir les sauvegardes disponibles
ls -la backups/

# Restaurer une sauvegarde
./docker-update.sh  # Inclut une sauvegarde automatique
```

### Problème de performances
```bash
# Vérifier l'utilisation des ressources
docker stats fdm-community

# Augmenter les limites si nécessaire
# Modifier docker-compose.yml :
deploy:
  resources:
    limits:
      memory: 512M
    reservations:
      memory: 256M
```

## 📈 Monitoring

### Logs structurés
```bash
# Logs avec horodatage
docker-compose logs -f --timestamps

# Logs des dernières 100 lignes
docker-compose logs --tail=100
```

### Métriques
```bash
# Utilisation des ressources
docker stats fdm-community --no-stream

# Espace disque
docker system df

# Volumes
docker volume ls
```

### Alertes (optionnel)
Configurez des alertes Synology pour :
- Utilisation CPU > 80%
- Utilisation RAM > 80%
- Espace disque faible

---

## 🎉 Félicitations !

Votre site FDM Community est maintenant déployé et opérationnel !

**Accès :**
- 🌐 Site : http://votre-nas-ip:3001
- ⚙️ Admin : http://votre-nas-ip:3001/admin.html
- 📊 Stats : Temps réel depuis Discord

**Support :**
- 📧 contact@teamfdm.fr
- 💬 Discord FDM
- 🐛 GitHub Issues