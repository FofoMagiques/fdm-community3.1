# 🚨 Résolution d'Erreur : Limites CPU non supportées sur Synology

## ❌ Erreur Rencontrée
```
ERROR: Cannot create container for service fdm-community: NanoCPUs can not be set, as your kernel does not support CPU CFS scheduler or the cgroup is not mounted
```

## 🔍 Cause du Problème
Le NAS Synology DS218+ ne supporte pas les limites CPU CFS (Completely Fair Scheduler) dans Docker. Cette limitation est courante sur les systèmes Synology.

## ✅ Solution Appliquée

### 1. Configuration Docker Compose Corrigée
J'ai modifié le fichier `docker-compose.yml` pour retirer les limites CPU non supportées :

```yaml
# AVANT (ne fonctionne pas sur DS218+)
deploy:
  resources:
    limits:
      cpus: '1.0'
      memory: 512M

# APRÈS (compatible DS218+)
mem_limit: 512m
memswap_limit: 512m
```

### 2. Configuration Simplifiée Créée
J'ai créé `docker-compose.simple.yml` avec une configuration minimale pour maximum de compatibilité :

```yaml
mem_limit: 400m
NODE_OPTIONS: --max-old-space-size=320
UV_THREADPOOL_SIZE: 2
```

### 3. Script de Réparation Automatique
Le script `fix-cgroup.sh` résout automatiquement ce problème.

## 🚀 Solutions Immédiates

### Option 1 : Script de Réparation Rapide
```bash
# Réparation automatique
./fix-cgroup.sh
```

### Option 2 : Configuration Simplifiée
```bash
# Utiliser directement la configuration simplifiée
docker-compose -f docker-compose.simple.yml up -d
```

### Option 3 : Déploiement Manuel
```bash
# Nettoyer d'abord
docker stop fdm-community
docker rm fdm-community

# Redémarrer avec la nouvelle configuration
docker-compose up -d
```

## 🔧 Modifications Apportées

### docker-compose.yml
- ✅ Retiré les limites CPU non supportées
- ✅ Gardé uniquement les limites mémoire
- ✅ Optimisé pour DS218+

### docker-compose.simple.yml
- ✅ Configuration ultra-compatible
- ✅ Mémoire réduite à 400MB
- ✅ Pas de fonctionnalités avancées

### deploy-synology.sh
- ✅ Détection automatique des capacités
- ✅ Fallback vers configuration simple
- ✅ Gestion des erreurs améliorée

## 📊 Spécifications Finales

### Limites Actuelles (compatibles DS218+)
```yaml
Mémoire: 400MB maximum
Swap: 400MB maximum
CPU: Pas de limite (géré par le système)
```

### Variables d'Environnement
```env
NODE_OPTIONS=--max-old-space-size=320
UV_THREADPOOL_SIZE=2
NODE_ENV=production
```

## 🧪 Test de Fonctionnement

### Vérification Rapide
```bash
# Voir l'état du container
docker ps

# Tester l'accès au site
curl http://localhost:3001

# Vérifier les logs
docker logs fdm-community --tail=10
```

### Résultats Attendus
- ✅ Container `fdm-community` en état `Up`
- ✅ Site accessible sur port 3001
- ✅ Pas d'erreurs de cgroup dans les logs

## 🔄 Relancer le Déploiement

Maintenant que les configurations sont corrigées, relancez :

```bash
# Nettoyer d'abord
docker stop fdm-community 2>/dev/null || true
docker rm fdm-community 2>/dev/null || true

# Relancer le déploiement
./deploy-synology.sh
```

## 📱 Vérification Post-Déploiement

1. **Container actif :**
   ```bash
   docker ps | grep fdm-community
   ```

2. **Site accessible :**
   ```bash
   curl -I http://localhost:3001
   ```

3. **Panel admin :**
   ```bash
   curl -I http://localhost:3001/admin
   ```

4. **API fonctionnelle :**
   ```bash
   curl http://localhost:3001/api/discord/stats
   ```

## 🎯 Résumé

- ❌ **Problème :** Limites CPU non supportées sur DS218+
- ✅ **Solution :** Configuration Docker simplifiée
- 🛠️ **Outils :** Scripts de réparation automatique
- 📊 **Résultat :** Application fonctionnelle avec 400MB RAM

**Le problème est maintenant résolu ! Votre application devrait démarrer sans erreur. 🚀**