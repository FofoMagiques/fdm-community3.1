# FDM Community - Docker Container
FROM node:18-alpine

# Maintainer
LABEL maintainer="FDM Community"
LABEL description="Site communautaire FDM avec backend Node.js et bot Discord"

# Installer les dépendances système
RUN apk add --no-cache \
    python3 \
    make \
    g++ \
    sqlite \
    curl \
    && rm -rf /var/cache/apk/*

# Créer le répertoire de l'application
WORKDIR /app

# Copier les fichiers de dépendances
COPY package*.json ./

# Installer les dépendances Node.js
RUN npm install && npm cache clean --force

# Copier tous les fichiers de l'application
COPY . .

# Créer le répertoire pour les données persistantes
RUN mkdir -p /app/data

# Créer un utilisateur non-root pour la sécurité
RUN addgroup -g 1001 -S fdm && \
    adduser -S fdm -u 1001 -G fdm

# Donner les permissions appropriées
RUN chown -R fdm:fdm /app
USER fdm

# Exposer le port
EXPOSE 3001

# Variables d'environnement par défaut
ENV NODE_ENV=production
ENV PORT=3001

# Script de santé pour Docker
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD curl -f http://localhost:3001/api/discord/stats || exit 1

# Commande de démarrage
CMD ["node", "server.js"]