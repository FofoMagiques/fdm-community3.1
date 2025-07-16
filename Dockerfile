# FDM Community - Docker Container pour Synology NAS
FROM node:18-alpine

# Maintainer
LABEL maintainer="FDM Community"
LABEL description="Site communautaire FDM avec backend Node.js et bot Discord - Optimisé pour Synology DS218+"

# Installer les dépendances système optimisées pour ARM64
RUN apk add --no-cache \
    python3 \
    make \
    g++ \
    sqlite \
    curl \
    dumb-init \
    && rm -rf /var/cache/apk/* \
    && rm -rf /tmp/*

# Créer le répertoire de l'application
WORKDIR /app

# Créer un utilisateur non-root pour la sécurité (compatible Synology)
RUN addgroup -g 1001 -S fdm && \
    adduser -S fdm -u 1001 -G fdm

# Copier les fichiers de dépendances
COPY package*.json ./

# Installer les dépendances Node.js avec optimisations ARM64
RUN npm ci --only=production --no-audit --no-fund && \
    npm cache clean --force && \
    rm -rf /tmp/*

# Copier tous les fichiers de l'application
COPY . .

# Créer les répertoires nécessaires avec bonnes permissions
RUN mkdir -p /app/data /app/logs && \
    chown -R fdm:fdm /app

# Passer à l'utilisateur non-root
USER fdm

# Exposer le port
EXPOSE 3001

# Variables d'environnement optimisées pour Synology
ENV NODE_ENV=production \
    PORT=3001 \
    NODE_OPTIONS="--max-old-space-size=512" \
    UV_THREADPOOL_SIZE=4

# Script de santé optimisé pour NAS
HEALTHCHECK --interval=60s --timeout=10s --start-period=30s --retries=3 \
  CMD curl -f http://localhost:3001/api/discord/stats || exit 1

# Point d'entrée avec dumb-init pour une meilleure gestion des processus
ENTRYPOINT ["dumb-init", "--"]

# Commande de démarrage
CMD ["node", "server.js"]