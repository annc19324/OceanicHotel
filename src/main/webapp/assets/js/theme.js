document.addEventListener('DOMContentLoaded', () => {
    const themeSelect = document.getElementById('themeSelect');
    if (themeSelect) {
        themeSelect.addEventListener('change', (e) => {
            const form = document.createElement('form');
            form.method = 'POST';
            form.action = window.contextPath + '/settings';
            const input = document.createElement('input');
            input.type = 'hidden';
            input.name = 'theme';
            input.value = e.target.value;
            form.appendChild(input);
            document.body.appendChild(form);
            form.submit();
        });
    }
});