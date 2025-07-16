# FDM Community - Site Web

Site web de la communauté FDM avec intégration Discord.

## 🚀 Démarrage rapide

### Option 1 : Démarrage classique (Node.js)

```bash
# Installer les dépendances
npm install

# Démarrer le serveur
node server.js
```

Ou utilisez le script de démarrage :

```bash
chmod +x start.sh
./start.sh
```

### Option 2 : Démarrage avec Docker

```bash
# Construire et démarrer
docker-compose up --build

# Ou en arrière-plan
docker-compose up -d --build
```

## 🔧 Configuration

1. **Copiez le fichier .env** et modifiez les valeurs selon vos besoins :
   - `DISCORD_TOKEN` : Token de votre bot Discord
   - `DISCORD_GUILD_ID` : ID de votre serveur Discord
   - `ADMIN_PASSWORD` : Mot de passe pour l'administration

2. **Créez votre bot Discord** :
   - Allez sur https://discord.com/developers/applications
   - Créez une nouvelle application
   - Copiez le token du bot
   - Invitez le bot sur votre serveur avec les permissions nécessaires

## 🌐 Accès au site

- **Site principal** : http://localhost:3001
- **Administration** : http://localhost:3001/admin.html
- **Configuration** : http://localhost:3001/config.html

## 📁 Structure du projet

```
fdm-community/
├── server.js          # Serveur Express principal
├── index.html         # Page d'accueil
├── style.css          # Styles CSS
├── script.js          # JavaScript frontend
├── admin.html         # Panel d'administration
├── config.html        # Configuration
├── package.json       # Dépendances Node.js
├── Dockerfile         # Configuration Docker
├── docker-compose.yml # Configuration Docker Compose
└── .env              # Variables d'environnement
```

## 🔧 Fonctionnalités

- ✅ Intégration Discord (stats en temps réel)
- ✅ Système d'événements
- ✅ Panel d'administration
- ✅ Base de données SQLite
- ✅ API REST
- ✅ Interface responsive
- ✅ Système de notifications

## 🛠️ Problèmes courants

### Le site ne charge pas le CSS/JS
- Vérifiez que les fichiers sont dans le bon dossier
- Redémarrez le serveur

### Le bot Discord ne se connecte pas
- Vérifiez votre token Discord
- Vérifiez que le bot est invité sur votre serveur

### Docker ne démarre pas
- Vérifiez que Docker est installé
- Vérifiez les permissions des fichiers

## 🆘 Support

Pour toute question ou problème, vérifiez :
1. Les logs du serveur
2. La configuration .env
3. Les permissions des fichiers
4. La connexion Discord

---

*Développé avec ❤️ pour la communauté FDM*