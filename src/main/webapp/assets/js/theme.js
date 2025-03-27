document.addEventListener('DOMContentLoaded', function () {
    const contextPath = window.contextPath || '';
    const theme = document.body.getAttribute('data-theme') || 'light';
    if (theme === 'dark') {
        document.body.classList.add('dark-mode');
    }

    const themeSelect = document.getElementById('themeSelect');
    if (themeSelect) {
        themeSelect.addEventListener('change', function () {
            const selectedTheme = this.value;
            document.body.classList.toggle('dark-mode', selectedTheme === 'dark');
            const form = document.createElement('form');
            form.method = 'POST';
            form.action = contextPath + '/settings';
            form.style.display = 'none';
            const themeInput = document.createElement('input');
            themeInput.type = 'hidden';
            themeInput.name = 'theme';
            themeInput.value = selectedTheme;
            form.appendChild(themeInput);
            document.body.appendChild(form);
            form.submit();
        });
    } else {
        console.error('themeSelect element not found');
    }
});