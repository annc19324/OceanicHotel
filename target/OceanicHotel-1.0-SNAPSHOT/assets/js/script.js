document.addEventListener('DOMContentLoaded', function () {
    // Lấy contextPath từ biến global (được nhúng trong JSP)
    const contextPath = window.contextPath || '';

    // Lấy giá trị theme từ session (được nhúng trong JSP)
    const theme = document.body.getAttribute('data-theme') || 'light';
    if (theme === 'dark') {
        document.body.classList.add('dark-mode');
    }

    // Xử lý thay đổi theme
    const themeSelect = document.getElementById('themeSelect');
    if (themeSelect) {
        themeSelect.addEventListener('change', function () {
            const selectedTheme = this.value;
            document.body.classList.toggle('dark-mode', selectedTheme === 'dark');
            // Gửi yêu cầu để lưu theme vào session
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
    }

    // Xử lý thay đổi ngôn ngữ
    const languageSelect = document.getElementById('languageSelect');
    if (languageSelect) {
        languageSelect.addEventListener('change', function () {
            const selectedLanguage = this.value;
            // Gửi yêu cầu để lưu language vào session
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
    }
    
        fetch('/OceanicHotel/get-error')
        .then(response => response.text())
        .then(errorMessage => {
            if (errorMessage) {
                const errorDiv = document.getElementById("error-message");
                errorDiv.textContent = errorMessage;
                errorDiv.style.display = "block";
            }
        });
});