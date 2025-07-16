# 🏠 Installation FDM Community sur Synology DS218+

## 📋 Prérequis

### 1. Spécifications NAS
- **Modèle :** Synology DS218+ (ARM64)
- **RAM :** Minimum 2GB (4GB recommandé)
- **Stockage :** 1GB d'espace libre minimum
- **DSM :** Version 7.0 ou supérieure

### 2. Paquets Synology requis
- **Docker** (Centre de paquets)
- **SSH** (Panneau de configuration > Terminal & SNMP)

## 🚀 Installation

### Étape 1 : Préparer le NAS

1. **Installer Docker :**
   - Ouvrez le Centre de paquets
   - Recherchez "Docker"
   - Installez Docker
   - Démarrez le service

2. **Activer SSH :**
   - Panneau de configuration > Terminal & SNMP
   - Activez le service SSH
   - Notez l'adresse IP de votre NAS

### Étape 2 : Connexion SSH

```bash
# Connectez-vous à votre NAS via SSH
ssh admin@IP_DE_VOTRE_NAS

# Naviguez vers le dossier docker (ou créez-le)
cd /volume1/docker
mkdir -p fdm-community
cd fdm-community
```

### Étape 3 : Télécharger les fichiers

```bash
# Téléchargez ou copiez tous les fichiers du projet dans ce dossier
# Assurez-vous d'avoir tous ces fichiers :
# - server.js
# - package.json
# - index.html, admin.html, config.html
# - style.css, script.js
# - Dockerfile
# - docker-compose.yml
# - deploy-synology.sh
# - .env
```

### Étape 4 : Configuration

1. **Éditez le fichier .env :**
```bash
nano .env
```

2. **Configurez vos paramètres :**
```env
# Token Discord (obligatoire)
DISCORD_TOKEN=VOTRE_TOKEN_DISCORD

# ID du serveur Discord (obligatoire)
DISCORD_GUILD_ID=VOTRE_GUILD_ID

# Mot de passe admin
ADMIN_PASSWORD=VotreMotDePasse

# Port (3001 par défaut)
PORT=3001

# Environnement
NODE_ENV=production

# Timezone
TZ=Europe/Paris
```

### Étape 5 : Déploiement

```bash
# Rendez le script exécutable
chmod +x deploy-synology.sh

# Lancez le déploiement
./deploy-synology.sh
```

## 🔧 Gestion via DSM (Interface Web)

### Accès Docker via DSM

1. **Ouvrez DSM** (http://IP_NAS:5000)
2. **Lancez Docker**
3. **Onglet "Conteneur"** : Gérez votre conteneur fdm-community
4. **Onglet "Image"** : Voir les images Docker

### Actions possibles :
- **Démarrer/Arrêter** le conteneur
- **Voir les logs** en temps réel
- **Modifier les paramètres** du conteneur
- **Redémarrer** le service

## 🌐 Accès au site

Une fois déployé, votre site sera accessible :

- **Local :** http://localhost:3001
- **Réseau :** http://IP_DE_VOTRE_NAS:3001
- **Admin :** http://IP_DE_VOTRE_NAS:3001/admin
- **Config :** http://IP_DE_VOTRE_NAS:3001/config

## 🛠️ Commandes utiles

```bash
# Voir les logs
docker logs fdm-community -f

# Redémarrer le conteneur
docker-compose restart

# Arrêter le service
docker-compose down

# Redémarrer complètement
docker-compose down && docker-compose up -d

# Voir le statut
docker ps

# Entrer dans le conteneur
docker exec -it fdm-community sh
```

## 📊 Monitoring

### Surveillance des ressources

```bash
# Utilisation des ressources
docker stats fdm-community

# Informations détaillées
docker inspect fdm-community
```

### Logs importantes
- **Application :** `docker logs fdm-community`
- **Système :** DSM > Centre de journalisation
- **Docker :** DSM > Docker > Conteneur > Logs

## 🔧 Optimisations pour DS218+

### Limites configurées :
- **CPU :** 1 core maximum
- **RAM :** 512MB maximum
- **Processus Node.js :** Optimisé pour ARM64

### Paramètres spécifiques :
```yaml
# Dans docker-compose.yml
deploy:
  resources:
    limits:
      cpus: '1.0'
      memory: 512M
    reservations:
      cpus: '0.5'
      memory: 256M
```

## 🔒 Sécurité

### Bonnes pratiques :
1. **Utilisateur non-root** dans le conteneur
2. **Port 3001** uniquement (pas d'exposition inutile)
3. **Logs limités** pour économiser l'espace
4. **Mot de passe admin** fort
5. **Token Discord** sécurisé

### Pare-feu :
- Ouvrez le port 3001 dans le pare-feu Synology
- Panneau de configuration > Sécurité > Pare-feu

## 📱 Accès externe (optionnel)

Pour accéder depuis l'extérieur :

1. **QuickConnect** : Configuration DSM
2. **DDNS** : Panneau de configuration > Accès externe
3. **Reverse Proxy** : Panneau de configuration > Serveur d'applications

## 🆘 Dépannage

### Problèmes courants :

1. **Container ne démarre pas :**
   ```bash
   docker logs fdm-community
   ```

2. **Erreur de permissions :**
   ```bash
   sudo chown -R 1001:1001 data logs
   ```

3. **Port occupé :**
   ```bash
   # Changer le port dans docker-compose.yml
   ports:
     - "3002:3001"
   ```

4. **Manque de mémoire :**
   ```bash
   # Redémarrer le NAS
   # Ou fermer d'autres applications
   ```

### Réinitialisation complète :

```bash
# Tout supprimer et recommencer
docker-compose down
docker rmi fdm-community_fdm-community
rm -rf data logs
./deploy-synology.sh
```

## 📞 Support

- **Logs détaillés :** `docker logs fdm-community -f`
- **Test de connectivité :** `curl http://localhost:3001`
- **Statut des services :** `docker ps`

---

*Configuration optimisée pour Synology DS218+ avec ARM64 🏠*