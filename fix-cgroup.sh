#!/bin/bash

# Script de réparation rapide pour les problèmes de compatibilité Synology
# Résout les problèmes de cgroup et de limites CPU

echo "🔧 Réparation des problèmes de compatibilité Synology"
echo "===================================================="

# Nettoyage des containers et images
echo "🧹 Nettoyage des containers existants..."
docker stop fdm-community 2>/dev/null || true
docker rm fdm-community 2>/dev/null || true

# Nettoyer les images
echo "🗑️ Nettoyage des images..."
docker rmi fdm-community_fdm-community 2>/dev/null || true

# Essayer la configuration simplifiée
echo "🚀 Démarrage avec configuration simplifiée..."
if docker-compose -f docker-compose.simple.yml up -d; then
    echo "✅ Service démarré avec succès (configuration simplifiée)"
    
    # Attendre le démarrage
    echo "⏳ Attente du démarrage..."
    sleep 15
    
    # Vérifier l'état
    if docker ps | grep -q fdm-community; then
        echo "✅ Container en cours d'exécution"
        
        # Tester l'accès
        if curl -s -o /dev/null -w "%{http_code}" http://localhost:3001 | grep -q "200"; then
            echo "✅ Site accessible sur http://localhost:3001"
        else
            echo "⚠️ Site en cours de démarrage, testez dans quelques secondes"
        fi
    else
        echo "❌ Container non démarré"
        echo "Logs du container :"
        docker logs fdm-community --tail=20
    fi
else
    echo "❌ Échec du démarrage"
    echo "Vérifiez les logs ci-dessus"
fi

echo ""
echo "🎯 Réparation terminée"
echo "🔗 Site : http://localhost:3001"
echo "📊 Logs : docker logs fdm-community -f"