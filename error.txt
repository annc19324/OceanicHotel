document.addEventListener('DOMContentLoaded', function () {
    const contextPath = window.contextPath || '';
    fetch(contextPath + '/get-error')
        .then(response => {
            if (!response.ok) {
                throw new Error('Network response was not ok');
            }
            return response.text();
        })
        .then(errorMessage => {
            if (errorMessage) {
                const errorDiv = document.getElementById("error-message");
                if (errorDiv) {
                    errorDiv.textContent = errorMessage;
                    errorDiv.style.display = "block";
                }
            }
        })
        .catch(error => console.error('Error fetching error message:', error));
});