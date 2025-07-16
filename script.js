// FDM Community - Main JavaScript

// Events data (sera chargé depuis l'API)
let events = [];

// State management
let participatingEvents = new Set();
let participationCounters = {};
let currentUsername = localStorage.getItem('fdm_username') || '';

// API Functions
async function loadEvents() {
    try {
        const response = await fetch('/api/events');
        events = await response.json();
        
        // Initialiser les compteurs de participation
        events.forEach(event => {
            participationCounters[event.id] = event.current_participants;
        });
        
        renderEvents();
    } catch (error) {
        console.error('Erreur lors du chargement des événements:', error);
        showNotification('Erreur lors du chargement des événements', 'error');
    }
}

async function updateDiscordStats() {
    try {
        const response = await fetch('/api/discord/stats');
        const stats = await response.json();
        
        const memberCount = document.getElementById('member-count');
        const onlineCount = document.getElementById('online-count');
        
        if (memberCount && onlineCount) {
            memberCount.textContent = stats.memberCount;
            onlineCount.textContent = stats.onlineCount;
        }
    } catch (error) {
        console.error('Erreur lors de la mise à jour des stats Discord:', error);
    }
}

async function participateInEvent(eventId) {
    if (!currentUsername) {
        const username = prompt('Entre ton pseudo pour participer :');
        if (!username || username.length < 3) {
            showNotification('Pseudo invalide (minimum 3 caractères)', 'error');
            return;
        }
        currentUsername = username;
        localStorage.setItem('fdm_username', username);
    }
    
    try {
        const response = await fetch(`/api/events/${eventId}/participate`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
            },
            body: JSON.stringify({ username: currentUsername }),
        });
        
        const data = await response.json();
        
        if (data.success) {
            if (data.participating) {
                participatingEvents.add(eventId);
                participationCounters[eventId] = (participationCounters[eventId] || 0) + 1;
            } else {
                participatingEvents.delete(eventId);
                participationCounters[eventId] = Math.max(0, (participationCounters[eventId] || 0) - 1);
            }
            
            updateEventButtons();
            updateParticipationCounters();
            showNotification(data.message, 'success');
            
            // Sauvegarder l'état
            localStorage.setItem('fdm_participating_events', JSON.stringify(Array.from(participatingEvents)));
        } else {
            showNotification(data.error || 'Erreur lors de la participation', 'error');
        }
    } catch (error) {
        console.error('Erreur lors de la participation:', error);
        showNotification('Erreur lors de la participation', 'error');
    }
}

async function downloadLauncher(eventId) {
    if (!currentUsername) {
        handleDownload(events.find(e => e.id === eventId)?.title || 'Événement', eventId);
        return;
    }
    
    try {
        const response = await fetch(`/api/events/${eventId}/download`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
            },
            body: JSON.stringify({ username: currentUsername }),
        });
        
        const data = await response.json();
        
        if (data.success) {
            showNotification(`Téléchargement enregistré ! Le launcher sera bientôt disponible.`, 'success');
            // Ici tu peux ajouter la logique pour télécharger le fichier
            // window.open(data.downloadUrl, '_blank');
        } else {
            showNotification(data.error || 'Erreur lors du téléchargement', 'error');
        }
    } catch (error) {
        console.error('Erreur lors du téléchargement:', error);
        showNotification('Erreur lors du téléchargement', 'error');
    }
}
// Utility functions
function formatDate(dateString) {
    const date = new Date(dateString);
    return date.toLocaleDateString('fr-FR', {
        weekday: 'long',
        year: 'numeric',
        month: 'long',
        day: 'numeric'
    });
}

function getCategoryClass(category) {
    const categoryClasses = {
        Gaming: "badge-gaming",
        Esport: "badge-esport",
        Social: "badge-social",
        Créatif: "badge-creative"
    };
    return categoryClasses[category] || "badge-gaming";
}

function getStatusClass(status) {
    const statusClasses = {
        upcoming: "badge-upcoming",
        ongoing: "badge-ongoing",
        past: "badge-past"
    };
    return statusClasses[status] || "badge-upcoming";
}

function getStatusText(status) {
    const statusTexts = {
        upcoming: "À venir",
        ongoing: "En cours",
        past: "Terminé"
    };
    return statusTexts[status] || "Inconnu";
}

// Event handling functions
function handleJoinServer() {
    // Animation du bouton
    const btn = document.getElementById('join-server-btn');
    btn.style.transform = 'scale(0.95)';
    
    setTimeout(() => {
        btn.style.transform = 'scale(1)';
        // Ouvre le Discord
        window.open("https://discord.gg/uamaVGnVJ2", "_blank");
        showNotification("Redirection vers Discord... 🚀", "success");
    }, 150);
}

function handleParticipate(eventId, eventTitle) {
    participateInEvent(eventId);
}

function handleDownload(eventTitle, eventId) {
    const modal = document.getElementById('username-modal');
    const input = document.getElementById('username-input');
    const confirmBtn = document.getElementById('username-confirm');
    
    // Store event info for confirmation
    confirmBtn.dataset.eventId = eventId;
    confirmBtn.dataset.eventTitle = eventTitle;
    
    // Show modal
    modal.style.display = 'block';
    input.focus();
    
    // Clear previous input
    input.value = '';
}

function confirmDownload() {
    const input = document.getElementById('username-input');
    const username = input.value.trim();
    const confirmBtn = document.getElementById('username-confirm');
    const eventTitle = confirmBtn.dataset.eventTitle;
    const eventId = parseInt(confirmBtn.dataset.eventId);
    
    if (!username) {
        showNotification("Tu dois entrer un pseudo ! 🤔", "error");
        input.focus();
        return;
    }
    
    if (username.length < 3) {
        showNotification("Ton pseudo doit faire au moins 3 caractères ! 😅", "error");
        input.focus();
        return;
    }
    
    // Close modal
    document.getElementById('username-modal').style.display = 'none';
    
    // Sauvegarder le pseudo
    currentUsername = username;
    localStorage.setItem('fdm_username', username);
    
    // Lancer le téléchargement
    downloadLauncher(eventId);
}

function updateEventButtons() {
    const participateButtons = document.querySelectorAll('[data-event-id]');
    participateButtons.forEach(button => {
        const eventId = parseInt(button.dataset.eventId);
        const isParticipating = participatingEvents.has(eventId);
        
        if (isParticipating) {
            button.innerHTML = `
                <svg width="16" height="16" viewBox="0 0 24 24" fill="currentColor">
                    <path d="M9 16.17L4.83 12l-1.42 1.41L9 19 21 7l-1.41-1.41z"/>
                </svg>
                Inscrit !
            `;
            button.className = "btn btn-participating";
        } else {
            button.innerHTML = `
                <svg width="16" height="16" viewBox="0 0 24 24" fill="currentColor">
                    <path d="M19 13h-6v6h-2v-6H5v-2h6V5h2v6h6v2z"/>
                </svg>
                Participer
            `;
            button.className = "btn btn-participate";
        }
    });
}

function updateParticipationCounters() {
    // Update counters in event cards
    events.forEach(event => {
        const counterElement = document.getElementById(`counter-${event.id}`);
        if (counterElement) {
            const count = participationCounters[event.id] || event.participants;
            counterElement.textContent = count;
            
            // Add animation
            counterElement.parentElement.classList.add('participation-counter');
            setTimeout(() => {
                counterElement.parentElement.classList.remove('participation-counter');
            }, 2000);
        }
    });
}

// Notification system
function showNotification(message, type = "info") {
    // Remove existing notifications
    const existingNotification = document.querySelector('.notification');
    if (existingNotification) {
        existingNotification.remove();
    }

    // Create notification element
    const notification = document.createElement('div');
    notification.className = `notification notification-${type}`;
    
    // Get icon based on type
    const icons = {
        success: '✅',
        error: '❌',
        info: '💡'
    };
    
    notification.innerHTML = `
        <div class="notification-content">
            <span class="notification-icon">${icons[type] || icons.info}</span>
            <span class="notification-message">${message}</span>
            <button class="notification-close">&times;</button>
        </div>
    `;

    // Add styles
    const colors = {
        success: 'linear-gradient(135deg, #4caf50 0%, #66bb6a 100%)',
        error: 'linear-gradient(135deg, #f44336 0%, #ef5350 100%)',
        info: 'linear-gradient(135deg, #e91e63 0%, #f06292 100%)'
    };
    
    notification.style.cssText = `
        position: fixed;
        top: 20px;
        right: 20px;
        background: ${colors[type] || colors.info};
        color: white;
        padding: 1rem 1.5rem;
        border-radius: 0.75rem;
        box-shadow: 0 8px 32px rgba(0, 0, 0, 0.3);
        backdrop-filter: blur(10px);
        z-index: 1000;
        max-width: 350px;
        animation: slideIn 0.4s ease;
        border: 1px solid rgba(255, 255, 255, 0.1);
    `;

    // Add animation styles
    const style = document.createElement('style');
    style.textContent = `
        @keyframes slideIn {
            from { transform: translateX(100%); opacity: 0; }
            to { transform: translateX(0); opacity: 1; }
        }
        .notification-content {
            display: flex;
            align-items: center;
            gap: 0.75rem;
        }
        .notification-icon {
            font-size: 1.2rem;
        }
        .notification-message {
            flex: 1;
            font-weight: 500;
        }
        .notification-close {
            background: none;
            border: none;
            color: white;
            font-size: 1.5rem;
            cursor: pointer;
            padding: 0;
            width: 24px;
            height: 24px;
            display: flex;
            align-items: center;
            justify-content: center;
            border-radius: 50%;
            transition: background-color 0.2s ease;
        }
        .notification-close:hover {
            background-color: rgba(255, 255, 255, 0.2);
        }
    `;
    document.head.appendChild(style);

    // Add to page
    document.body.appendChild(notification);

    // Add close functionality
    const closeButton = notification.querySelector('.notification-close');
    closeButton.addEventListener('click', () => {
        notification.remove();
    });

    // Auto remove after 5 seconds
    setTimeout(() => {
        if (notification.parentNode) {
            notification.remove();
        }
    }, 5000);
}

// Render events
function renderEvents() {
    const upcomingEvents = events.filter(event => event.status === 'upcoming');
    const upcomingEventsContainer = document.getElementById('upcoming-events');
    const noEventsContainer = document.getElementById('no-events');

    if (upcomingEvents.length === 0) {
        document.querySelector('.events-upcoming').style.display = 'none';
        noEventsContainer.style.display = 'block';
        return;
    }

    document.querySelector('.events-upcoming').style.display = 'block';
    noEventsContainer.style.display = 'none';

    upcomingEventsContainer.innerHTML = upcomingEvents.map(event => {
        const isParticipating = participatingEvents.has(event.id);
        const currentCount = participationCounters[event.id] || event.current_participants || 0;
        
        return `
            <div class="event-card">
                <div class="event-header">
                    <span class="event-badge ${getCategoryClass(event.category)}">${event.category}</span>
                    <span class="event-badge ${getStatusClass(event.status)}">${getStatusText(event.status)}</span>
                </div>
                
                <h3 class="event-title">${event.title}</h3>
                
                <div class="event-meta">
                    <div class="event-meta-item">
                        <span>📅</span>
                        <span>${formatDate(event.date)}</span>
                    </div>
                    <div class="event-meta-item">
                        <span>🕐</span>
                        <span>${event.time}</span>
                    </div>
                </div>
                
                <p class="event-description">${event.description}</p>
                
                <div class="event-stats">
                    <span>👥 <span id="counter-${event.id}">${currentCount}</span> participants</span>
                    ${event.max_participants ? `<span>Max: ${event.max_participants}</span>` : ''}
                </div>
                
                <div class="event-actions">
                    <button 
                        class="btn ${isParticipating ? 'btn-participating' : 'btn-participate'}" 
                        data-event-id="${event.id}"
                        onclick="handleParticipate(${event.id}, '${event.title}')"
                    >
                        ${isParticipating ? 
                            `<svg width="16" height="16" viewBox="0 0 24 24" fill="currentColor">
                                <path d="M9 16.17L4.83 12l-1.42 1.41L9 19 21 7l-1.41-1.41z"/>
                            </svg>
                            Inscrit !` : 
                            `<svg width="16" height="16" viewBox="0 0 24 24" fill="currentColor">
                                <path d="M19 13h-6v6h-2v-6H5v-2h6V5h2v6h6v2z"/>
                            </svg>
                            Participer`
                        }
                    </button>
                    
                    ${event.has_download ? `
                        <button 
                            class="btn btn-download" 
                            onclick="downloadLauncher(${event.id})"
                        >
                            📥 ${event.download_text || 'Télécharger'}
                        </button>
                    ` : ''}
                </div>
            </div>
        `;
    }).join('');
}

// Load saved participating events from localStorage
function loadParticipatingEvents() {
    try {
        const savedEvents = localStorage.getItem('fdm_participating_events');
        const savedCounters = localStorage.getItem('fdm_participation_counters');
        
        if (savedEvents) {
            const eventIds = JSON.parse(savedEvents);
            participatingEvents = new Set(eventIds);
        }
        
        if (savedCounters) {
            participationCounters = JSON.parse(savedCounters);
        }
    } catch (error) {
        console.error('Error loading saved data:', error);
        participatingEvents = new Set();
        // Reinitialize counters
        events.forEach(event => {
            participationCounters[event.id] = event.participants;
        });
    }
}

// Smooth scroll functionality
function initSmoothScroll() {
    document.querySelectorAll('a[href^="#"]').forEach(anchor => {
        anchor.addEventListener('click', function (e) {
            e.preventDefault();
            const target = document.querySelector(this.getAttribute('href'));
            if (target) {
                target.scrollIntoView({
                    behavior: 'smooth',
                    block: 'start'
                });
            }
        });
    });
}

// Initialize animations on scroll
function initScrollAnimations() {
    const observerOptions = {
        threshold: 0.1,
        rootMargin: '0px 0px -50px 0px'
    };

    const observer = new IntersectionObserver((entries) => {
        entries.forEach(entry => {
            if (entry.isIntersecting) {
                entry.target.style.opacity = '1';
                entry.target.style.transform = 'translateY(0)';
            }
        });
    }, observerOptions);

    // Observe elements for animation
    document.querySelectorAll('.stat-card, .event-card, .server-info-card').forEach(el => {
        el.style.opacity = '0';
        el.style.transform = 'translateY(20px)';
        el.style.transition = 'opacity 0.6s ease, transform 0.6s ease';
        observer.observe(el);
    });
}

// Update live stats (réel maintenant)
function updateLiveStats() {
    updateDiscordStats();
    // Mise à jour toutes les 2 minutes
    setTimeout(updateLiveStats, 120000);
}

// Modal functionality
function initModal() {
    const modal = document.getElementById('username-modal');
    const closeBtn = document.querySelector('.modal-close');
    const cancelBtn = document.getElementById('username-cancel');
    const confirmBtn = document.getElementById('username-confirm');
    const input = document.getElementById('username-input');
    
    // Close modal events
    closeBtn.addEventListener('click', () => {
        modal.style.display = 'none';
    });
    
    cancelBtn.addEventListener('click', () => {
        modal.style.display = 'none';
    });
    
    confirmBtn.addEventListener('click', confirmDownload);
    
    // Close modal when clicking outside
    window.addEventListener('click', (event) => {
        if (event.target === modal) {
            modal.style.display = 'none';
        }
    });
    
    // Handle Enter key in input
    input.addEventListener('keypress', (event) => {
        if (event.key === 'Enter') {
            confirmDownload();
        }
    });
}

// Initialize the application
function initApp() {
    // Load saved data
    loadParticipatingEvents();
    
    // Load events from API
    loadEvents();
    
    // Update Discord stats
    updateDiscordStats();
    
    // Bind event handlers
    const joinServerBtn = document.getElementById('join-server-btn');
    if (joinServerBtn) {
        joinServerBtn.addEventListener('click', handleJoinServer);
    }
    
    // Initialize other features
    initSmoothScroll();
    initScrollAnimations();
    initModal();
    updateLiveStats();
    
    // Welcome message
    if (currentUsername) {
        setTimeout(() => {
            showNotification(`Salut ${currentUsername} ! Content de te revoir ! 👋`, "success");
        }, 1000);
    }
    
    console.log('🎮 FDM Community website initialized with backend!');
}

// Wait for DOM to be fully loaded
if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', initApp);
} else {
    initApp();
}