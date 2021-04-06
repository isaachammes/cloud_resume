const apiUrl = 'https://qebcw0w3ug.execute-api.us-east-1.amazonaws.com/get-update-dynamodb-counter'
const countElement = document.getElementById('count');

updateVisitCount();

function updateVisitCount() {
    fetch(apiUrl)
        .then(res => res.json())
        .then(res => {
        countElement.innerHTML = res;
    });
}