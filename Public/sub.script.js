
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
            picker.appendChild(li);
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