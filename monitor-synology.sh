#!/bin/bash

# Script de monitoring pour FDM Community sur Synology NAS
# Surveille les performances et l'état du service

# Configuration
CONTAINER_NAME="fdm-community"
LOG_FILE="/tmp/fdm-monitor.log"
ALERT_CPU_THRESHOLD=90
ALERT_MEMORY_THRESHOLD=90
CHECK_INTERVAL=60

# Couleurs
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Fonction de logging
log_message() {
    local level=$1
    local message=$2
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo -e "${timestamp} [$level] $message" | tee -a $LOG_FILE
}

# Vérifier l'état du container
check_container_status() {
    local status=$(docker inspect --format='{{.State.Status}}' $CONTAINER_NAME 2>/dev/null)
    local health=$(docker inspect --format='{{.State.Health.Status}}' $CONTAINER_NAME 2>/dev/null)
    
    echo -e "${BLUE}📊 État du Container${NC}"
    echo "================================"
    
    if [ "$status" = "running" ]; then
        echo -e "Status: ${GREEN}✅ Running${NC}"
    else
        echo -e "Status: ${RED}❌ $status${NC}"
        return 1
    fi
    
    if [ "$health" = "healthy" ]; then
        echo -e "Health: ${GREEN}✅ Healthy${NC}"
    elif [ "$health" = "unhealthy" ]; then
        echo -e "Health: ${RED}❌ Unhealthy${NC}"
    else
        echo -e "Health: ${YELLOW}⚠️  $health${NC}"
    fi
    
    echo ""
    return 0
}

# Surveiller les ressources
monitor_resources() {
    echo -e "${BLUE}📈 Utilisation des Ressources${NC}"
    echo "================================"
    
    # Obtenir les stats du container
    local stats=$(docker stats $CONTAINER_NAME --no-stream --format "table {{.CPUPerc}}\t{{.MemUsage}}\t{{.MemPerc}}\t{{.NetIO}}\t{{.BlockIO}}")
    
    if [ $? -eq 0 ]; then
        echo "$stats"
        
        # Extraire les valeurs pour les alertes
        local cpu_percent=$(docker stats $CONTAINER_NAME --no-stream --format "{{.CPUPerc}}" | sed 's/%//')
        local mem_percent=$(docker stats $CONTAINER_NAME --no-stream --format "{{.MemPerc}}" | sed 's/%//')
        
        # Vérifier les seuils d'alerte
        if (( $(echo "$cpu_percent > $ALERT_CPU_THRESHOLD" | bc -l) )); then
            log_message "ALERT" "CPU usage is high: ${cpu_percent}%"
            echo -e "${RED}🚨 ALERTE: CPU élevé (${cpu_percent}%)${NC}"
        fi
        
        if (( $(echo "$mem_percent > $ALERT_MEMORY_THRESHOLD" | bc -l) )); then
            log_message "ALERT" "Memory usage is high: ${mem_percent}%"
            echo -e "${RED}🚨 ALERTE: Mémoire élevée (${mem_percent}%)${NC}"
        fi
    else
        echo -e "${RED}❌ Impossible d'obtenir les stats${NC}"
    fi
    
    echo ""
}

# Vérifier la connectivité
check_connectivity() {
    echo -e "${BLUE}🌐 Test de Connectivité${NC}"
    echo "================================"
    
    # Test local
    if curl -s -o /dev/null -w "%{http_code}" http://localhost:3001 | grep -q "200"; then
        echo -e "Site local: ${GREEN}✅ Accessible${NC}"
    else
        echo -e "Site local: ${RED}❌ Inaccessible${NC}"
        log_message "ERROR" "Site not accessible locally"
    fi
    
    # Test API
    if curl -s -o /dev/null -w "%{http_code}" http://localhost:3001/api/discord/stats | grep -q "200"; then
        echo -e "API Discord: ${GREEN}✅ Fonctionnelle${NC}"
    else
        echo -e "API Discord: ${RED}❌ Erreur${NC}"
        log_message "ERROR" "Discord API not working"
    fi
    
    # Test admin
    if curl -s -o /dev/null -w "%{http_code}" http://localhost:3001/admin | grep -q "200"; then
        echo -e "Panel admin: ${GREEN}✅ Accessible${NC}"
    else
        echo -e "Panel admin: ${RED}❌ Inaccessible${NC}"
        log_message "ERROR" "Admin panel not accessible"
    fi
    
    echo ""
}

# Vérifier les logs récents
check_logs() {
    echo -e "${BLUE}📋 Logs Récents (5 dernières lignes)${NC}"
    echo "================================"
    
    docker logs $CONTAINER_NAME --tail=5 2>/dev/null || echo "Impossible d'obtenir les logs"
    echo ""
}

# Informations système Synology
synology_info() {
    echo -e "${BLUE}🏠 Informations Synology${NC}"
    echo "================================"
    
    # Température du CPU (si disponible)
    if command -v synosetkeyvalue &> /dev/null; then
        local temp=$(synosetkeyvalue /usr/syno/etc/esynoscheduler/esynoscheduler.xml temp_warn_threshold 2>/dev/null || echo "N/A")
        echo "Température CPU: ${temp}°C"
    fi
    
    # Espace disque
    local disk_usage=$(df -h / | tail -1 | awk '{print $5}' | sed 's/%//')
    echo "Utilisation disque: ${disk_usage}%"
    
    if [ "$disk_usage" -gt 85 ]; then
        echo -e "${RED}🚨 ALERTE: Espace disque faible${NC}"
        log_message "ALERT" "Disk space is low: ${disk_usage}%"
    fi
    
    # Mémoire système
    local mem_info=$(free -h | grep ^Mem | awk '{print $3 "/" $2}')
    echo "Mémoire système: $mem_info"
    
    echo ""
}

# Diagnostic complet
run_diagnostics() {
    echo -e "${YELLOW}🔍 Diagnostic Complet${NC}"
    echo "================================"
    
    # Vérifier les fichiers critiques
    local critical_files=(
        "./data/fdm_database.db"
        "./logs"
        "./.env"
        "./server.js"
        "./package.json"
    )
    
    echo "Fichiers critiques:"
    for file in "${critical_files[@]}"; do
        if [ -e "$file" ]; then
            echo -e "  ${GREEN}✅${NC} $file"
        else
            echo -e "  ${RED}❌${NC} $file"
        fi
    done
    
    # Vérifier les ports
    echo ""
    echo "Ports réseau:"
    if netstat -tlnp 2>/dev/null | grep -q ":3001"; then
        echo -e "  ${GREEN}✅${NC} Port 3001 ouvert"
    else
        echo -e "  ${RED}❌${NC} Port 3001 fermé"
    fi
    
    echo ""
}

# Fonction principale
main() {
    local mode=${1:-"status"}
    
    echo "🏠 FDM Community - Monitoring Synology NAS"
    echo "=========================================="
    echo "Container: $CONTAINER_NAME"
    echo "Timestamp: $(date)"
    echo ""
    
    case $mode in
        "status"|"s")
            check_container_status
            ;;
        "resources"|"r")
            monitor_resources
            ;;
        "connectivity"|"c")
            check_connectivity
            ;;
        "logs"|"l")
            check_logs
            ;;
        "synology"|"syn")
            synology_info
            ;;
        "full"|"f")
            check_container_status
            monitor_resources
            check_connectivity
            check_logs
            synology_info
            run_diagnostics
            ;;
        "watch"|"w")
            echo "Mode surveillance activé (Ctrl+C pour arrêter)"
            while true; do
                clear
                main "full"
                echo ""
                echo "Prochaine mise à jour dans ${CHECK_INTERVAL}s..."
                sleep $CHECK_INTERVAL
            done
            ;;
        "help"|"h")
            echo "Utilisation: $0 [option]"
            echo ""
            echo "Options:"
            echo "  status, s      - État du container"
            echo "  resources, r   - Utilisation des ressources"
            echo "  connectivity, c - Test de connectivité"
            echo "  logs, l        - Logs récents"
            echo "  synology, syn  - Informations Synology"
            echo "  full, f        - Diagnostic complet"
            echo "  watch, w       - Mode surveillance continue"
            echo "  help, h        - Aide"
            ;;
        *)
            echo "Option inconnue: $mode"
            main "help"
            ;;
    esac
}

# Vérifier que le container existe
if ! docker ps -a --format "{{.Names}}" | grep -q "^$CONTAINER_NAME$"; then
    echo -e "${RED}❌ Container '$CONTAINER_NAME' non trouvé${NC}"
    exit 1
fi

# Exécuter le monitoring
main "$@"