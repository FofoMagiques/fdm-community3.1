#!/bin/bash

# Script de mise à jour pour FDM Community
# Fichier : update_fdm.sh

FDM_DIR="/app"
BACKUP_DIR="/app/backups"
DATE=$(date '+%Y-%m-%d_%H-%M-%S')

echo "🔄 Mise à jour FDM Community..."

# Créer le dossier de sauvegarde
mkdir -p "$BACKUP_DIR"

# Arrêter le serveur
echo "🛑 Arrêt du serveur..."
./monitor_fdm.sh stop

# Sauvegarder la base de données
echo "💾 Sauvegarde de la base de données..."
if [ -f "fdm_database.db" ]; then
    cp "fdm_database.db" "$BACKUP_DIR/fdm_database_$DATE.db"
    echo "✅ Base de données sauvegardée"
else
    echo "⚠️  Aucune base de données trouvée"
fi

# Sauvegarder la configuration
echo "💾 Sauvegarde de la configuration..."
cp ".env" "$BACKUP_DIR/.env_$DATE"
echo "✅ Configuration sauvegardée"

# Installer les nouvelles dépendances si nécessaire
echo "📦 Vérification des dépendances..."
npm install --production

# Redémarrer le serveur
echo "🚀 Redémarrage du serveur..."
./monitor_fdm.sh start

# Vérifier le statut
sleep 3
./monitor_fdm.sh status

echo ""
echo "🎉 Mise à jour terminée !"
echo "📁 Sauvegardes dans : $BACKUP_DIR"