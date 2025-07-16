# 🚀 Déploiement Rapide sur NAS Synology

## ⚡ Installation en 5 minutes

### 1. Prérequis NAS
```bash
# Connectez-vous en SSH à votre NAS
ssh Fofo@teamfdm

# Vérifiez que Docker est installé
docker --version
docker-compose --version
```

### 2. Téléchargement du projet
```bash
# Créez le répertoire projet
mkdir -p /volume1/docker/fdm-community
cd /volume1/docker/fdm-community

# Option A : Clone depuis GitHub (si disponible)
git clone https://github.com/votre-username/fdm-community.git .

# Option B : Transférez les fichiers via SCP/SFTP
# Copiez tous les fichiers du projet dans ce répertoire
```

### 3. Configuration Express
```bash
# Copiez la configuration
cp .env.example .env

# Éditez avec vos vraies valeurs
nano .env
```

**Votre .env doit contenir :**
```env
DISCORD_TOKEN=MTM5MzQwNjQwNjg2NTk3NzQ3Nw.GVXMXj.apuAo9qscEnDI2G_5XoRpc1oEiGN6jygSb7LQ4
DISCORD_GUILD_ID=681602280893579342
ADMIN_PASSWORD=fdm2024admin
PORT=3001
NODE_ENV=production
```

### 4. Démarrage
```bash
# Rendez les scripts exécutables
chmod +x *.sh

# Vérification pré-déploiement
./docker-check.sh

# Démarrage automatique
./docker-start.sh
```

### 5. Vérification
```bash
# Vérifiez le statut
./docker-status.sh

# Testez l'accès web
curl http://localhost:3001/api/discord/stats
```

## 🌐 Accès à votre site

- **Site principal** : `http://votre-nas-ip:3001`
- **Panel admin** : `http://votre-nas-ip:3001/admin.html`
- **Mot de passe admin** : `fdm2024admin` (changez-le !)

## 🔧 Commandes de maintenance

```bash
# Status complet
./docker-status.sh

# Logs en temps réel
docker-compose logs -f

# Redémarrage
docker-compose restart

# Mise à jour
./docker-update.sh

# Arrêt
docker-compose down
```

## 🤖 Auto-démarrage (optionnel)

Ajoutez au crontab pour un démarrage automatique :
```bash
crontab -e

# Ajoutez ces lignes :
@reboot cd /volume1/docker/fdm-community && ./docker-start.sh
*/5 * * * * cd /volume1/docker/fdm-community && docker-compose ps | grep -q "Up" || ./docker-start.sh
```

## 🎯 Résultat attendu

Après le déploiement, vous devriez voir :
- ✅ Site accessible sur port 3001
- ✅ Stats Discord temps réel (103 membres, 16 en ligne)
- ✅ Panel admin fonctionnel
- ✅ Base de données créée automatiquement
- ✅ Événements pré-configurés

## 🆘 Aide rapide

### Le site ne s'affiche pas
```bash
# Vérifiez les logs
docker-compose logs

# Vérifiez la configuration
cat .env

# Redémarrez
docker-compose restart
```

### Bot Discord non connecté
1. Vérifiez votre `DISCORD_TOKEN` dans `.env`
2. Vérifiez que le bot est sur votre serveur
3. Vérifiez l'`DISCORD_GUILD_ID`

### Changement de port
Si le port 3001 est occupé, modifiez dans `docker-compose.yml` :
```yaml
ports:
  - "3002:3001"  # Port externe : Port interne
```

---

**🎮 Votre site FDM Community sera opérationnel en moins de 5 minutes !**