#!/bin/bash

# Script de réparation Docker pour FDM Community
# Corrige les problèmes courants avec Docker

echo "🔧 Réparation des problèmes Docker..."

# Nettoyer les anciens containers
echo "🧹 Nettoyage des anciens containers..."
docker stop fdm-community 2>/dev/null || true
docker rm fdm-community 2>/dev/null || true
docker rmi fdm-community_fdm-community 2>/dev/null || true

# Vérifier la structure des fichiers
echo "📁 Vérification de la structure des fichiers..."

required_files=(
    "package.json"
    "server.js"
    "index.html"
    "style.css"
    "script.js"
    "admin.html"
    "config.html"
    "Dockerfile"
    "docker-compose.yml"
    ".env"
)

missing_files=()
for file in "${required_files[@]}"; do
    if [ ! -f "$file" ]; then
        missing_files+=("$file")
    fi
done

if [ ${#missing_files[@]} -gt 0 ]; then
    echo "❌ Fichiers manquants:"
    printf '   %s\n' "${missing_files[@]}"
    echo "⚠️  Assurez-vous que tous les fichiers sont présents avant de continuer."
    exit 1
else
    echo "✅ Tous les fichiers requis sont présents"
fi

# Nettoyer les dossiers inutiles
echo "🗑️  Nettoyage des dossiers inutiles..."
if [ -d "frontend" ]; then
    echo "Suppression du dossier frontend inutile..."
    rm -rf frontend
fi

# Créer les dossiers nécessaires
echo "📂 Création des dossiers nécessaires..."
mkdir -p data
mkdir -p logs

# Vérifier et corriger les permissions
echo "🔒 Vérification des permissions..."
chmod +x start.sh 2>/dev/null || true
chmod +x test-site.sh 2>/dev/null || true

# Construire l'image Docker
echo "🏗️  Construction de l'image Docker..."
if docker compose build --no-cache; then
    echo "✅ Image Docker construite avec succès"
else
    echo "❌ Erreur lors de la construction de l'image Docker"
    exit 1
fi

# Démarrer les services
echo "🚀 Démarrage des services Docker..."
if docker compose up -d; then
    echo "✅ Services Docker démarrés avec succès"
    
    # Attendre que le service soit prêt
    echo "⏳ Attente du démarrage du service..."
    sleep 10
    
    # Vérifier que le service fonctionne
    if docker compose ps | grep -q "running"; then
        echo "✅ Service FDM Community est en cours d'exécution"
        
        # Test de connectivité
        echo "🧪 Test de connectivité..."
        if curl -s -o /dev/null -w "%{http_code}" "http://localhost:3001" | grep -q "200"; then
            echo "✅ Site accessible sur http://localhost:3001"
        else
            echo "❌ Site non accessible"
            echo "📋 Logs du container:"
            docker compose logs --tail=10
        fi
    else
        echo "❌ Service non démarré"
        echo "📋 Logs du container:"
        docker compose logs --tail=20
    fi
else
    echo "❌ Erreur lors du démarrage des services Docker"
    exit 1
fi

echo ""
echo "🎯 Réparation Docker terminée !"
echo "🔗 Site : http://localhost:3001"
echo "🛠️  Admin : http://localhost:3001/admin"
echo "📊 Logs : docker compose logs -f"
echo "🛑 Arrêt : docker compose down"