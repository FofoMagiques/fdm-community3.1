#!/bin/bash

# Script de mise à jour Docker pour FDM Community
echo "🔄 Mise à jour de FDM Community..."

# Sauvegarder les données
echo "💾 Sauvegarde des données..."
mkdir -p backups
DATE=$(date '+%Y-%m-%d_%H-%M-%S')

# Sauvegarder le volume de données
docker run --rm -v fdm-community_fdm-data:/data -v $(pwd)/backups:/backup alpine tar czf /backup/fdm-data-$DATE.tar.gz -C /data .

echo "✅ Sauvegarde créée : backups/fdm-data-$DATE.tar.gz"

# Arrêter les conteneurs
echo "🛑 Arrêt des conteneurs..."
docker-compose down

# Mettre à jour l'image
echo "🔨 Reconstruction de l'image..."
docker-compose build --no-cache

# Redémarrer
echo "🚀 Redémarrage..."
docker-compose up -d

# Attendre et vérifier
echo "⏳ Vérification du démarrage..."
sleep 15

if docker-compose ps | grep -q "Up"; then
    echo "✅ Mise à jour terminée avec succès !"
    ./docker-status.sh
else
    echo "❌ Erreur lors de la mise à jour"
    echo "📝 Vérifiez les logs : docker-compose logs"
fi