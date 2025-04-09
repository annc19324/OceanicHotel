<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    String language = (String) session.getAttribute("language");
    if (language == null) {
        language = "en";
        session.setAttribute("language", language);
    }
    String theme = (String) session.getAttribute("theme");
    if (theme == null) {
        theme = "light";
        session.setAttribute("theme", theme);
    }
%>
<!DOCTYPE html>
<html lang="<%= language%>">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title><%= language.equals("vi") ? "Đăng ký - Khách sạn Oceanic" : "Register - Oceanic Hotel"%></title>
        <link rel="icon" href="<%= request.getContextPath()%>/assets/images/logo.png" type="image/x-icon">
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0-beta3/css/all.min.css">
        <script>window.contextPath = '<%= request.getContextPath()%>';</script>
        <script type="module" src="<%= request.getContextPath()%>/assets/js/language.js" defer></script>
        <script type="module" src="<%= request.getContextPath()%>/assets/js/theme.js" defer></script>
        <style>
            body {
                margin: 0;
                padding: 0;
                background-image: url('<%= request.getContextPath()%>/assets/images/Home-BG.png');
                font-family: 'Montserrat', sans-serif;
                display: flex;
                align-items: center;
                justify-content: center;
                min-height: 100vh;
                background-size: 100% 100%;
                background-position: center;
                background-repeat: no-repeat;
                background-attachment: fixed;
                user-select: none;
            }
            body.dark-mode {
                background-image: url('<%= request.getContextPath()%>/assets/images/Home-BG-Dark.png');
                color: #fff;
            }
            .container {
                width: 100%;
                max-width: 800px;
                padding: 20px;
                background-color: #fff;
                border-radius: 8px;
                box-shadow: 0 0 10px rgba(0, 0, 0, 0.1);
                opacity: 0.9;
                text-align: center;
            }
            body.dark-mode .container {
                background-color: #444;
            }
            h2 {
                margin-bottom: 20px;
            }
            .form-grid {
                display: grid;
                grid-template-columns: 1fr 1fr;
                gap: 20px;
            }
            label {
                display: block;
                margin-bottom: 5px;
                font-weight: bold;
                text-align: left;
            }
            input[type="text"], input[type="email"], input[type="password"], input[type="date"], select {
                width: 100%;
                padding: 8px;
                margin-bottom: 5px;
                border: 1px solid #ccc;
                border-radius: 4px;
                box-sizing: border-box;
            }
            body.dark-mode input, body.dark-mode select {
                background-color: #555;
                color: #fff;
                border-color: #666;
            }
            .error-input {
                font-size: 12px;
                color: red;
                margin-top: 0;
                margin-bottom: 15px;
                display: none;
                text-align: left;
            }
            body.dark-mode .error-input {
                color: #ff6666;
            }
            button {
                width: 50%;
                padding: 10px;
                background-color: #007bff;
                color: #fff;
                border: none;
                border-radius: 4px;
                cursor: pointer;
                font-family: 'Montserrat', sans-serif;
                font-weight: bold;
                grid-column: span 2;
            }
            button:hover {
                background-color: #0056b3;
            }
            body.dark-mode button {
                background-color: #0066cc;
            }
            .error {
                color: red;
                text-align: center;
                margin-top: 10px;
                font-weight: normal;
                min-height: 20px;
                grid-column: span 2;
            }
            body.dark-mode .error {
                color: #ff6666;
            }
            .link {
                text-align: center;
                margin-top: 15px;
                font-weight: normal;
                grid-column: span 2;
            }
            .link a {
                color: #007bff;
                text-decoration: none;
            }
            .link a:hover {
                text-decoration: underline;
            }
            body.dark-mode .link a {
                color: #66b3ff;
            }
            .settings {
                position: absolute;
                top: 10px;
                right: 10px;
                display: flex;
                gap: 10px;
                align-items: center;
            }
            .settings select {
                padding: 5px;
                border-radius: 4px;
                font-family: 'Montserrat', sans-serif;
            }
        </style>
    </head>
    <body class="<%= theme.equals("dark") ? "dark-mode" : ""%>" data-theme="<%= theme%>">
        <div class="settings">
            <select id="languageSelect">
                <option value="en" <%= language.equals("en") ? "selected" : ""%>><%= language.equals("vi") ? "Tiếng Anh" : "English"%></option>
                <option value="vi" <%= language.equals("vi") ? "selected" : ""%>><%= language.equals("vi") ? "Tiếng Việt" : "Vietnamese"%></option>
            </select>
            <select id="themeSelect">
                <option value="light" <%= theme.equals("light") ? "selected" : ""%>><%= language.equals("vi") ? "Chế độ sáng" : "Light Mode"%></option>
                <option value="dark" <%= theme.equals("dark") ? "selected" : ""%>><%= language.equals("vi") ? "Chế độ tối" : "Dark Mode"%></option>
            </select>
        </div>
        <div class="container">
            <h2><%= language.equals("vi") ? "Đăng ký" : "Register"%></h2>
            <form action="<%= request.getContextPath()%>/register" method="post" onsubmit="return validateForm()" novalidate>
                <div class="form-grid">
                    <!-- Cột 1 -->
                    <div>
                        <label for="username"><%= language.equals("vi") ? "Tên người dùng:" : "Username:"%></label>
                        <input type="text" id="username" name="username" required>
                        <p class="error-input" id="username-error"></p>

                        <label for="password"><%= language.equals("vi") ? "Mật khẩu:" : "Password:"%></label>
                        <input type="password" id="password" name="password" required oninput="validatePassword()">
                        <p class="error-input" id="password-error"></p>

                        <label for="full_name"><%= language.equals("vi") ? "Họ và tên:" : "Full Name:"%></label>
                        <input type="text" id="full_name" name="full_name" required>
                        <p class="error-input" id="full_name-error"></p>

                        <label for="email"><%= language.equals("vi") ? "Email:" : "Email:"%></label>
                        <input type="email" id="email" name="email" required>
                        <p class="error-input" id="email-error"></p>
                    </div>
                    <!-- Cột 2 -->
                    <div>
                        <label for="phone_number"><%= language.equals("vi") ? "Số điện thoại:" : "Phone Number:"%></label>
                        <input type="text" id="phone_number" name="phone_number" required>
                        <p class="error-input" id="phone_number-error"></p>

                        <label for="cccd"><%= language.equals("vi") ? "CCCD:" : "ID Card:"%></label>
                        <input type="text" id="cccd" name="cccd" required> <!-- Thêm required -->
                        <p class="error-input" id="cccd-error"></p>

                        <div class="input-wrapper">
                            <label><%= language.equals("vi") ? "Ngày sinh:" : "Date of Birth:"%></label>
                            <div style="display: flex; gap: 10px;">
                                <select id="dob_day" name="dob_day" required>
                                    <option value=""><%= language.equals("vi") ? "Ngày" : "Day"%></option>
                                    <% for (int i = 1; i <= 31; i++) {%>
                                    <option value="<%= String.format("%02d", i)%>"><%= String.format("%02d", i)%></option>
                                    <% }%>
                                </select>
                                <select id="dob_month" name="dob_month" required>
                                    <option value=""><%= language.equals("vi") ? "Tháng" : "Month"%></option>
                                    <% for (int i = 1; i <= 12; i++) {%>
                                    <option value="<%= String.format("%02d", i)%>"><%= String.format("%02d", i)%></option>
                                    <% }%>
                                </select>
                                <select id="dob_year" name="dob_year" required>
                                    <option value=""><%= language.equals("vi") ? "Năm" : "Year"%></option>
                                    <%
                                        int currentYear = java.time.Year.now().getValue();
                                        for (int i = currentYear; i >= currentYear - 100; i--) {
                                    %>
                                    <option value="<%= i%>"><%= i%></option>
                                    <% }%>
                                </select>
                            </div>
                            <p class="error-input" id="date_of_birth-error"></p>
                        </div>

                        <label for="gender"><%= language.equals("vi") ? "Giới tính:" : "Gender:"%></label>
                        <select id="gender" name="gender">
                            <option value=""><%= language.equals("vi") ? "Chọn giới tính" : "Select gender"%></option>
                            <option value="Male"><%= language.equals("vi") ? "Nam" : "Male"%></option>
                            <option value="Female"><%= language.equals("vi") ? "Nữ" : "Female"%></option>
                            <option value="Other"><%= language.equals("vi") ? "Khác" : "Other"%></option>
                        </select>
                        <p class="error-input" id="gender-error"></p>
                    </div>
                </div>
                <button type="submit"><%= language.equals("vi") ? "Đăng ký" : "Register"%></button>
                <p class="error" id="general-error"><%= request.getAttribute("error") != null ? request.getAttribute("error") : ""%></p>
                <p class="link"><%= language.equals("vi") ? "Đã có tài khoản?" : "Already have an account?"%> <a href="<%= request.getContextPath()%>/login"><%= language.equals("vi") ? "Đăng nhập tại đây" : "Login here"%></a></p>
            </form>
        </div>
        <script>
            window.onload = function () {
                const errorFromServer = '<%= request.getAttribute("error") != null ? request.getAttribute("error") : ""%>';
                if (errorFromServer)
                    document.getElementById("general-error").textContent = errorFromServer;
                document.querySelectorAll(".error-input").forEach(e => e.style.display = "none");
            };

            function validateUsername() {
                const username = document.getElementById("username").value.trim();
                const errorElement = document.getElementById("username-error");
                const regex = /^[a-zA-Z0-9]{6,}$/;
                const language = '<%= language%>';
                if (!regex.test(username)) {
                    errorElement.style.display = "block";
                    errorElement.textContent = language === "vi" ? "Tên người dùng phải ít nhất 6 ký tự, chỉ chứa chữ cái và số!" : "Username must be at least 6 characters, only letters and numbers!";
                } else {
                    errorElement.style.display = "none";
                }
            }

            function validateEmail() {
                const email = document.getElementById("email").value.trim();
                const errorElement = document.getElementById("email-error");
                const regex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
                const language = '<%= language%>';
                if (!regex.test(email)) {
                    errorElement.style.display = "block";
                    errorElement.textContent = language === "vi" ? "Email không hợp lệ!" : "Invalid email format!";
                } else {
                    errorElement.style.display = "none";
                }
            }

            function validateFullName() {
                const fullName = document.getElementById("full_name").value.trim();
                const errorElement = document.getElementById("full_name-error");
                const language = '<%= language%>';
                if (!fullName) {
                    errorElement.style.display = "block";
                    errorElement.textContent = language === "vi" ? "Vui lòng nhập họ và tên!" : "Please enter full name!";
                } else {
                    errorElement.style.display = "none";
                }
            }

            function validatePhoneNumber() {
                const phone = document.getElementById("phone_number").value.trim();
                const errorElement = document.getElementById("phone_number-error");
                const regex = /^[0-9]{10,15}$/;
                const language = '<%= language%>';
                if (!regex.test(phone)) {
                    errorElement.style.display = "block";
                    errorElement.textContent = language === "vi" ? "Số điện thoại phải từ 10-15 chữ số!" : "Phone number must be 10-15 digits!";
                } else {
                    errorElement.style.display = "none";
                }
            }

            function validateCCCD() {
                const cccd = document.getElementById("cccd").value.trim();
                const errorElement = document.getElementById("cccd-error");
                const regex = /^[0-9]{12}$/;
                const language = '<%= language%>';
                if (!cccd) { // Kiểm tra rỗng
                    errorElement.style.display = "block";
                    errorElement.textContent = language === "vi" ? "Vui lòng nhập CCCD!" : "Please enter ID Card!";
                } else if (!regex.test(cccd)) {
                    errorElement.style.display = "block";
                    errorElement.textContent = language === "vi" ? "CCCD phải là 12 chữ số!" : "ID Card must be 12 digits!";
                } else {
                    errorElement.style.display = "none";
                }
            }

            function validateDateOfBirth() {
                const day = document.getElementById("dob_day").value;
                const month = document.getElementById("dob_month").value;
                const year = document.getElementById("dob_year").value;
                const errorElement = document.getElementById("date_of_birth-error");
                const language = '<%= language%>';

                if (!day || !month || !year) {
                    errorElement.style.display = "block";
                    errorElement.textContent = language === "vi" ? "Vui lòng chọn đầy đủ ngày sinh!" : "Please select full date of birth!";
                    return false;
                }

                const dobDate = new Date(year, month - 1, day);
                const now = new Date();
                const ageDiffMs = now - dobDate;
                const ageDate = new Date(ageDiffMs);
                const age = Math.abs(ageDate.getUTCFullYear() - 1970);

                if (dobDate > now) {
                    errorElement.style.display = "block";
                    errorElement.textContent = language === "vi" ? "Ngày sinh không thể là ngày trong tương lai!" : "Date of birth cannot be a future date!";
                } else if (age < 16) {
                    errorElement.style.display = "block";
                    errorElement.textContent = language === "vi" ? "Bạn cần trên 16 tuổi để tạo tài khoản!" : "You need to be over 16 to create an account!";
                } else {
                    errorElement.style.display = "none";
                }
            }

            function validateGender() {
                const gender = document.getElementById("gender").value;
                const errorElement = document.getElementById("gender-error");
                const language = '<%= language%>';
                if (!gender && !["Male", "Female", "Other"].includes(gender)) {
                    errorElement.style.display = "block";
                    errorElement.textContent = language === "vi" ? "Giới tính phải là 'Nam', 'Nữ' hoặc 'Khác'!" : "Gender must be 'Male', 'Female', or 'Other'!";
                } else {
                    errorElement.style.display = "none";
                }
            }

            function validatePassword() {
                const password = document.getElementById("password").value;
                const errorElement = document.getElementById("password-error");
                const regex = /^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@#$%^&+=!]).{8,}$/;
                const language = '<%= language%>';
                if (!regex.test(password)) {
                    errorElement.style.display = "block";
                    errorElement.textContent = language === "vi" ? "Mật khẩu phải có ít nhất 8 ký tự, bao gồm chữ hoa, chữ thường, số và ký tự đặc biệt!" : "Password must be at least 8 characters with uppercase, lowercase, number, and special character!";
                } else {
                    errorElement.style.display = "none";
                }
            }

            function validateForm() {
                validateUsername();
                validateEmail();
                validateFullName();
                validatePhoneNumber();
                validateCCCD();
                validateDateOfBirth();
                validateGender();
                validatePassword();
                return Array.from(document.querySelectorAll(".error-input")).every(e => e.style.display === "none");
            }

            document.getElementById("username").addEventListener("input", validateUsername);
            document.getElementById("email").addEventListener("input", validateEmail);
            document.getElementById("full_name").addEventListener("input", validateFullName);
            document.getElementById("phone_number").addEventListener("input", validatePhoneNumber);
            document.getElementById("cccd").addEventListener("input", validateCCCD);
            document.getElementById("dob_day").addEventListener("change", validateDateOfBirth);
            document.getElementById("dob_month").addEventListener("change", validateDateOfBirth);
            document.getElementById("dob_year").addEventListener("change", validateDateOfBirth);
            document.getElementById("gender").addEventListener("change", validateGender);
            document.getElementById("password").addEventListener("input", validatePassword);
        </script>
    </body>
</html>