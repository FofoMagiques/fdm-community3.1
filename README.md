# 🎮 FDM Community

[![Docker](https://img.shields.io/badge/Docker-Ready-blue?logo=docker)](https://docker.com)
[![Node.js](https://img.shields.io/badge/Node.js-18+-green?logo=node.js)](https://nodejs.org)
[![Discord](https://img.shields.io/badge/Discord-Bot%20Integrated-7289da?logo=discord)](https://discord.com)
[![License](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

> Site communautaire moderne pour le serveur Discord FDM avec backend intégré, stats Discord temps réel et gestion d'événements.

![FDM Community Preview](https://via.placeholder.com/800x400/2a1529/f8f0f8?text=FDM+Community+Preview)

## ✨ Fonctionnalités

### 🤖 **Discord Integration**
- **Stats temps réel** : Membres et utilisateurs en ligne mis à jour automatiquement
- **Bot Discord intégré** : Connexion directe à votre serveur
- **Lien d'invitation** : Bouton "Rejoindre Discord" fonctionnel

### 📅 **Gestion d'Événements**
- **CRUD complet** : Créer, modifier et supprimer des événements
- **Système de participation** : Inscription avec pseudos trackés
- **Téléchargements** : Launcher/fichiers avec historique complet
- **Panel admin** : Interface web intuitive

### 🎨 **Design & UX**
- **Design moderne** : Thème dark avec accents roses
- **Responsive** : Compatible mobile, tablette et desktop
- **Animations fluides** : Transitions et effets visuels
- **Performance optimisée** : Chargement rapide

### 🔐 **Sécurité & Fiabilité**
- **Authentification sécurisée** : Panel admin protégé
- **Rate limiting** : Protection contre les abus
- **Validation des données** : Entrées utilisateur sécurisées
- **Base de données** : SQLite embarquée pour la persistance

## 🚀 Installation Rapide (Docker)

### Prérequis
- Docker et Docker Compose installés
- Bot Discord créé avec token
- ID de votre serveur Discord

### 1. Clone du repository
```bash
git clone https://github.com/votre-username/fdm-community.git
cd fdm-community
```

### 2. Configuration
```bash
# Copier le fichier de configuration
cp .env.example .env

# Éditer avec vos valeurs
nano .env
```

Remplissez votre `.env` :
```env
DISCORD_TOKEN=your_discord_bot_token_here
DISCORD_GUILD_ID=your_discord_guild_id_here
ADMIN_PASSWORD=your_secure_admin_password
PORT=3001
```

### 3. Démarrage
```bash
# Démarrage automatique
./docker-start.sh

# Ou manuellement
docker-compose up -d
```

### 4. Accès
- **Site principal** : http://localhost:3001
- **Panel admin** : http://localhost:3001/admin.html
- **Configuration** : http://localhost:3001/config.html

## 📋 Configuration Discord

### Créer un Bot Discord

1. **Developer Portal** : https://discord.com/developers/applications
2. **New Application** → Nommer votre bot
3. **Bot** → Reset Token → Copier le token
4. **OAuth2** → URL Generator :
   - Scopes : `bot`
   - Permissions : `Read Messages/View Channels`
5. **Inviter le bot** sur votre serveur

### Obtenir l'ID du serveur

1. **Activer le mode développeur** : Discord → Paramètres → Avancé → Mode développeur
2. **Clic droit** sur votre serveur → Copier l'ID du serveur
3. **Coller l'ID** dans `DISCORD_GUILD_ID`

## 🛠️ Utilisation

### Panel Admin

1. Accédez à `/admin.html`
2. Connectez-vous avec votre mot de passe admin
3. Gérez vos événements :
   - ➕ Créer de nouveaux événements
   - ✏️ Modifier les événements existants
   - 🗑️ Supprimer les événements
   - 📥 Voir l'historique des téléchargements

### Gestion des Événements

```javascript
// Exemple d'événement
{
  "title": "Tournoi Valorant FDM",
  "description": "Tournoi hebdomadaire avec prix à gagner !",
  "date": "2025-03-15",
  "time": "20:00",
  "category": "Gaming",
  "max_participants": 50,
  "has_download": true,
  "download_text": "Télécharger le guide"
}
```

### API Endpoints

| Méthode | Endpoint | Description |
|---------|----------|-------------|
| `GET` | `/api/discord/stats` | Stats Discord temps réel |
| `GET` | `/api/events` | Liste des événements |
| `POST` | `/api/events/:id/participate` | Participer à un événement |
| `POST` | `/api/events/:id/download` | Télécharger un fichier |
| `POST` | `/api/admin/login` | Connexion admin |
| `POST` | `/api/admin/events` | Créer un événement |
| `PUT` | `/api/admin/events/:id` | Modifier un événement |
| `DELETE` | `/api/admin/events/:id` | Supprimer un événement |

## 🔧 Commandes Docker

```bash
# Démarrer
./docker-start.sh

# Vérifier le statut
./docker-status.sh

# Mettre à jour
./docker-update.sh

# Logs en temps réel
docker-compose logs -f

# Redémarrer
docker-compose restart

# Arrêter
docker-compose down

# Nettoyer
docker system prune
```

## 📊 Monitoring

### Health Check
Le conteneur inclut un health check automatique qui vérifie :
- Connectivité du serveur
- Réponse de l'API Discord
- État général du service

### Logs
```bash
# Logs du conteneur
docker-compose logs -f

# Logs spécifiques
docker-compose logs -f fdm-community
```

### Métriques
```bash
# Stats du conteneur
docker stats fdm-community

# Utilisation des volumes
docker system df
```

## 🗂️ Structure du Projet

```
fdm-community/
├── 📄 index.html              # Page principale
├── 🎨 style.css               # Styles CSS
├── ⚡ script.js               # JavaScript frontend
├── 🖥️ server.js               # Serveur backend Node.js
├── 👨‍💼 admin.html               # Panel administrateur
├── 🔧 config.html             # Page de configuration
├── 📦 package.json            # Dépendances Node.js
├── 🐳 Dockerfile              # Configuration Docker
├── 🐳 docker-compose.yml      # Orchestration Docker
├── 🔐 .env.example            # Variables d'environnement
├── 🗄️ fdm_database.db         # Base de données SQLite
├── 🖼️ image/                  # Assets images
│   └── Logo FDM V3.png
└── 🚀 Scripts de déploiement
    ├── docker-start.sh
    ├── docker-status.sh
    └── docker-update.sh
```

## 🔐 Sécurité

### Mesures Implémentées
- **Helmet.js** : Headers de sécurité HTTP
- **Rate Limiting** : Protection contre les attaques
- **Validation des entrées** : Sanitisation des données
- **CORS configuré** : Politique d'origine croisée
- **Utilisateur non-root** : Conteneur sécurisé

### Recommandations
- Utilisez des mots de passe forts
- Changez régulièrement le token Discord
- Surveillez les logs d'accès
- Mettez à jour régulièrement

## 🤝 Contribution

1. **Fork** le repository
2. **Créez** votre branche (`git checkout -b feature/AmazingFeature`)
3. **Commitez** vos changements (`git commit -m 'Add some AmazingFeature'`)
4. **Push** vers la branche (`git push origin feature/AmazingFeature`)
5. **Ouvrez** une Pull Request

## 📝 Changelog

### v1.0.0 (2025-01-14)
- ✨ Version initiale avec Docker
- 🤖 Intégration Discord complète
- 📅 Système de gestion d'événements
- 👨‍💼 Panel administrateur
- 🔐 Authentification sécurisée
- 📱 Design responsive

## 🐛 Dépannage

### Problèmes courants

#### Le bot Discord ne se connecte pas
```bash
# Vérifier les logs
docker-compose logs fdm-community

# Vérifier la configuration
cat .env
```

#### Erreur de port déjà utilisé
```bash
# Changer le port dans docker-compose.yml
ports:
  - "3002:3001"  # Au lieu de 3001:3001
```

#### Base de données corrompue
```bash
# Restaurer depuis une sauvegarde
docker-compose down
# Remplacer le volume avec une sauvegarde
docker-compose up -d
```

## 📞 Support

- 🐛 **Issues** : [GitHub Issues](https://github.com/votre-username/fdm-community/issues)
- 💬 **Discord** : Rejoignez notre serveur pour le support
- 📧 **Email** : contact@teamfdm.fr

## 📜 License

Ce projet est sous licence MIT. Voir le fichier [LICENSE](LICENSE) pour plus de détails.

---

<div align="center">

**Développé avec ❤️ par la communauté FDM**

[Site Web](http://teamfdm.fr) • [Discord](https://discord.gg/your-invite) • [GitHub](https://github.com/votre-username)

</div>