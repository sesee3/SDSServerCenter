const API_URL = "/api/v1/"

const token = localStorage.getItem('JAUTHENTICATION');

console.log("Loaded token:", token);

const currentUser = JSON.parse(localStorage.getItem('currentUser') || '{}');

    // Verifica autenticazione
    if (!token || !currentUser.username) {
        window.location.href = '/signin';
    }

    let conferences = [];
    let currentConference = null;
    let editMode = false;
    let attendeesArray = [];
    let contactsArray = [];

    const allAvailableDays = [
        
        { date: '2025-12-18', label: '18 Dicembre' },
        { date: '2025-12-19', label: '19 Dicembre' }
    ];
    let availabilitySlotsArray = [];

    const daySelectorDefaultText = "Seleziona un giorno da aggiungere";
    let currentSelectedDay = null;

        document.getElementById("appScreen").style.display = "block";
        document.getElementById("currentUser").textContent = currentUser.username;
        loadConferences();

    // Conferences
    async function loadConferences() {
        try {
            const response = await fetch(`${API_URL}conferences`, {
                headers: {
                    Authorization: `Bearer ${token}`,
                },
            });

            if (!response.ok) {
                if (response.status === 401) {
                    logout();
                    return;
                }
                throw new Error("Impossibile caricare le conferenze");
            }

            conferences = await response.json();
            renderConferences();
        } catch (error) {
            console.error("Errore nel caricamento delle conferenze:", error);
            document.getElementById("conferencesContainer").innerHTML =
                `<div class="empty-state"><p>Errore nel caricamento delle conferenze: ${error.message}</p></div>`;
        }
    }

    
    function renderConferenceCardSlots(slots) {
        if (!slots || slots.length === 0) {
            return `<div class="conference-slots"><span class="no-slots">No availability set.</span></div>`;
        }

        let grouped = {};
        slots.forEach(s => {
            if (!grouped[s.date]) grouped[s.date] = [];
            grouped[s.date].push(s);
        });

        let html = '<div class="conference-slots">';
        Object.keys(grouped).sort().forEach(dayKey => {
            html += `
                <div class="array-item" style="margin-bottom:10px;">
                    <div class="slot-day-title" style="font-weight:600; margin-bottom:6px;">
                        ${day(dayKey)}
                    </div>
                    ${grouped[dayKey].map(s => `
                        <div class="slot-item" style="margin:4px 0;">
                            <span class="slot-item-time">${s.start} - ${s.end}</span>
                        </div>
                    `).join('')}
                </div>
            `;
        });
        html += '</div>';
        return html;
    }

    function renderConferences() {
        const container = document.getElementById(
            "conferencesContainer",
        );

        if (conferences.length === 0) {
            container.innerHTML = `
                <div class="empty-state">
                    <p>Ancora nessuna conferenza programmata.</p>
                </div>
                `;
            return;
        }

        const html = `
                <div class="conferences-grid">
                    ${conferences
            .map(
                (conf) => `
                    <div class="conference-card" onclick="showConferenceDetail('${conf.id}')">
                        <div class="conference-header">
                            <div>
                                <div class="conference-title">${escapeHtml(conf.title)}</div>
                                <div>
                                    <span class="conference-badge ${conf.isOnline ? "badge-online" : "badge-in-person"}">
                                        ${conf.isOnline ? "📹 Videoconferenza" : "🏫 In Istituto"}
                                    </span>
                                    ${conf.isExternal ? '<span class="conference-badge badge-external">External</span>' : ""}
                                </div>
                            </div>
                        </div>

                        ${renderConferenceCardSlots(conf.availableSlots)}

                        <div class="conference-meta">
                            <div class="meta-item">👥 ${conf.attendences?.length || 0} relatori</div>
                        </div>
                    </div>
                `,
            )
            .join("")}
                </div>
            `;

        container.innerHTML = html;
    }

    function filterConferences() {
        const searchTerm = document
            .getElementById("searchInput")
            .value.toLowerCase();
        const filtered = conferences.filter(
            (conf) =>
                conf.title.toLowerCase().includes(searchTerm) ||
                conf.abstract.toLowerCase().includes(searchTerm),
        );

        const container = document.getElementById(
            "conferencesContainer",
        );
        if (filtered.length === 0) {
            container.innerHTML =
                `<div class="empty-state"><p>Nessuna conferenza trovata per "${searchTerm}"</p></div>`;
            return;
        }

        const html = `
                <div class="conferences-grid">
                    ${filtered
            .map(
                (conf) => `
                    <div class="conference-card" onclick="showConferenceDetail('${conf.id}')">
                        <div class="conference-header">
                            <div>
                                <div class="conference-title">${escapeHtml(conf.title)}</div>
                                <div>
                                    <span class="conference-badge ${conf.isOnline ? "badge-online" : "badge-in-person"}">
                                        ${conf.isOnline ? "📹 Videoconferenza" : "🏫 In Istituto"}
                                    </span>
                                    ${conf.isExternal ? '<span class="conference-badge badge-external">External</span>' : ""}
                                </div>
                            </div>
                        </div>

                        <!-- *** MODIFICATO: Mostra slot invece di abstract *** -->
                        ${renderConferenceCardSlots(conf.availableSlots)}

                        <div class="conference-meta">
                            <div class="meta-item">👥 ${conf.attendences?.length || 0} attendees</div>
                        </div>
                    </div>
                `,
            )
            .join("")}
                </div>
            `;

        container.innerHTML = html;
    }

    function showConferenceDetail(id) {
        currentConference = conferences.find((c) => c.id === id);
        if (!currentConference) return;

        let availabilityHtml = "Non Impostata";
        if (currentConference.availableSlots && currentConference.availableSlots.length > 0) {
            availabilityHtml = currentConference.availableSlots.map(slot =>
                `<div style="margin-top: 4px;">
                            <strong>${formatSlotDay(slot.date)}:</strong> ${slot.start} - ${slot.end}
                         </div>`
            ).join('');
        }

        const html = `
                <div class="detail-row">
                    <div class="detail-label">Titolo</div>
                    <div class="detail-value">${escapeHtml(currentConference.title)}</div>
                </div>
                <div class="detail-row">
                    <div class="detail-label">Abstract</div>
                    <div class="detail-value">${escapeHtml(currentConference.abstract)}</div>
                </div>
                <div class="detail-row">
                    <div class="detail-label">Modalità</div>
                    <div class="detail-value">${currentConference.isOnline ? "📹 Videoconferenza" : "🏫 In Istituto"}</div>
                </div>
                ${
            currentConference.url
                ? `
                <div class="detail-row">
                    <div class="detail-label">URL di Google Meet</div>
                    <div class="detail-value"><a href="${escapeHtml(currentConference.url)}" target="_blank">${escapeHtml(currentConference.url)}</a></div>
                </div>
                `
                : ""
        }
                <div class="detail-row">
                    <div class="detail-label">Relatori</div>
                    <div class="detail-value">${currentConference.attendences?.join(", ") || "None"}</div>
                </div>
                <div class="detail-row">
                    <div class="detail-label">Contatti</div>
                    <div class="detail-value">${currentConference.usefulContacts?.join(", ") || "None"}</div>
                </div>
                <div class="detail-row">
                    <div class="detail-label">Disponibilità</div>
                    <div class="detail-value">${availabilityHtml}</div>
                </div>
                ${
            currentConference.externalNotes
                ? `
                <div class="detail-row">
                    <div class="detail-label">Note Aggiuntive</div>
                    <div class="detail-value">${escapeHtml(currentConference.externalNotes)}</div>
                </div>
                `
                : ""
        }
            `;

        document.getElementById("detailContent").innerHTML = html;
        document.getElementById("detailModal").classList.add("active");
    }

    function showCreateModal() {
        editMode = false;
        currentConference = null;
        attendeesArray = [];
        contactsArray = [];

        document.getElementById("formModalTitle").textContent = "Nuova Conferenza";
        document.getElementById("formTitle").value = "";
        document.getElementById("formAbstract").value = "";
        document.getElementById("formIsOnline").checked = false;
        document.getElementById("formUrl").value = "";

        document.getElementById("formExternalNotes").value = "";
        document.getElementById("attendeesList").innerHTML = "";
        document.getElementById("contactsList").innerHTML = "";

        resetAvailabilityForm(); // Reset new dynamic form

        document.getElementById("formModal").classList.add("active");
    }

    function editConference() {
        if (!currentConference) return;

        editMode = true;
        attendeesArray = [...(currentConference.attendences || [])];
        contactsArray = [...(currentConference.usefulContacts || [])];

        document.getElementById("formModalTitle").textContent =
            "Modifica Conferenza";
        document.getElementById("formTitle").value =
            currentConference.title;
        document.getElementById("formAbstract").value =
            currentConference.abstract;
        document.getElementById("formIsOnline").checked =
            currentConference.isOnline;
        document.getElementById("formUrl").value =
            currentConference.url || "";

        document.getElementById("formExternalNotes").value =
            currentConference.externalNotes || "";

        renderArrayList("attendees", attendeesArray);
        renderArrayList("contacts", contactsArray);

        
        availabilitySlotsArray = (currentConference.availableSlots || []).map(slot => ({
            day: slot.date,
            start: slot.start,
            end: slot.end
        }));
        renderAvailabilitySlots();
        renderCustomSelectOptions();

        closeModal("detailModal");
        document.getElementById("formModal").classList.add("active");
    }

    function addArrayItem(type) {
        const input = document.getElementById(`${type}Input`);
        const value = input.value.trim();

        if (!value) return;

        if (type === "attendee") {
            attendeesArray.push(value);
            renderArrayList("attendees", attendeesArray);
        } else if (type === "contact") {
            contactsArray.push(value);
            renderArrayList("contacts", contactsArray);
        }

        input.value = "";
    }

    function removeArrayItem(type, index) {
        if (type === "attendees") {
            attendeesArray.splice(index, 1);
            renderArrayList("attendees", attendeesArray);
        } else if (type === "contacts") {
            contactsArray.splice(index, 1);
            renderArrayList("contacts", contactsArray);
        }
    }

    function renderArrayList(type, array) {
        const listId =
            type === "attendees" ? "attendeesList" : "contactsList";
        const list = document.getElementById(listId);

        if (array.length === 0) {
            list.innerHTML = "";
            return;
        }

        list.innerHTML = array
            .map(
                (item, index) => `
                <li class="array-item">
                    <span>${escapeHtml(item)}</span>
                    <button class="btn-remove" onclick="removeArrayItem('${type}', ${index})">Elimina</button>
                </li>
                `,
            )
            .join("");
    }

    // --- Funzioni per il selettore custom di disponibilità ---

    // Apre/Chiude il menu custom
    function toggleCustomSelect() {
        document.getElementById('customSelectContainer').classList.toggle('open');
    }

    // Chiude il menu se si clicca fuori
    function closeCustomSelect() {
        document.getElementById('customSelectContainer').classList.remove('open');
    }

    // Chiamata quando si clicca un'opzione
    function selectCustomDay(date, label) {
        currentSelectedDay = { date, label };

        // Aggiorna il testo del pulsante
        const buttonSpan = document.querySelector('#customSelectButton span');
        buttonSpan.textContent = label;
        buttonSpan.parentElement.classList.remove('placeholder');

        closeCustomSelect();
    }

    // Chiamata quando l'utente clicca "Add Day"
    function addAvailabilitySlot() {
        if (!currentSelectedDay) {
            alert("Seleziona prima un giorno da aggiungere.");
            return;
        }

        const defaultStart = '08:00';
        const defaultEnd = '14:00';

        availabilitySlotsArray.push({
            day: currentSelectedDay.date,
            start: defaultStart,
            end: defaultEnd
        });

        currentSelectedDay = null;
        document.querySelector('#customSelectButton span').textContent = daySelectorDefaultText;

        sortSlots();
        renderAvailabilitySlots();
    }

    // Rimuove uno slot dall'array e ridisegna
    function removeAvailabilitySlot(index) {
        availabilitySlotsArray.splice(index, 1);
        renderAvailabilitySlots();
        renderCustomSelectOptions();
    }

    // Aggiorna l'orario nell'array quando l'utente lo cambia
    function updateSlotTime(index, type, value) {
        const slot = availabilitySlotsArray[index];
        if (!slot) return;

        const previous = slot[type];
        slot[type] = value;

        // Prevent end < start
        if (slot.end < slot.start) {
            alert("La data di fine non può essere precedente a quella di inizio.");
            slot[type] = previous;

            const input = document.querySelector(`[data-index="${index}"] input[data-field="${type}"]`);
            if (input) input.value = previous;

            return;
        }

        renderAvailabilitySlots();
    }

//Controlla se vi sono sovrapposizioni di blocchi o la data di fine è prima di quella di inizio
function checkSlotConflicts(slot, allSlots) {
    const sameDay = allSlots.filter(s => s.day === slot.day);
    const conflicts = [];

    for (const s of sameDay) {
        if (s === slot) continue;

        const overlaps = (slot.start < s.end && slot.end > s.start);
        const identical = (slot.start === s.start && slot.end === s.end);

        if (identical) {
            conflicts.push("Esiste");
        } else if (overlaps) {
            conflicts.push("Sovrapposizione");
        }
    }

    return conflicts;
}

//Riordina i blocchi
function sortSlots() {
    availabilitySlotsArray.sort((a, b) => {
        if (a.day < b.day) return -1;
        if (a.day > b.day) return 1;

        // same day → sort by start, then end
        if (a.start < b.start) return -1;
        if (a.start > b.start) return 1;
        if (a.end < b.end) return -1;
        if (a.end > b.end) return 1;

        return 0;
    });
}

    // Disegna l'elenco degli slot aggiunti
    function renderAvailabilitySlots() {
        sortSlots();

        const container = document.getElementById("availabilitySlotsContainer");
        container.innerHTML = "";
container.style.className = "array-list";

        let lastDay = null;
        availabilitySlotsArray.forEach((slot, index) => {
            const conflicts = checkSlotConflicts(slot, availabilitySlotsArray);
            const hasConflict = conflicts.length > 0;

            if (slot.day !== lastDay) {
                if (lastDay !== null) container.innerHTML += `<div style="height:10px;"></div>`;
                container.innerHTML += `<div class="array-item" style="margin:0;padding:8px 10px;font-weight:600;">${day(slot.day)}</div>`;
                lastDay = slot.day;
            }

            container.innerHTML += `
                <div class="slot" style="display:flex;align-items:center;gap:10px;margin:6px 0;" data-index="${index}">
                    
                    <input type="time" value="${slot.start}"
                           data-field="start"
                           onchange="updateSlotTime(${index},'start',this.value)"
                           style="padding:4px;">

                    <span>→</span>

                    <input type="time" value="${slot.end}"
                           data-field="end"
                           onchange="updateSlotTime(${index},'end',this.value)"
                           style="padding:4px;">

                    <button class="btn-remove" onclick="removeAvailabilitySlot(${index})">Elimina</button>

                    ${hasConflict ? `
                        <span style="color:#d9534f; font-size:12px;">
                            <svg width="20" height="20" viewBox="0 0 26 24" fill="none" xmlns="http://www.w3.org/2000/svg">
                            <path d="M15.7526 1.63011L25.5171 18.9918C25.8358 19.5515 26 20.1604 26 20.7496C26 22.5663 24.783 24 22.7645 24H3.22585C1.21694 24 0 22.5663 0 20.7496C0 20.1604 0.154532 19.5614 0.482911 18.9918L10.2474 1.63011C10.8559 0.540097 11.9183 0 13 0C14.0721 0 15.1441 0.540097 15.7526 1.63011ZM11.7348 18.4517C11.7348 19.1293 12.3142 19.689 13 19.689C13.6761 19.689 14.2652 19.1391 14.2652 18.4517C14.2652 17.7545 13.6857 17.2046 13 17.2046C12.3046 17.2046 11.7348 17.7643 11.7348 18.4517ZM11.9666 7.75777L12.1211 14.671C12.1308 15.2602 12.4398 15.5941 13 15.5941C13.5312 15.5941 13.8499 15.2701 13.8596 14.671L14.0141 7.76758C14.0238 7.1784 13.5891 6.74633 12.9903 6.74633C12.3819 6.74633 11.9569 7.16859 11.9666 7.75777Z" fill="#D9534F"/>
                            </svg>

                            ${conflicts.join(", ")}
                        </span>
                    ` : ""}
                </div>
            `;
        });
    }

    // Aggiorna il dropdown custom per mostrare solo i giorni non ancora aggiunti
    function renderCustomSelectOptions() {
        const optionsContainer = document.getElementById("customSelectOptions");
        optionsContainer.innerHTML = '';

        allAvailableDays.forEach(day => {
            optionsContainer.innerHTML += `
                <button
                    type="button"
                    class="custom-select-option"
                    onclick="selectCustomDay('${day.date}', '${day.label}')">
                    ${day.label}
                </button>`;
        });

        document.getElementById('customSelectButton').disabled = false;
    }

    // Resetta l'intero form di disponibilità
    function resetAvailabilityForm() {
        availabilitySlotsArray = [];
        currentSelectedDay = null;

        // Resetta il testo del pulsante
        const buttonSpan = document.querySelector('#customSelectButton span');
        if (buttonSpan) { // Controlla se esiste (nel caso il modal non sia ancora aperto)
            buttonSpan.textContent = daySelectorDefaultText;
            buttonSpan.parentElement.classList.add('placeholder');
        }

        renderAvailabilitySlots();
        renderCustomSelectOptions();
    }


    async function saveConference() {
        const title = document.getElementById("formTitle").value.trim();
        const abstract = document
            .getElementById("formAbstract")
            .value.trim();

        if (!title || !abstract) {
            alert("Aggiungi un titolo e un abstract prima di salvare");
            return;
        }

        // --- Logica di validazione disponibilità (semplificata) ---
        if (availabilitySlotsArray.length === 0) {
            alert("Seleziona i blocchi previsti per la conferenza prima di salvare.");
            return;
        }

        const hasEmptyTime = availabilitySlotsArray.some(slot => !slot.start || !slot.end);
        if (hasEmptyTime) {
            alert("Imposta una data di inizio");
            return;
        }
        // --- Fine logica disponibilità ---


        // Converti gli slot dal formato frontend {day, start, end} al formato server {date, start, end}
        const serverSlots = availabilitySlotsArray.map(slot => ({
            date: slot.day,
            start: slot.start,
            end: slot.end
        }));

        const data = {
            title,
            abstract,
            isOnline: document.getElementById("formIsOnline").checked,
            url:
                document.getElementById("formUrl").value.trim() || null,
            attendences: attendeesArray,
            usefulContacts: contactsArray,
            isExternal: false,
            externalNotes: document
                .getElementById("formExternalNotes")
                .value.trim(),
            availableSlots: serverSlots,
        };

        const saveBtn = document.getElementById("saveBtn");
        saveBtn.disabled = true;
        saveBtn.textContent = "Salvataggio...";

        try {
            const url = editMode
                ? `${API_URL}conferences/${currentConference.id}`
                : `${API_URL}conferences/create`;
            const method = editMode ? "PUT" : "POST";

            const response = await fetch(url, {
                method,
                headers: {
                    "Content-Type": "application/json",
                    Authorization: `Bearer ${token}`,
                },
                body: JSON.stringify(data),
            });

            if (!response.ok) {
                throw new Error("Failed to save conference");
            }

            closeModal("formModal");
            await loadConferences();
        } catch (error) {
            alert("Error: " + error.message);
        } finally {
            saveBtn.disabled = false;
            saveBtn.textContent = "Salva";
        }
    }

    async function deleteConference() {
        if (!currentConference) return;

        if (
            !confirm("Confermi di eliminare questa conferenza?")
        ) {
            return;
        }

        try {
            const response = await fetch(
                `${API_URL}conferences/${currentConference.id}`,
                {
                    method: "DELETE",
                    headers: {
                        Authorization: `Bearer ${token}`,
                    },
                },
            );

            if (!response.ok) {
                throw new Error("Impossibile eliminare la conferenza");
            }

            closeModal("detailModal");
            await loadConferences();
        } catch (error) {
            alert("Errore: " + error.message);
        }
    }

    /* * ===================================
    * GESTIONE TEMA E INIZIALIZZAZIONE
    * ===================================
    */
    
    // Al caricamento della pagina
    document.addEventListener('DOMContentLoaded', () => {
        // Applica il tema salvato (funzione da common.js)
        initTheme();

        // --- Listener per il selettore custom ---
        // Popola il selettore custom per la prima volta
        renderCustomSelectOptions();

        // Aggiungi listener per chiudere il dropdown custom se si clicca fuori
        document.addEventListener('click', function(event) {
            const selectContainer = document.getElementById('customSelectContainer');
            if (selectContainer && !selectContainer.contains(event.target)) {
                closeCustomSelect();
            }
        });
        // --- Fine listener ---
    });

    // Utilities
    function closeModal(modalId) {
        document.getElementById(modalId).classList.remove("active");
    }

    // Helper per formattare la data (ora globale)
    function formatSlotDay(dateString) {
        if (!dateString) return "";
        const [year, month, day] = dateString.split('-');
        const date = new Date(year, month - 1, day);
        return date.toLocaleDateString('en-US', {
            month: 'short',
            day: 'numeric',
            year: 'numeric'
        });
    }

    function day(dateString) {
        if (!dateString) return "";
        const d = new Date(dateString);
        return d.toLocaleDateString('it-IT', {
            day: "numeric",
            month: "long"
        });
    }

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

    // Keyboard shortcuts
    document.addEventListener("keydown", (e) => {
        if (e.key === "Escape") {
            closeModal("detailModal");
            closeModal("formModal");
        }
    });