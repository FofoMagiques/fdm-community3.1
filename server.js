const express = require('express');
const { Client, GatewayIntentBits } = require('discord.js');
const sqlite3 = require('sqlite3').verbose();
const cors = require('cors');
const bcrypt = require('bcrypt');
const rateLimit = require('express-rate-limit');
const helmet = require('helmet');
const path = require('path');
const fs = require('fs');
require('dotenv').config();

const app = express();
const PORT = process.env.PORT || 3001;

// Créer le répertoire data s'il n'existe pas
const dataDir = '/app/data';
if (!fs.existsSync(dataDir)) {
    fs.mkdirSync(dataDir, { recursive: true });
}

// Base de données dans le volume persistant
const dbPath = path.join(dataDir, 'fdm_database.db');

// Middleware de sécurité
app.use(helmet({
    contentSecurityPolicy: {
        directives: {
            defaultSrc: ["'self'"],
            styleSrc: ["'self'", "'unsafe-inline'", "https://fonts.googleapis.com"],
            fontSrc: ["'self'", "https://fonts.gstatic.com"],
            scriptSrc: ["'self'", "'unsafe-inline'"],
            imgSrc: ["'self'", "data:", "https:"],
            connectSrc: ["'self'"]
        }
    },
    crossOriginEmbedderPolicy: false
}));

app.use(cors());
app.use(express.json());
app.use(express.static(path.join(__dirname)));

// Routes pour les pages statiques
app.get('/', (req, res) => {
    res.sendFile(path.join(__dirname, 'index.html'));
});

app.get('/admin', (req, res) => {
    res.sendFile(path.join(__dirname, 'admin.html'));
});

app.get('/config', (req, res) => {
    res.sendFile(path.join(__dirname, 'config.html'));
});

// Rate limiting
const limiter = rateLimit({
    windowMs: 15 * 60 * 1000, // 15 minutes
    max: 100 // limite par IP
});
app.use('/api/', limiter);

// Discord Bot Setup
const client = new Client({
    intents: [
        GatewayIntentBits.Guilds,
        GatewayIntentBits.GuildMembers,
        GatewayIntentBits.GuildPresences
    ]
});

// Variables globales pour les stats Discord
let discordStats = {
    memberCount: 95,
    onlineCount: 12,
    lastUpdate: Date.now()
};

// Initialisation de la base de données SQLite
const db = new sqlite3.Database(dbPath);

// Création des tables
db.serialize(() => {
    // Table des événements
    db.run(`CREATE TABLE IF NOT EXISTS events (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        description TEXT,
        date TEXT NOT NULL,
        time TEXT NOT NULL,
        category TEXT DEFAULT 'Gaming',
        max_participants INTEGER,
        status TEXT DEFAULT 'upcoming',
        has_download BOOLEAN DEFAULT 0,
        download_text TEXT,
        created_at DATETIME DEFAULT CURRENT_TIMESTAMP
    )`);

    // Table des participations
    db.run(`CREATE TABLE IF NOT EXISTS participations (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        event_id INTEGER,
        username TEXT NOT NULL,
        participated_at DATETIME DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (event_id) REFERENCES events (id)
    )`);

    // Table des téléchargements
    db.run(`CREATE TABLE IF NOT EXISTS downloads (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        event_id INTEGER,
        username TEXT NOT NULL,
        downloaded_at DATETIME DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (event_id) REFERENCES events (id)
    )`);

    // Insérer des événements d'exemple s'ils n'existent pas
    db.get("SELECT COUNT(*) as count FROM events", (err, row) => {
        if (row.count === 0) {
            const sampleEvents = [
                {
                    title: "Serveur Minecraft RP - Collab Epic",
                    description: "On lance notre serveur Minecraft RP en collaboration avec une autre team ! Télécharge notre launcher custom pour une expérience de ouf avec des mods exclusifs. Ça va être légendaire ! 🔥",
                    date: "2025-03-15",
                    time: "20:00",
                    category: "Gaming",
                    max_participants: 80,
                    has_download: 1,
                    download_text: "Télécharger le launcher"
                },
                {
                    title: "Tournoi Valorant FDM",
                    description: "Le tournoi annuel FDM revient ! Équipes de 5, format BO3, et des prix de malade à gagner. Inscris ton équipe et viens montrer de quoi tu es capable !",
                    date: "2025-03-22",
                    time: "18:00",
                    category: "Gaming",
                    max_participants: 40,
                    has_download: 0
                }
            ];

            const insertStmt = db.prepare(`INSERT INTO events (title, description, date, time, category, max_participants, has_download, download_text) VALUES (?, ?, ?, ?, ?, ?, ?, ?)`);
            sampleEvents.forEach(event => {
                insertStmt.run(event.title, event.description, event.date, event.time, event.category, event.max_participants, event.has_download, event.download_text);
            });
            insertStmt.finalize();
        }
    });
});

// Connexion Discord Bot
client.once('ready', () => {
    console.log(`🤖 Bot Discord connecté : ${client.user.tag}`);
    updateDiscordStats();
    // Mise à jour des stats toutes les 2 minutes
    setInterval(updateDiscordStats, 120000);
});

// Fonction pour mettre à jour les stats Discord
async function updateDiscordStats() {
    try {
        const guild = client.guilds.cache.get(process.env.DISCORD_GUILD_ID);
        if (guild) {
            const members = await guild.members.fetch();
            const onlineMembers = members.filter(member => 
                member.presence?.status === 'online' || 
                member.presence?.status === 'idle' || 
                member.presence?.status === 'dnd'
            );
            
            discordStats = {
                memberCount: guild.memberCount,
                onlineCount: onlineMembers.size,
                lastUpdate: Date.now()
            };
            
            console.log(`📊 Stats mises à jour : ${discordStats.memberCount} membres, ${discordStats.onlineCount} en ligne`);
        }
    } catch (error) {
        console.error('Erreur lors de la mise à jour des stats:', error);
    }
}

// ========== ROUTES API ==========

// Stats Discord
app.get('/api/discord/stats', (req, res) => {
    res.json(discordStats);
});

// Récupérer tous les événements
app.get('/api/events', (req, res) => {
    db.all(`SELECT e.*, COUNT(p.id) as current_participants 
            FROM events e 
            LEFT JOIN participations p ON e.id = p.event_id 
            WHERE e.status = 'upcoming' 
            GROUP BY e.id 
            ORDER BY e.date ASC`, (err, rows) => {
        if (err) {
            console.error(err);
            return res.status(500).json({ error: 'Erreur base de données' });
        }
        res.json(rows);
    });
});

// Participer à un événement
app.post('/api/events/:id/participate', (req, res) => {
    const { username } = req.body;
    const eventId = req.params.id;
    
    if (!username || username.length < 3) {
        return res.status(400).json({ error: 'Nom d\'utilisateur invalide' });
    }
    
    // Vérifier si l'utilisateur participe déjà
    db.get(`SELECT * FROM participations WHERE event_id = ? AND username = ?`, 
           [eventId, username], (err, row) => {
        if (err) {
            console.error(err);
            return res.status(500).json({ error: 'Erreur base de données' });
        }
        
        if (row) {
            // Désinscrire l'utilisateur
            db.run(`DELETE FROM participations WHERE event_id = ? AND username = ?`, 
                   [eventId, username], function(err) {
                if (err) {
                    console.error(err);
                    return res.status(500).json({ error: 'Erreur lors de la désinscription' });
                }
                res.json({ success: true, participating: false, message: 'Désinscrit avec succès' });
            });
        } else {
            // Inscrire l'utilisateur
            db.run(`INSERT INTO participations (event_id, username) VALUES (?, ?)`, 
                   [eventId, username], function(err) {
                if (err) {
                    console.error(err);
                    return res.status(500).json({ error: 'Erreur lors de l\'inscription' });
                }
                res.json({ success: true, participating: true, message: 'Inscrit avec succès' });
            });
        }
    });
});

// Télécharger le launcher
app.post('/api/events/:id/download', (req, res) => {
    const { username } = req.body;
    const eventId = req.params.id;
    
    if (!username || username.length < 3) {
        return res.status(400).json({ error: 'Nom d\'utilisateur invalide' });
    }
    
    // Enregistrer le téléchargement
    db.run(`INSERT OR REPLACE INTO downloads (event_id, username) VALUES (?, ?)`, 
           [eventId, username], function(err) {
        if (err) {
            console.error(err);
            return res.status(500).json({ error: 'Erreur lors de l\'enregistrement' });
        }
        
        // Ici tu peux ajouter la logique pour servir le fichier
        res.json({ 
            success: true, 
            message: 'Téléchargement enregistré',
            downloadUrl: `/downloads/launcher-${eventId}.zip` // Exemple
        });
    });
});

// ========== ROUTES ADMIN ==========

// Configuration (endpoint pour la page config.html)
app.post('/api/admin/config', (req, res) => {
    const { guildId, inviteLink } = req.body;
    
    if (!guildId || !/^\d{17,19}$/.test(guildId)) {
        return res.status(400).json({ error: 'ID de serveur invalide' });
    }
    
    // Mettre à jour le fichier .env
    const fs = require('fs');
    let envContent = fs.readFileSync('.env', 'utf8');
    
    // Remplacer ou ajouter DISCORD_GUILD_ID
    if (envContent.includes('DISCORD_GUILD_ID=')) {
        envContent = envContent.replace(/DISCORD_GUILD_ID=.*/, `DISCORD_GUILD_ID=${guildId}`);
    } else {
        envContent += `\nDISCORD_GUILD_ID=${guildId}`;
    }
    
    // Optionnel : sauvegarder le lien d'invitation
    if (inviteLink) {
        if (envContent.includes('DISCORD_INVITE_LINK=')) {
            envContent = envContent.replace(/DISCORD_INVITE_LINK=.*/, `DISCORD_INVITE_LINK=${inviteLink}`);
        } else {
            envContent += `\nDISCORD_INVITE_LINK=${inviteLink}`;
        }
    }
    
    fs.writeFileSync('.env', envContent);
    
    res.json({ success: true, message: 'Configuration sauvegardée' });
});

// Test de connexion Guild
app.get('/api/admin/test-guild/:guildId', async (req, res) => {
    const { guildId } = req.params;
    
    try {
        const guild = client.guilds.cache.get(guildId);
        if (!guild) {
            return res.status(404).json({ 
                error: 'Serveur non trouvé. Assure-toi que le bot est bien sur ce serveur.' 
            });
        }
        
        const memberCount = guild.memberCount;
        const guildName = guild.name;
        
        res.json({ 
            success: true, 
            guildName, 
            memberCount,
            message: `Connexion réussie au serveur ${guildName}` 
        });
    } catch (error) {
        console.error('Erreur test guild:', error);
        res.status(500).json({ error: 'Erreur lors du test de connexion' });
    }
});

// Authentification admin simple
app.post('/api/admin/login', async (req, res) => {
    const { password } = req.body;
    
    if (password === process.env.ADMIN_PASSWORD) {
        res.json({ success: true, token: 'admin-authenticated' });
    } else {
        res.status(401).json({ error: 'Mot de passe incorrect' });
    }
});

// Créer un événement (admin)
app.post('/api/admin/events', (req, res) => {
    const { title, description, date, time, category, max_participants, has_download, download_text } = req.body;
    
    db.run(`INSERT INTO events (title, description, date, time, category, max_participants, has_download, download_text) 
            VALUES (?, ?, ?, ?, ?, ?, ?, ?)`, 
           [title, description, date, time, category || 'Gaming', max_participants, has_download ? 1 : 0, download_text],
           function(err) {
        if (err) {
            console.error(err);
            return res.status(500).json({ error: 'Erreur lors de la création' });
        }
        res.json({ success: true, id: this.lastID });
    });
});

// Modifier un événement (admin)
app.put('/api/admin/events/:id', (req, res) => {
    const { title, description, date, time, category, max_participants, has_download, download_text } = req.body;
    const eventId = req.params.id;
    
    db.run(`UPDATE events SET title = ?, description = ?, date = ?, time = ?, category = ?, 
            max_participants = ?, has_download = ?, download_text = ? WHERE id = ?`,
           [title, description, date, time, category, max_participants, has_download ? 1 : 0, download_text, eventId],
           function(err) {
        if (err) {
            console.error(err);
            return res.status(500).json({ error: 'Erreur lors de la modification' });
        }
        res.json({ success: true });
    });
});

// Supprimer un événement (admin)
app.delete('/api/admin/events/:id', (req, res) => {
    const eventId = req.params.id;
    
    db.run(`DELETE FROM events WHERE id = ?`, [eventId], function(err) {
        if (err) {
            console.error(err);
            return res.status(500).json({ error: 'Erreur lors de la suppression' });
        }
        res.json({ success: true });
    });
});

// Liste des téléchargements (admin)
app.get('/api/admin/downloads', (req, res) => {
    db.all(`SELECT d.*, e.title as event_title 
            FROM downloads d 
            JOIN events e ON d.event_id = e.id 
            ORDER BY d.downloaded_at DESC`, (err, rows) => {
        if (err) {
            console.error(err);
            return res.status(500).json({ error: 'Erreur base de données' });
        }
        res.json(rows);
    });
});

// Démarrage du serveur
app.listen(PORT, () => {
    console.log(`🌍 Serveur FDM démarré sur le port ${PORT}`);
    console.log(`🔗 Accès local : http://localhost:${PORT}`);
});

// Connexion du bot Discord
client.login(process.env.DISCORD_TOKEN).catch(console.error);

// Gestion propre de l'arrêt
process.on('SIGINT', () => {
    console.log('\n🛑 Arrêt du serveur...');
    db.close();
    client.destroy();
    process.exit(0);
});