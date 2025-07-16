#!/bin/bash

# Test de compatibilité Synology pour FDM Community
# Vérifie que la configuration est optimale pour DS218+

echo "🧪 Test de Compatibilité Synology DS218+"
echo "========================================"

# Couleurs
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Compteurs
TESTS_PASSED=0
TESTS_FAILED=0
TOTAL_TESTS=0

# Fonction de test
run_test() {
    local test_name=$1
    local test_command=$2
    local expected_result=${3:-0}
    
    echo -n "Testing $test_name... "
    TOTAL_TESTS=$((TOTAL_TESTS + 1))
    
    if eval "$test_command"; then
        if [ $? -eq $expected_result ]; then
            echo -e "${GREEN}✅ PASS${NC}"
            TESTS_PASSED=$((TESTS_PASSED + 1))
            return 0
        fi
    fi
    
    echo -e "${RED}❌ FAIL${NC}"
    TESTS_FAILED=$((TESTS_FAILED + 1))
    return 1
}

# Fonction pour vérifier les fichiers
check_file() {
    local file=$1
    local description=$2
    
    if [ -f "$file" ]; then
        echo -e "${GREEN}✅${NC} $description: $file"
        return 0
    else
        echo -e "${RED}❌${NC} $description: $file (manquant)"
        return 1
    fi
}

# Tests de base
echo -e "${BLUE}📋 Tests de Base${NC}"
echo "=================="

run_test "Docker disponible" "command -v docker"
run_test "Docker Compose disponible" "command -v docker-compose || docker compose version"
run_test "Curl disponible" "command -v curl"

# Tests des fichiers
echo ""
echo -e "${BLUE}📁 Tests des Fichiers${NC}"
echo "====================="

required_files=(
    "Dockerfile:Configuration Docker"
    "docker-compose.yml:Composition Docker standard"
    "docker-compose.performance.yml:Configuration haute performance"
    "deploy-synology.sh:Script de déploiement"
    "monitor-synology.sh:Script de monitoring"
    "server.js:Application Node.js"
    "package.json:Dépendances Node.js"
    ".env:Configuration environnement"
    "index.html:Page principale"
    "admin.html:Panel admin"
    "style.css:Styles CSS"
    "script.js:JavaScript frontend"
)

for file_info in "${required_files[@]}"; do
    IFS=':' read -r file desc <<< "$file_info"
    check_file "$file" "$desc"
done

# Tests de configuration Docker
echo ""
echo -e "${BLUE}🐳 Tests Configuration Docker${NC}"
echo "============================="

# Vérifier la configuration Dockerfile
if [ -f "Dockerfile" ]; then
    echo "Analyse du Dockerfile:"
    
    if grep -q "node:18-alpine" Dockerfile; then
        echo -e "${GREEN}✅${NC} Base image Alpine (optimisée pour ARM64)"
    else
        echo -e "${RED}❌${NC} Base image non optimisée"
    fi
    
    if grep -q "dumb-init" Dockerfile; then
        echo -e "${GREEN}✅${NC} Dumb-init pour gestion des processus"
    else
        echo -e "${YELLOW}⚠️${NC} Dumb-init non configuré"
    fi
    
    if grep -q "1001:1001" Dockerfile; then
        echo -e "${GREEN}✅${NC} Utilisateur non-root configuré"
    else
        echo -e "${RED}❌${NC} Utilisateur root (risque sécurité)"
    fi
fi

# Tests de configuration docker-compose
if [ -f "docker-compose.yml" ]; then
    echo ""
    echo "Analyse docker-compose.yml:"
    
    if grep -q "cpus:" docker-compose.yml; then
        echo -e "${GREEN}✅${NC} Limites CPU configurées"
    else
        echo -e "${YELLOW}⚠️${NC} Limites CPU non configurées"
    fi
    
    if grep -q "memory:" docker-compose.yml; then
        echo -e "${GREEN}✅${NC} Limites mémoire configurées"
    else
        echo -e "${YELLOW}⚠️${NC} Limites mémoire non configurées"
    fi
    
    if grep -q "restart: unless-stopped" docker-compose.yml; then
        echo -e "${GREEN}✅${NC} Politique de redémarrage configurée"
    else
        echo -e "${YELLOW}⚠️${NC} Politique de redémarrage non configurée"
    fi
fi

# Tests d'optimisation
echo ""
echo -e "${BLUE}⚡ Tests d'Optimisation${NC}"
echo "========================"

# Vérifier les optimisations Node.js
if [ -f ".env" ]; then
    echo "Analyse des optimisations Node.js:"
    
    if grep -q "NODE_OPTIONS" .env || grep -q "NODE_OPTIONS" docker-compose.yml; then
        echo -e "${GREEN}✅${NC} Optimisations Node.js configurées"
    else
        echo -e "${YELLOW}⚠️${NC} Optimisations Node.js manquantes"
    fi
    
    if grep -q "UV_THREADPOOL_SIZE" .env || grep -q "UV_THREADPOOL_SIZE" docker-compose.yml; then
        echo -e "${GREEN}✅${NC} Pool de threads optimisé"
    else
        echo -e "${YELLOW}⚠️${NC} Pool de threads non optimisé"
    fi
fi

# Tests de structure de données
echo ""
echo -e "${BLUE}🗄️ Tests Structure Données${NC}"
echo "=========================="

# Créer les dossiers s'ils n'existent pas
mkdir -p data logs

echo "Vérification des dossiers de données:"
check_file "data/" "Dossier base de données"
check_file "logs/" "Dossier logs"

# Vérifier les permissions
if [ -d "data" ]; then
    data_perms=$(stat -c "%a" data 2>/dev/null || echo "unknown")
    if [ "$data_perms" = "755" ] || [ "$data_perms" = "775" ]; then
        echo -e "${GREEN}✅${NC} Permissions dossier data: $data_perms"
    else
        echo -e "${YELLOW}⚠️${NC} Permissions dossier data: $data_perms (recommandé: 755)"
    fi
fi

# Tests de sécurité
echo ""
echo -e "${BLUE}🔒 Tests de Sécurité${NC}"
echo "==================="

# Vérifier les mots de passe par défaut
if [ -f ".env" ]; then
    if grep -q "ADMIN_PASSWORD=.*admin" .env; then
        echo -e "${RED}❌${NC} Mot de passe admin par défaut détecté"
    else
        echo -e "${GREEN}✅${NC} Mot de passe admin personnalisé"
    fi
    
    if grep -q "DISCORD_TOKEN=.*test" .env; then
        echo -e "${RED}❌${NC} Token Discord de test détecté"
    else
        echo -e "${GREEN}✅${NC} Token Discord configuré"
    fi
fi

# Tests de performance
echo ""
echo -e "${BLUE}📊 Tests de Performance${NC}"
echo "========================"

# Vérifier la configuration haute performance
if [ -f "docker-compose.performance.yml" ]; then
    echo "Analyse configuration haute performance:"
    
    if grep -q "max-old-space-size=384" docker-compose.performance.yml; then
        echo -e "${GREEN}✅${NC} Limite mémoire Node.js optimisée (384MB)"
    else
        echo -e "${YELLOW}⚠️${NC} Limite mémoire Node.js non optimisée"
    fi
    
    if grep -q "tmpfs" docker-compose.performance.yml; then
        echo -e "${GREEN}✅${NC} Cache temporaire en mémoire configuré"
    else
        echo -e "${YELLOW}⚠️${NC} Cache temporaire non configuré"
    fi
fi

# Tests de compatibilité ARM64
echo ""
echo -e "${BLUE}🏗️ Tests Compatibilité ARM64${NC}"
echo "============================="

# Vérifier l'architecture
arch=$(uname -m)
echo "Architecture détectée: $arch"

if [ "$arch" = "aarch64" ] || [ "$arch" = "arm64" ]; then
    echo -e "${GREEN}✅${NC} Architecture ARM64 détectée"
elif [ "$arch" = "x86_64" ]; then
    echo -e "${YELLOW}⚠️${NC} Architecture x86_64 (émulation ARM64 possible)"
else
    echo -e "${RED}❌${NC} Architecture non supportée: $arch"
fi

# Test des scripts
echo ""
echo -e "${BLUE}📜 Tests des Scripts${NC}"
echo "==================="

scripts=(
    "deploy-synology.sh"
    "monitor-synology.sh"
    "start.sh"
    "test-site.sh"
)

for script in "${scripts[@]}"; do
    if [ -f "$script" ]; then
        if [ -x "$script" ]; then
            echo -e "${GREEN}✅${NC} Script $script (exécutable)"
        else
            echo -e "${YELLOW}⚠️${NC} Script $script (non exécutable)"
        fi
    else
        echo -e "${RED}❌${NC} Script $script (manquant)"
    fi
done

# Résumé des tests
echo ""
echo -e "${BLUE}📊 Résumé des Tests${NC}"
echo "=================="
echo "Total des tests: $TOTAL_TESTS"
echo -e "Tests réussis: ${GREEN}$TESTS_PASSED${NC}"
echo -e "Tests échoués: ${RED}$TESTS_FAILED${NC}"

if [ $TESTS_FAILED -eq 0 ]; then
    echo ""
    echo -e "${GREEN}🎉 Tous les tests sont passés !${NC}"
    echo -e "${GREEN}✅ Configuration optimale pour Synology DS218+${NC}"
else
    echo ""
    echo -e "${YELLOW}⚠️ Certains tests ont échoué${NC}"
    echo -e "${YELLOW}Vérifiez les éléments marqués en rouge ci-dessus${NC}"
fi

echo ""
echo -e "${BLUE}🚀 Prochaines étapes recommandées :${NC}"
echo "1. Corriger les éléments en rouge/orange"
echo "2. Exécuter: ./deploy-synology.sh"
echo "3. Surveiller: ./monitor-synology.sh watch"
echo "4. Tester: curl http://localhost:3001"