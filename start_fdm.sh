#!/bin/bash

# Script de démarrage pour le serveur FDM sur NAS Synology
# Fichier : start_fdm.sh

echo "🎮 Démarrage du serveur FDM Community..."

# Se placer dans le bon répertoire
cd /volume1/web/FDM

# Tuer les anciens processus si ils existent
echo "🔄 Nettoyage des anciens processus..."
pkill -f "node server.js"
sleep 2

# Démarrer le serveur
echo "🚀 Démarrage du serveur..."
node server.js > server.log 2>&1 &

# Attendre un peu pour que le serveur démarre
sleep 3

# Vérifier que le serveur fonctionne
if pgrep -f "node server.js" > /dev/null; then
    echo "✅ Serveur FDM démarré avec succès !"
    echo "🌍 Accès : http://teamfdm:3001"
    echo "⚙️  Panel admin : http://teamfdm:3001/admin.html"
    echo "🔧 Configuration : http://teamfdm:3001/config.html"
    echo ""
    echo "📊 Stats Discord en temps réel activées"
    echo "🎯 Serveur Discord connecté"
    echo ""
    echo "📝 Logs disponibles dans : server.log"
else
    echo "❌ Erreur lors du démarrage du serveur"
    echo "📝 Vérifiez les logs dans : server.log"
fi