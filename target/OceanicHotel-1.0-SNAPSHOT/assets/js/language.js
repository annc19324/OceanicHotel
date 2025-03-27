document.addEventListener('DOMContentLoaded', function () {
    const contextPath = window.contextPath || '';

    const languageSelect = document.getElementById('languageSelect');
    if (languageSelect) {
        languageSelect.addEventListener('change', function () {
            const selectedLanguage = this.value;
            const form = document.createElement('form');
            form.method = 'POST';
            form.action = contextPath + '/settings';
            form.style.display = 'none';
            const languageInput = document.createElement('input');
            languageInput.type = 'hidden';
            languageInput.name = 'language';
            languageInput.value = selectedLanguage;
            form.appendChild(languageInput);
            document.body.appendChild(form);
            form.submit();
        });
    } else {
        console.error('languageSelect element not found');
    }
});