#!/bin/bash

# Script de vérification du statut Docker
echo "🔍 Statut de FDM Community"
echo "=========================="

# Vérifier si le conteneur tourne
if docker-compose ps | grep -q "Up"; then
    echo "✅ Conteneur : En cours d'exécution"
    
    # Obtenir l'ID du conteneur
    CONTAINER_ID=$(docker-compose ps -q fdm-community)
    
    # Afficher les stats du conteneur
    echo "📊 Statistiques du conteneur :"
    docker stats --no-stream $CONTAINER_ID --format "   CPU: {{.CPUPerc}} | RAM: {{.MemUsage}} | NET: {{.NetIO}}"
    
    # Tester la connectivité API
    echo ""
    echo "🌐 Test de connectivité :"
    
    if curl -s http://localhost:3001/api/discord/stats > /dev/null 2>&1; then
        echo "✅ API accessible"
        
        # Obtenir les stats Discord
        STATS=$(curl -s http://localhost:3001/api/discord/stats)
        if [ $? -eq 0 ]; then
            echo "🤖 Stats Discord : $STATS"
        fi
        
        # Tester les événements
        EVENTS=$(curl -s http://localhost:3001/api/events | jq length 2>/dev/null)
        if [ $? -eq 0 ]; then
            echo "📅 Événements chargés : $EVENTS"
        fi
    else
        echo "❌ API non accessible"
    fi
    
    echo ""
    echo "🔗 Liens d'accès :"
    echo "   📱 Site principal : http://localhost:3001"
    echo "   ⚙️  Panel admin    : http://localhost:3001/admin.html"
    echo "   🔧 Configuration  : http://localhost:3001/config.html"
    
else
    echo "❌ Conteneur : Arrêté"
    echo ""
    echo "Pour démarrer :"
    echo "   ./docker-start.sh"
fi

echo ""
echo "📋 Commandes utiles :"
echo "   docker-compose logs -f        # Logs en temps réel"
echo "   docker-compose restart        # Redémarrer"
echo "   docker-compose down           # Arrêter"
echo "   docker system prune           # Nettoyer Docker"