#!/bin/bash

# Script de déploiement pour Synology NAS DS218+
# Optimisé pour architecture ARM64 et ressources limitées

echo "🏠 Déploiement FDM Community sur Synology NAS DS218+"
echo "=================================================="

# Configuration
CONTAINER_NAME="fdm-community"
PROJECT_NAME="fdm-community"
COMPOSE_FILE="docker-compose.yml"

# Couleurs pour les messages
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Fonction pour afficher des messages colorés
log_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

log_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

log_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

log_error() {
    echo -e "${RED}❌ $1${NC}"
}

# Vérification de l'environnement Synology
check_synology() {
    log_info "Vérification de l'environnement Synology..."
    
    # Vérifier que nous sommes sur un NAS Synology
    if [ ! -f /etc/synoinfo.conf ]; then
        log_warning "Ce script est optimisé pour Synology NAS mais peut fonctionner sur d'autres systèmes"
    else
        log_success "Environnement Synology détecté"
    fi
}

# Vérification de Docker
check_docker() {
    log_info "Vérification de Docker..."
    
    if ! command -v docker &> /dev/null; then
        log_error "Docker n'est pas installé"
        log_info "Installez Docker depuis le Centre de paquets Synology"
        exit 1
    fi
    
    if ! docker info &> /dev/null; then
        log_error "Docker n'est pas démarré"
        log_info "Démarrez Docker depuis le Centre de paquets Synology"
        exit 1
    fi
    
    log_success "Docker est prêt"
}

# Vérification de Docker Compose
check_docker_compose() {
    log_info "Vérification de Docker Compose..."
    
    if ! command -v docker-compose &> /dev/null && ! docker compose version &> /dev/null; then
        log_error "Docker Compose n'est pas disponible"
        log_info "Assurez-vous que Docker Compose est installé"
        exit 1
    fi
    
    log_success "Docker Compose est prêt"
}

# Préparation des dossiers
prepare_directories() {
    log_info "Préparation des dossiers..."
    
    # Créer les dossiers nécessaires
    mkdir -p data logs
    
    # Définir les permissions appropriées pour Synology
    chmod 755 data logs
    
    # Si nous sommes sur Synology, ajuster les permissions
    if [ -f /etc/synoinfo.conf ]; then
        # Obtenir l'UID/GID du user Docker sur Synology (généralement 1001:1001)
        chown -R 1001:1001 data logs 2>/dev/null || true
    fi
    
    log_success "Dossiers préparés"
}

# Nettoyage des anciens containers
cleanup_containers() {
    log_info "Nettoyage des anciens containers..."
    
    # Arrêter et supprimer l'ancien container s'il existe
    if docker ps -a --format "table {{.Names}}" | grep -q "^${CONTAINER_NAME}$"; then
        docker stop $CONTAINER_NAME 2>/dev/null || true
        docker rm $CONTAINER_NAME 2>/dev/null || true
        log_success "Ancien container supprimé"
    fi
    
    # Nettoyer les images non utilisées (pour économiser l'espace)
    docker image prune -f &> /dev/null || true
}

# Vérification du fichier .env
check_env_file() {
    log_info "Vérification du fichier .env..."
    
    if [ ! -f .env ]; then
        log_warning "Fichier .env manquant"
        log_info "Création d'un fichier .env par défaut..."
        
        cat > .env << EOF
# Configuration FDM Community pour Synology
DISCORD_TOKEN=MTM5MzQwNjQwNjg2NTk3NzQ3Nw.GVXMXj.apuAo9qscEnDI2G_5XoRpc1oEiGN6jygSb7LQ4
DISCORD_GUILD_ID=681602280893579342
ADMIN_PASSWORD=FofoTheBest
PORT=3001
NODE_ENV=production
TZ=Europe/Paris
EOF
        
        log_success "Fichier .env créé"
        log_warning "N'oubliez pas de modifier les valeurs dans .env selon vos besoins"
    else
        log_success "Fichier .env trouvé"
    fi
}

# Construction et démarrage
build_and_start() {
    log_info "Construction de l'image Docker..."
    
    # Utiliser docker-compose pour construire
    if command -v docker-compose &> /dev/null; then
        COMPOSE_CMD="docker-compose"
    else
        COMPOSE_CMD="docker compose"
    fi
    
    # Construire l'image
    if $COMPOSE_CMD build --no-cache; then
        log_success "Image construite avec succès"
    else
        log_error "Erreur lors de la construction de l'image"
        exit 1
    fi
    
    log_info "Démarrage du service..."
    
    # Démarrer le service
    if $COMPOSE_CMD up -d; then
        log_success "Service démarré avec succès"
    else
        log_error "Erreur lors du démarrage du service"
        exit 1
    fi
}

# Vérification du démarrage
check_startup() {
    log_info "Vérification du démarrage..."
    
    # Attendre que le service soit prêt
    sleep 15
    
    # Vérifier que le container fonctionne
    if docker ps --format "table {{.Names}}\t{{.Status}}" | grep -q "${CONTAINER_NAME}.*Up"; then
        log_success "Container en cours d'exécution"
    else
        log_error "Container non démarré"
        log_info "Vérification des logs..."
        docker logs $CONTAINER_NAME --tail=20
        exit 1
    fi
    
    # Tester la connectivité
    sleep 5
    local_ip=$(hostname -I | awk '{print $1}')
    
    if curl -s -o /dev/null -w "%{http_code}" "http://localhost:3001" | grep -q "200"; then
        log_success "Site accessible localement"
    else
        log_warning "Site non accessible localement"
    fi
}

# Affichage des informations finales
show_final_info() {
    echo ""
    echo "🎉 Déploiement terminé !"
    echo "======================"
    
    # Obtenir l'IP locale
    local_ip=$(hostname -I | awk '{print $1}')
    
    echo ""
    echo "📱 Accès au site :"
    echo "   • Local : http://localhost:3001"
    echo "   • Réseau : http://${local_ip}:3001"
    echo ""
    echo "🛠️  Pages importantes :"
    echo "   • Site : http://${local_ip}:3001"
    echo "   • Admin : http://${local_ip}:3001/admin"
    echo "   • Config : http://${local_ip}:3001/config"
    echo ""
    echo "🔧 Commandes utiles :"
    echo "   • Logs : docker logs fdm-community -f"
    echo "   • Arrêt : docker-compose down"
    echo "   • Redémarrage : docker-compose restart"
    echo "   • Statut : docker ps"
    echo ""
    echo "📁 Données persistantes :"
    echo "   • Base de données : ./data/"
    echo "   • Logs : ./logs/"
    echo ""
    echo "⚙️  Configuration :"
    echo "   • Fichier : .env"
    echo "   • Après modification : docker-compose restart"
    echo ""
    
    if [ -f /etc/synoinfo.conf ]; then
        echo "🏠 Synology NAS :"
        echo "   • Accès DSM : http://${local_ip}:5000"
        echo "   • Docker : Centre de paquets > Docker"
        echo ""
    fi
}

# Fonction principale
main() {
    echo "🚀 Début du déploiement..."
    
    check_synology
    check_docker
    check_docker_compose
    prepare_directories
    cleanup_containers
    check_env_file
    build_and_start
    check_startup
    show_final_info
    
    log_success "Déploiement terminé avec succès ! 🎉"
}

# Gestion des erreurs
trap 'log_error "Erreur lors du déploiement. Vérifiez les logs ci-dessus."' ERR

# Exécution
main "$@"