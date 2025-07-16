#!/bin/bash

# Script de démarrage FDM Community
# Peut être utilisé avec ou sans Docker

echo "🚀 Démarrage du site FDM Community..."

# Vérifier que Node.js est installé
if ! command -v node &> /dev/null; then
    echo "❌ Node.js n'est pas installé"
    exit 1
fi

# Vérifier que les dépendances sont installées
if [ ! -d "node_modules" ]; then
    echo "📦 Installation des dépendances..."
    npm install
fi

# Créer le dossier data s'il n'existe pas
mkdir -p data
mkdir -p logs

# Lancer le serveur
echo "🌍 Lancement du serveur sur le port 3001..."
echo "🔗 Accès local : http://localhost:3001"
echo "🛑 Pour arrêter le serveur, faites Ctrl+C"

node server.js