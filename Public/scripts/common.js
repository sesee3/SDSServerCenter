/**
 * COMMON.JS - Funzionalità condivise tra tutte le pagine
 * Include: gestione tema, autenticazione, utilità comuni
 */

/* ===================================
 * GESTIONE AUTENTICAZIONE
 * =================================== */

/**
 * Ottiene il token JWT dal localStorage
 */
function getToken() {
    return localStorage.getItem('JAUTHENTICATION');
}

/**
 * Ottiene l'utente corrente dal localStorage
 */
function getCurrentUser() {
    const userStr = localStorage.getItem('currentUser');
    return userStr ? JSON.parse(userStr) : null;
}

/**
 * Verifica se l'utente è autenticato
 */
function isAuthenticated() {
    const token = getToken();
    const user = getCurrentUser();
    return !!(token && user && user.username);
}

/**
 * Reindirizza al login se l'utente non è autenticato
 */
function requireAuth() {
    if (!isAuthenticated()) {
        window.location.href = '/signin';
        return false;
    }
    return true;
}

/**
 * Effettua il logout
 */
async function logout() {
    const token = getToken();
    
    if (token) {
        try {
            await fetch('/api/v1/auth/logout', {
                method: 'POST',
                headers: {
                    'Authorization': `Bearer ${token}`
                }
            });
        } catch (error) {
            console.error('Errore durante il logout:', error);
        }
    }
    
    // Pulisci il localStorage
    localStorage.removeItem('JAUTHENTICATION');
    localStorage.removeItem('currentUser');
    localStorage.removeItem('theme');
    
    // Reindirizza al login
    window.location.href = '/signin';
}

/**
 * Mostra il nome utente nell'elemento specificato
 */
function displayUsername(elementId) {
    const user = getCurrentUser();
    if (user && user.username) {
        const element = document.getElementById(elementId);
        if (element) {
            element.textContent = user.username;
        }
    }
}

/* ===================================
 * GESTIONE TEMA (Light/Dark/Auto)
 * =================================== */

/**
 * Applica il tema specificato
 */
function applyTheme(theme) {
    let actualTheme;

    if (theme === 'auto') {
        const prefersDark = window.matchMedia('(prefers-color-scheme: dark)').matches;
        if (prefersDark) {
            document.documentElement.dataset.theme = 'dark';
            actualTheme = 'dark';
        } else {
            document.documentElement.removeAttribute('data-theme');
            actualTheme = 'light';
        }
    } else if (theme === 'light') {
        document.documentElement.removeAttribute('data-theme');
        actualTheme = 'light';
    } else {
        document.documentElement.dataset.theme = 'dark';
        actualTheme = 'dark';
    }

    // Aggiorna l'icona attiva nello switcher (se presente)
    const themeIcons = document.querySelectorAll('.theme-icon');
    themeIcons.forEach(icon => {
        icon.classList.remove('active');
    });

    const selectedIcon = document.getElementById(`theme${theme.charAt(0).toUpperCase() + theme.slice(1)}`);
    if (selectedIcon) {
        selectedIcon.classList.add('active');
    }
}

/**
 * Imposta e salva il tema scelto
 */
function setTheme(theme) {
    localStorage.setItem('theme', theme);
    applyTheme(theme);
}

/**
 * Inizializza il tema al caricamento della pagina
 */
function initTheme() {
    const savedTheme = localStorage.getItem('theme') || 'auto';
    applyTheme(savedTheme);

    // Ascolta i cambiamenti del tema di sistema
    window.matchMedia('(prefers-color-scheme: dark)').addEventListener('change', () => {
        const currentTheme = localStorage.getItem('theme') || 'auto';
        if (currentTheme === 'auto') {
            applyTheme('auto');
        }
    });
}

/**
 * Crea il componente theme switcher
 */
function createThemeSwitcher() {
    return `
        <div class="theme-switcher-custom">
            <button id="themeAuto" class="theme-icon active" onclick="setTheme('auto')" title="Tema automatico">
                <svg width="18" height="18" viewBox="0 0 71 90" fill="currentColor" stroke="currentColor" stroke-width="2" stroke-linecap="round" xmlns="http://www.w3.org/2000/svg">
                    <path d="M5.34961 89.5254C2.12695 89.5254 0 87.6562 0 84.6914C0 83.4023 0.322266 82.1777 0.837891 80.6309L27.3281 6.57422C28.9395 2.0625 31.1953 0 35.3203 0C39.4453 0 41.7012 2.0625 43.3125 6.57422L69.8027 80.6309C70.3184 82.0488 70.6406 83.4023 70.6406 84.627C70.6406 87.6562 68.5137 89.5254 65.2266 89.5254C62.1328 89.5254 60.3926 88.043 59.168 84.2402L51.7559 62.2617H18.8203L11.4082 84.2402C10.1836 88.1074 8.44336 89.5254 5.34961 89.5254ZM21.8496 53.1738H48.7266L35.5137 13.9863H35.0625L21.8496 53.1738Z"/>
                </svg>
            </button>
            <button id="themeLight" class="theme-icon" onclick="setTheme('light')" title="Tema chiaro">
                <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                    <circle cx="12" cy="12" r="5"></circle>
                    <line x1="12" y1="1" x2="12" y2="3"></line>
                    <line x1="12" y1="21" x2="12" y2="23"></line>
                    <line x1="4.22" y1="4.22" x2="5.64" y2="5.64"></line>
                    <line x1="18.36" y1="18.36" x2="19.78" y2="19.78"></line>
                    <line x1="1" y1="12" x2="3" y2="12"></line>
                    <line x1="21" y1="12" x2="23" y2="12"></line>
                    <line x1="4.22" y1="19.78" x2="5.64" y2="18.36"></line>
                    <line x1="18.36" y1="5.64" x2="19.78" y2="4.22"></line>
                </svg>
            </button>
            <button id="themeDark" class="theme-icon" onclick="setTheme('dark')" title="Tema scuro">
                <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                    <path d="M21 12.79A9 9 0 1 1 11.21 3 7 7 0 0 0 21 12.79z"></path>
                </svg>
            </button>
        </div>
    `;
}

/* ===================================
 * UTILITÀ COMUNI
 * =================================== */

/**
 * Escape HTML per prevenire XSS
 */
function escapeHtml(text) {
    if (typeof text !== 'string') return '';
    const map = {
        "&": "&amp;",
        "<": "&lt;",
        ">": "&gt;",
        '"': "&quot;",
        "'": "&#039;",
    };
    return text.replace(/[&<>"']/g, (m) => map[m]);
}

/**
 * Formatta una data in formato locale
 */
function formatDate(dateString) {
    if (!dateString) return "";
    const date = new Date(dateString);
    return date.toLocaleDateString('it-IT', {
        day: 'numeric',
        month: 'long',
        year: 'numeric'
    });
}

/**
 * Formatta una data e ora in formato locale
 */
function formatDateTime(dateString) {
    if (!dateString) return "";
    const date = new Date(dateString);
    return date.toLocaleString('it-IT');
}

/**
 * Gestisce gli errori delle API
 */
async function handleApiError(response) {
    if (response.status === 401) {
        logout();
        return;
    }
    
    let errorMessage = 'Si è verificato un errore';
    try {
        const data = await response.json();
        errorMessage = data.reason || data.message || errorMessage;
    } catch (e) {
        // Se non riesce a parsare il JSON, usa il messaggio di default
    }
    
    throw new Error(errorMessage);
}

/**
 * Mostra un messaggio di alert
 */
function showAlert(message, type = 'error') {
    const alertDiv = document.createElement('div');
    alertDiv.className = `alert alert-${type}`;
    alertDiv.textContent = message;
    
    // Cerca un container per gli alert o usa il body
    const container = document.querySelector('.container') || document.body;
    container.insertBefore(alertDiv, container.firstChild);
    
    // Rimuovi dopo 5 secondi
    setTimeout(() => {
        alertDiv.remove();
    }, 5000);
}

/* ===================================
 * INIZIALIZZAZIONE
 * =================================== */

// Inizializza il tema quando il DOM è pronto
document.addEventListener('DOMContentLoaded', () => {
    initTheme();
});

// Gestisci la chiusura dei modals con ESC
document.addEventListener('keydown', (e) => {
    if (e.key === 'Escape') {
        const modals = document.querySelectorAll('.modal.active');
        modals.forEach(modal => modal.classList.remove('active'));
    }
});
