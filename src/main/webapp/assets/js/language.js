    document.addEventListener('DOMContentLoaded', () => {
        const languageSelect = document.getElementById('languageSelect');
        if (languageSelect) {
            languageSelect.addEventListener('change', (e) => {
                const form = document.createElement('form');
                form.method = 'POST';
                form.action = window.contextPath + '/settings';
                const input = document.createElement('input');
                input.type = 'hidden';
                input.name = 'language';
                input.value = e.target.value;
                form.appendChild(input);
                document.body.appendChild(form);
                form.submit();
            });
        }
    });