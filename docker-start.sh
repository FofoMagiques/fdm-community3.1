#!/bin/bash

# Script de démarrage Docker pour FDM Community
echo "🎮 Démarrage de FDM Community avec Docker..."

# Vérifier si Docker est installé
if ! command -v docker &> /dev/null; then
    echo "❌ Docker n'est pas installé. Veuillez l'installer d'abord."
    exit 1
fi

# Vérifier si docker-compose est installé
if ! command -v docker-compose &> /dev/null; then
    echo "❌ Docker Compose n'est pas installé. Veuillez l'installer d'abord."
    exit 1
fi

# Vérifier si le fichier .env existe
if [ ! -f .env ]; then
    echo "⚠️  Fichier .env manquant. Copie de .env.example..."
    cp .env.example .env
    echo "📝 Veuillez éditer le fichier .env avec vos vraies valeurs :"
    echo "   - DISCORD_TOKEN"
    echo "   - DISCORD_GUILD_ID"
    echo "   - ADMIN_PASSWORD"
    echo ""
    echo "Puis relancez : ./docker-start.sh"
    exit 1
fi

# Arrêter les anciens conteneurs
echo "🛑 Arrêt des anciens conteneurs..."
docker-compose down

# Construire et démarrer
echo "🔨 Construction de l'image Docker..."
docker-compose build

echo "🚀 Démarrage des conteneurs..."
docker-compose up -d

# Attendre que le service soit prêt
echo "⏳ Attente du démarrage du service..."
sleep 10

# Vérifier le statut
if docker-compose ps | grep -q "Up"; then
    echo "✅ FDM Community démarré avec succès !"
    echo ""
    echo "🌐 Accès web :"
    echo "   📱 Site principal : http://localhost:3001"
    echo "   ⚙️  Panel admin    : http://localhost:3001/admin.html"
    echo "   🔧 Configuration  : http://localhost:3001/config.html"
    echo ""
    echo "📊 Commandes utiles :"
    echo "   docker-compose logs -f    # Voir les logs"
    echo "   docker-compose stop       # Arrêter"
    echo "   docker-compose restart    # Redémarrer"
    echo "   ./docker-status.sh        # Vérifier le statut"
else
    echo "❌ Erreur lors du démarrage. Vérifiez les logs :"
    echo "   docker-compose logs"
fi