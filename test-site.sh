#!/bin/bash

# Test complet du site FDM Community
# Ce script vérifie que tous les composants fonctionnent correctement

echo "🧪 Test du site FDM Community..."

# Fonction pour tester une URL
test_url() {
    local url=$1
    local name=$2
    local expected_code=${3:-200}
    
    echo -n "Testing $name... "
    
    status_code=$(curl -s -o /dev/null -w "%{http_code}" "$url" 2>/dev/null)
    
    if [ "$status_code" = "$expected_code" ]; then
        echo "✅ OK ($status_code)"
        return 0
    else
        echo "❌ FAIL ($status_code, expected $expected_code)"
        return 1
    fi
}

# Vérifier que le serveur fonctionne
if ! pgrep -f "node server.js" > /dev/null; then
    echo "⚠️  Le serveur n'est pas en cours d'exécution. Démarrage..."
    nohup node server.js > server.log 2>&1 &
    sleep 5
fi

# Attendre que le serveur soit prêt
echo "⏳ Attente du serveur..."
sleep 3

# Tests des pages principales
echo "🌐 Test des pages web:"
test_url "http://localhost:3001/" "Page d'accueil"
test_url "http://localhost:3001/admin" "Panel admin"
test_url "http://localhost:3001/config" "Configuration"

# Tests des fichiers statiques
echo "📁 Test des fichiers statiques:"
test_url "http://localhost:3001/style.css" "Fichier CSS"
test_url "http://localhost:3001/script.js" "Fichier JavaScript"

# Tests de l'API
echo "🔌 Test de l'API:"
test_url "http://localhost:3001/api/events" "API Événements"
test_url "http://localhost:3001/api/discord/stats" "API Discord Stats"

# Test du contenu CSS
echo "🎨 Test du contenu CSS:"
css_content=$(curl -s "http://localhost:3001/style.css" 2>/dev/null)
if echo "$css_content" | grep -q "fdm-dark"; then
    echo "✅ Le CSS contient les styles FDM"
else
    echo "❌ Le CSS ne contient pas les styles FDM"
fi

# Test du contenu JavaScript
echo "⚡ Test du contenu JavaScript:"
js_content=$(curl -s "http://localhost:3001/script.js" 2>/dev/null)
if echo "$js_content" | grep -q "FDM Community"; then
    echo "✅ Le JavaScript contient les fonctions FDM"
else
    echo "❌ Le JavaScript ne contient pas les fonctions FDM"
fi

# Test de la base de données
echo "🗄️  Test de la base de données:"
if [ -f "data/fdm_database.db" ] || [ -f "fdm_database.db" ]; then
    echo "✅ Base de données SQLite présente"
else
    echo "❌ Base de données SQLite manquante"
fi

# Test des événements
echo "🎮 Test des événements:"
events_response=$(curl -s "http://localhost:3001/api/events" 2>/dev/null)
if echo "$events_response" | grep -q "Minecraft\|Valorant"; then
    echo "✅ Les événements de test sont présents"
else
    echo "❌ Les événements de test sont manquants"
fi

# Test des logs
echo "📋 Test des logs:"
if [ -f "server.log" ]; then
    echo "✅ Fichier de log présent"
    echo "Dernières lignes du log:"
    tail -3 server.log
else
    echo "❌ Fichier de log manquant"
fi

echo ""
echo "🎯 Résumé des tests terminé !"
echo "🔗 Accédez au site sur : http://localhost:3001"
echo "🛠️  Panel admin : http://localhost:3001/admin"
echo "⚙️  Configuration : http://localhost:3001/config"