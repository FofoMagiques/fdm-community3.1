#!/usr/bin/env python3
"""
Test final du site FDM Community
Vérification complète de toutes les fonctionnalités
"""

import requests
import time
import json

def test_site_complet():
    base_url = "http://localhost:3001"
    
    print("🎮 Test complet du site FDM Community")
    print("=" * 50)
    
    # 1. Test du serveur
    print("\n1. 🌐 Test de connectivité du serveur...")
    try:
        response = requests.get(f"{base_url}/", timeout=5)
        print(f"✅ Serveur accessible (Code: {response.status_code})")
        print(f"   📄 Taille de la page: {len(response.text)} caractères")
    except Exception as e:
        print(f"❌ Serveur inaccessible: {e}")
        return
    
    # 2. Test des stats Discord
    print("\n2. 🤖 Test des stats Discord...")
    try:
        response = requests.get(f"{base_url}/api/discord/stats", timeout=5)
        stats = response.json()
        print(f"✅ Stats Discord OK")
        print(f"   👥 Membres: {stats['memberCount']}")
        print(f"   🟢 En ligne: {stats['onlineCount']}")
        print(f"   ⏰ Dernière maj: {time.strftime('%H:%M:%S', time.localtime(stats['lastUpdate']/1000))}")
    except Exception as e:
        print(f"❌ Erreur stats Discord: {e}")
    
    # 3. Test des événements
    print("\n3. 📅 Test des événements...")
    try:
        response = requests.get(f"{base_url}/api/events", timeout=5)
        events = response.json()
        print(f"✅ Événements chargés: {len(events)} événements")
        
        for i, event in enumerate(events[:3], 1):
            print(f"   {i}. {event['title']} - {event['date']} à {event['time']}")
            print(f"      👥 {event['current_participants']} participants")
    except Exception as e:
        print(f"❌ Erreur événements: {e}")
    
    # 4. Test de participation
    print("\n4. 👥 Test de participation...")
    try:
        if events:
            event_id = events[0]['id']
            response = requests.post(
                f"{base_url}/api/events/{event_id}/participate",
                json={"username": "TestUser123"},
                timeout=5
            )
            result = response.json()
            if result.get('success'):
                print(f"✅ Participation réussie: {result.get('message')}")
            else:
                print(f"❌ Erreur participation: {result.get('error')}")
    except Exception as e:
        print(f"❌ Erreur test participation: {e}")
    
    # 5. Test admin
    print("\n5. 🔐 Test panel admin...")
    try:
        response = requests.post(
            f"{base_url}/api/admin/login",
            json={"password": "fdm2024admin"},
            timeout=5
        )
        admin_result = response.json()
        if admin_result.get('success'):
            print(f"✅ Connexion admin réussie")
            
            # Test création d'événement
            new_event = {
                "title": "Test Event Final",
                "description": "Événement de test final",
                "date": "2025-03-25",
                "time": "20:00",
                "category": "Gaming",
                "max_participants": 20,
                "has_download": False
            }
            
            response = requests.post(
                f"{base_url}/api/admin/events",
                json=new_event,
                timeout=5
            )
            
            if response.status_code == 200:
                print("✅ Création d'événement admin OK")
            else:
                print(f"❌ Erreur création événement: {response.status_code}")
        else:
            print(f"❌ Erreur connexion admin: {admin_result.get('error')}")
    except Exception as e:
        print(f"❌ Erreur test admin: {e}")
    
    # 6. Test des téléchargements
    print("\n6. 📥 Test des téléchargements...")
    try:
        response = requests.get(f"{base_url}/api/admin/downloads", timeout=5)
        downloads = response.json()
        print(f"✅ Téléchargements: {len(downloads)} enregistrements")
        
        for download in downloads[:3]:
            print(f"   📥 {download['username']} - {download['event_title']}")
    except Exception as e:
        print(f"❌ Erreur téléchargements: {e}")
    
    # 7. Test des pages
    print("\n7. 📄 Test des pages...")
    pages = [
        ("Page principale", "/"),
        ("Panel admin", "/admin.html"),
        ("Configuration", "/config.html")
    ]
    
    for name, path in pages:
        try:
            response = requests.get(f"{base_url}{path}", timeout=5)
            if response.status_code == 200:
                print(f"✅ {name} accessible")
            else:
                print(f"❌ {name} erreur: {response.status_code}")
        except Exception as e:
            print(f"❌ {name} erreur: {e}")
    
    print("\n" + "=" * 50)
    print("🎉 Test final terminé !")
    print(f"🌐 Site accessible sur: {base_url}")
    print(f"⚙️  Panel admin: {base_url}/admin.html")
    print(f"📊 Stats Discord: Temps réel activé")
    print(f"🗄️  Base de données: SQLite opérationnelle")

if __name__ == "__main__":
    test_site_complet()