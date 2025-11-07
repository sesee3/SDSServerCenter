
// [HTML PAGE] - on appear
document.addEventListener("DOMContentLoaded", () => {
    fetchStudents().then(r => console.log("Loaded"))
});

async function fetchStudents() {
    try {
        const students = await fetchAPI("students");

        const picker = document.getElementById("students-picker");
        picker.innerHTML = "";

        students.forEach(student => {
            const option = document.createElement("option");
            option.textContent = `${student.name} ${student.surname}`;
            option.value = student.id;
            picker.appendChild(option);
        })

    } catch (e) {
        console.error("Error fetching students", e);
        return null;
    }
}

function handleSubmit(e) {
    e.preventDefault();
    window.location.href = "conferma.view.html";
}
function handleFixedButtonClick() {
    document.querySelector(".form-container").requestSubmit();
}

//DATA ------!!!!!!!!!SPOSTARE TUTTE LE FUNZIONI DI API IN UN ALTRO FILE!!!!!!!!!!
async function fetchAPI(dataType) {
    try {
        const response = await fetch(`http://localhost:3000/data/v1/${dataType}`);
        if (!response.ok) {
            throw new Error(`HTTP ${response.status}`);
        }

        return await response.json();

    } catch (error) {
        console.error("Errore API", error);
        return null;
    }
}

async function fetchCache(dataType) {
    const cache = localStorage.getItem(dataType);
    if (cache) return JSON.parse(cache);

    const apiData = await fetchAPI(dataType);
    if (apiData) localStorage.setItem(dataType, JSON.stringify(apiData));
    return apiData;
}



//CUSTOM PICKER
// Opzioni di esempio
const options = [
    "A", "B", "C", "D", "E", "F", "G", "H", "I",
    "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z"
];

document.addEventListener("DOMContentLoaded", () => {
    const list = document.getElementById("picker-options");
    options.forEach(opt => {
        const li = document.createElement("li");
        li.textContent = opt;
        li.onclick = () => selectOption(opt);
        list.appendChild(li);
    });
});

function filterOptions() {
    const input = document.getElementById("picker-search");
    const filter = input.value.toLowerCase();
    const listItems = document.querySelectorAll("#picker-options li");

    listItems.forEach(li => {
        const text = li.textContent.toLowerCase();
        li.style.display = text.includes(filter) ? "block" : "none";
    });
}

function selectOption(value) {
    const input = document.getElementById("picker-search");
    input.value = value;
    document.getElementById("picker-options").style.display = "none";
    // Puoi salvare il valore selezionato in un input nascosto per il form
}

document.getElementById("picker-search").addEventListener("click", () => {
    const optionsMenu = document.getElementById("picker-options");
    optionsMenu.style.display = "block";
});
document.addEventListener("click", (e) => {
    if (!e.target.closest(".custom-picker")) {
        document.getElementById("picker-options").style.display = "none";
    }
});