# 🏠 FDM Community - Synology NAS DS218+

## 📊 Configuration Optimisée

Cette version est spécifiquement optimisée pour le **Synology DS218+** avec :
- **Architecture ARM64** (Realtek RTD1296)
- **Optimisations mémoire** (512MB max)
- **Gestion des ressources** adaptée aux NAS
- **Sécurité renforcée** pour environnement réseau

## 🚀 Démarrage Rapide

### 1. Installation automatique
```bash
# Déploiement complet optimisé Synology
./deploy-synology.sh
```

### 2. Installation manuelle
```bash
# Configuration standard
docker-compose up -d

# Configuration haute performance
docker-compose -f docker-compose.performance.yml up -d
```

## 📁 Fichiers Spécifiques Synology

| Fichier | Description |
|---------|-------------|
| `deploy-synology.sh` | Script de déploiement automatique |
| `docker-compose.performance.yml` | Configuration haute performance |
| `monitor-synology.sh` | Monitoring des ressources |
| `SYNOLOGY-INSTALL.md` | Guide d'installation détaillé |

## 🔧 Scripts Utiles

### Déploiement
```bash
./deploy-synology.sh          # Déploiement complet
```

### Monitoring
```bash
./monitor-synology.sh status  # État du service
./monitor-synology.sh full    # Diagnostic complet
./monitor-synology.sh watch   # Surveillance continue
```

### Maintenance
```bash
# Redémarrage optimisé
docker-compose restart

# Nettoyage et redémarrage
docker-compose down && docker-compose up -d

# Mise à jour
docker-compose pull && docker-compose up -d
```

## 🌐 Accès

Une fois déployé sur votre NAS :

- **Site principal :** `http://IP_NAS:3001`
- **Panel admin :** `http://IP_NAS:3001/admin`
- **Configuration :** `http://IP_NAS:3001/config`

## 📊 Spécifications Techniques

### Limites de Ressources
```yaml
CPU: 1.0 core max (0.5 core réservé)
RAM: 512MB max (256MB réservé)
Stockage: Optimisé SSD/HDD
```

### Optimisations Node.js
```env
NODE_OPTIONS=--max-old-space-size=384
UV_THREADPOOL_SIZE=4
NODE_MAX_PARALLEL_JOBS=2
```

## 🔒 Sécurité

- **Utilisateur non-root** (1001:1001)
- **Réseau isolé** (172.20.0.0/16)
- **Logs limités** (5MB max)
- **Pas de privilèges supplémentaires**

## 📈 Monitoring

### Surveillance des ressources
```bash
# Monitoring en temps réel
./monitor-synology.sh watch

# Vérification rapide
./monitor-synology.sh status
```

### Métriques importantes
- **CPU** : < 90% en utilisation normale
- **RAM** : < 400MB en utilisation normale
- **Santé** : Container healthy
- **Réseau** : Port 3001 accessible

## 🛠️ Dépannage

### Problèmes fréquents
1. **Container ne démarre pas** : Vérifiez les logs
2. **Manque de mémoire** : Redémarrez le NAS
3. **Port occupé** : Changez le port dans docker-compose.yml
4. **Permissions** : Vérifiez les droits sur ./data et ./logs

### Commandes de diagnostic
```bash
# Logs détaillés
docker logs fdm-community -f

# État des ressources
docker stats fdm-community

# Santé du container
docker inspect fdm-community
```

## 📞 Support Spécifique Synology

### Logs système
- **DSM :** Centre de journalisation
- **Docker :** DSM > Docker > Container > Details
- **Application :** `docker logs fdm-community`

### Configuration réseau
- **Pare-feu :** Ouvrir port 3001
- **Reverse proxy :** Optionnel pour HTTPS
- **DDNS :** Pour accès externe

## 🔄 Mise à jour

```bash
# Sauvegarde des données
cp -r data data.backup

# Mise à jour
docker-compose pull
docker-compose up -d

# Vérification
./monitor-synology.sh status
```

## 📋 Checklist Post-Installation

- [ ] Container démarré et healthy
- [ ] Site accessible sur port 3001
- [ ] Panel admin fonctionnel
- [ ] API Discord connectée
- [ ] Données persistantes sauvegardées
- [ ] Monitoring configuré
- [ ] Logs en rotation
- [ ] Sauvegardes planifiées

---

*Configuration optimisée pour Synology DS218+ - ARM64 🏠*