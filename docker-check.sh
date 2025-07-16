#!/bin/bash

# Test des fichiers Docker avant déploiement
echo "🔍 Vérification des fichiers Docker pour FDM Community"
echo "=================================================="

# Vérifier la présence des fichiers essentiels
FILES_REQUIRED=(
    "Dockerfile"
    "docker-compose.yml"
    ".env.example"
    "package.json"
    "server.js"
    "index.html"
    "style.css"
    "script.js"
)

echo "📁 Vérification des fichiers requis..."
for file in "${FILES_REQUIRED[@]}"; do
    if [ -f "$file" ]; then
        echo "✅ $file"
    else
        echo "❌ $file - MANQUANT"
        exit 1
    fi
done

# Vérifier les permissions des scripts
echo ""
echo "🔐 Vérification des permissions..."
SCRIPTS=(
    "docker-start.sh"
    "docker-status.sh"
    "docker-update.sh"
)

for script in "${SCRIPTS[@]}"; do
    if [ -x "$script" ]; then
        echo "✅ $script (exécutable)"
    else
        echo "⚠️  $script (non exécutable) - Correction..."
        chmod +x "$script"
        echo "✅ $script (corrigé)"
    fi
done

# Vérifier le contenu du package.json
echo ""
echo "📦 Vérification de package.json..."
if command -v node &> /dev/null; then
    if node -e "JSON.parse(require('fs').readFileSync('package.json', 'utf8'))" 2>/dev/null; then
        echo "✅ package.json valide"
    else
        echo "❌ package.json invalide"
        exit 1
    fi
else
    echo "⚠️  Node.js non disponible pour la vérification JSON"
fi

# Vérifier la configuration .env.example
echo ""
echo "🔧 Vérification de .env.example..."
if grep -q "DISCORD_TOKEN=" .env.example && grep -q "DISCORD_GUILD_ID=" .env.example; then
    echo "✅ .env.example contient les variables Discord requises"
else
    echo "❌ .env.example manque des variables essentielles"
    exit 1
fi

# Vérifier le Dockerfile
echo ""
echo "🐳 Vérification du Dockerfile..."
if grep -q "FROM node:" Dockerfile && grep -q "WORKDIR /app" Dockerfile; then
    echo "✅ Dockerfile structure correcte"
else
    echo "❌ Dockerfile structure incorrecte"
    exit 1
fi

# Vérifier docker-compose.yml
echo ""
echo "🐳 Vérification de docker-compose.yml..."
if grep -q "version:" docker-compose.yml && grep -q "services:" docker-compose.yml; then
    echo "✅ docker-compose.yml structure correcte"
else
    echo "❌ docker-compose.yml structure incorrecte"
    exit 1
fi

# Vérifier la taille des fichiers principaux
echo ""
echo "📊 Taille des fichiers principaux..."
for file in "index.html" "style.css" "script.js" "server.js"; do
    if [ -f "$file" ]; then
        size=$(stat -c%s "$file" 2>/dev/null || stat -f%z "$file" 2>/dev/null)
        if [ "$size" -gt 100 ]; then
            echo "✅ $file (${size} bytes)"
        else
            echo "⚠️  $file (${size} bytes) - Fichier très petit"
        fi
    fi
done

echo ""
echo "🎉 Vérification terminée !"
echo ""
echo "📋 Étapes suivantes pour le déploiement :"
echo "1. Copier .env.example vers .env"
echo "2. Configurer vos variables Discord dans .env"
echo "3. Lancer : ./docker-start.sh"
echo ""
echo "🔗 Documentation complète dans README.md et DEPLOY.md"