#!/bin/bash

# Service de monitoring pour FDM Community
# Fichier : monitor_fdm.sh

FDM_DIR="/app"
LOG_FILE="$FDM_DIR/monitor.log"
PID_FILE="$FDM_DIR/fdm.pid"

log_message() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOG_FILE"
}

start_server() {
    if [ -f "$PID_FILE" ]; then
        PID=$(cat "$PID_FILE")
        if kill -0 "$PID" 2>/dev/null; then
            log_message "Serveur FDM déjà en cours d'exécution (PID: $PID)"
            return 1
        else
            rm -f "$PID_FILE"
        fi
    fi
    
    cd "$FDM_DIR"
    nohup node server.js > server.log 2>&1 &
    echo $! > "$PID_FILE"
    
    sleep 3
    
    if kill -0 $(cat "$PID_FILE") 2>/dev/null; then
        log_message "Serveur FDM démarré avec succès (PID: $(cat "$PID_FILE"))"
        return 0
    else
        log_message "Erreur lors du démarrage du serveur FDM"
        rm -f "$PID_FILE"
        return 1
    fi
}

stop_server() {
    if [ -f "$PID_FILE" ]; then
        PID=$(cat "$PID_FILE")
        if kill -0 "$PID" 2>/dev/null; then
            kill "$PID"
            rm -f "$PID_FILE"
            log_message "Serveur FDM arrêté (PID: $PID)"
        else
            log_message "Aucun processus trouvé pour le PID: $PID"
            rm -f "$PID_FILE"
        fi
    else
        log_message "Aucun fichier PID trouvé"
    fi
}

check_server() {
    if [ -f "$PID_FILE" ]; then
        PID=$(cat "$PID_FILE")
        if kill -0 "$PID" 2>/dev/null; then
            # Vérifier si le serveur répond
            if curl -s http://localhost:3001/api/discord/stats > /dev/null; then
                return 0
            else
                log_message "Serveur ne répond pas, redémarrage nécessaire"
                return 1
            fi
        else
            log_message "Processus FDM non trouvé, redémarrage nécessaire"
            return 1
        fi
    else
        log_message "Fichier PID non trouvé, démarrage nécessaire"
        return 1
    fi
}

status_server() {
    if check_server; then
        echo "✅ Serveur FDM en cours d'exécution"
        PID=$(cat "$PID_FILE")
        echo "🔍 PID: $PID"
        echo "🌐 URL: http://teamfdm:3001"
        
        # Afficher les stats Discord
        STATS=$(curl -s http://localhost:3001/api/discord/stats)
        if [ $? -eq 0 ]; then
            echo "📊 Stats Discord: $STATS"
        fi
    else
        echo "❌ Serveur FDM arrêté"
    fi
}

case "$1" in
    start)
        start_server
        ;;
    stop)
        stop_server
        ;;
    restart)
        stop_server
        sleep 2
        start_server
        ;;
    status)
        status_server
        ;;
    monitor)
        log_message "Vérification du serveur FDM..."
        if ! check_server; then
            log_message "Redémarrage du serveur FDM"
            stop_server
            start_server
        fi
        ;;
    *)
        echo "Usage: $0 {start|stop|restart|status|monitor}"
        echo ""
        echo "Commandes:"
        echo "  start   - Démarrer le serveur FDM"
        echo "  stop    - Arrêter le serveur FDM"
        echo "  restart - Redémarrer le serveur FDM"
        echo "  status  - Vérifier le statut du serveur"
        echo "  monitor - Vérifier et redémarrer si nécessaire"
        exit 1
        ;;
esac