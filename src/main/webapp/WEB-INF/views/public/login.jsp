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
<html lang="<%= language %>">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><%= language.equals("vi") ? "Đăng nhập - Khách sạn Oceanic" : "Login - Oceanic Hotel" %></title>
    <link rel="icon" href="<%= request.getContextPath() %>/assets/images/logo.png" type="image/x-icon">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0-beta3/css/all.min.css">
    <script>window.contextPath = '<%= request.getContextPath() %>';</script>
    <script type="module" src="<%= request.getContextPath() %>/assets/js/language.js" defer></script>
    <script type="module" src="<%= request.getContextPath() %>/assets/js/theme.js" defer></script>
    <style>
        body {
            font-family: 'Montserrat', sans-serif;
            margin: 0;
            padding: 0;
            background-image: url('<%= request.getContextPath() %>/assets/images/Home-BG.png');
            background-size: 100% 100%;
            background-position: center;
            background-repeat: no-repeat;
            background-attachment: fixed;
            display: flex;
            align-items: center;
            justify-content: center;
            min-height: 100vh;
        }
        
        body.dark-mode {
            color: #fff;
            background-image: url('<%= request.getContextPath() %>/assets/images/Home-BG-Dark.png');
        }
        
        .container {
            width: 100%;
            max-width: 400px;
            padding: 20px;
            background-color: #fff;
            border-radius: 8px;
            text-align: center;
            opacity: 0.9;
        }
        body.dark-mode .container { background-color: #444; }
        .logo { max-width: 100%; height: auto; }
        label { display: block; font-weight: bold; text-align: left; }
        .input-wrapper { margin-bottom: 20px; position: relative; }
        input[type="text"], input[type="password"], input[type="text"] {
            width: 100%;
            padding: 8px;
            border: 1px solid #ccc;
            border-radius: 4px;
            box-sizing: border-box;
        }
        body.dark-mode input { background-color: #555; color: #fff; border-color: #666; }
        button {
            width: 100%;
            padding: 10px;
            background-color: #007bff;
            color: #fff;
            border: none;
            border-radius: 4px;
            cursor: pointer;
            font-weight: bold;
        }
        button:hover { background-color: #0056b3; }
        body.dark-mode button { background-color: #0066cc; }
        .error { color: red; text-align: center; margin-top: 10px; font-weight: normal; min-height: 20px; }
        body.dark-mode .error { color: #ff6666; }
        .link { text-align: center; margin-top: 15px; font-weight: normal; }
        .link a { color: #007bff; text-decoration: none; }
        .link a:hover { text-decoration: underline; }
        body.dark-mode .link a { color: #66b3ff; }
        .settings { position: absolute; top: 10px; right: 10px; }
        .settings select { padding: 5px; margin-left: 10px; border-radius: 4px; font-family: 'Montserrat', sans-serif; }
        
        /* CSS cho biểu tượng toggle mật khẩu */
        .password-toggle {
            position: absolute;
            right: 10px;
            top: 70%;
            transform: translateY(-50%);
            cursor: pointer;
            color: #666;
        }
        body.dark-mode .password-toggle { color: #ccc; }
    </style>
</head>
<body class="<%= theme.equals("dark") ? "dark-mode" : "" %>" data-theme="<%= theme %>">
    <div class="settings">
        <select id="languageSelect">
            <option value="en" <%= language.equals("en") ? "selected" : "" %>><%= language.equals("vi") ? "Tiếng Anh" : "English" %></option>
            <option value="vi" <%= language.equals("vi") ? "selected" : "" %>><%= language.equals("vi") ? "Tiếng Việt" : "Vietnamese" %></option>
        </select>
        <select id="themeSelect">
            <option value="light" <%= theme.equals("light") ? "selected" : "" %>><%= language.equals("vi") ? "Chế độ sáng" : "Light Mode" %></option>
            <option value="dark" <%= theme.equals("dark") ? "selected" : "" %>><%= language.equals("vi") ? "Chế độ tối" : "Dark Mode" %></option>
        </select>
    </div>
    <div class="container">
        <img src="<%= request.getContextPath() %>/assets/images/width_800.jpg" alt="Oceanic Hotel Logo" class="logo">
        <h2><%= language.equals("vi") ? "Đăng nhập" : "Login" %></h2>
        <form action="<%= request.getContextPath() %>/login" method="post" onsubmit="return validateForm()" novalidate>
            <div class="input-wrapper">
                <label for="username"><%= language.equals("vi") ? "Tên người dùng:" : "Username:" %></label>
                <input type="text" id="username" name="username" value="<%= request.getParameter("username") != null ? request.getParameter("username") : "" %>">
            </div>
            <div class="input-wrapper">
                <label for="password"><%= language.equals("vi") ? "Mật khẩu:" : "Password:" %></label>
                <input type="password" id="password" name="password" autocomplete="current-password">
                <i class="fas fa-eye password-toggle" id="togglePassword"></i>
            </div>
            <button type="submit"><%= language.equals("vi") ? "Đăng nhập" : "Login" %></button>
        </form>
        <p class="error" id="general-error"><%= request.getAttribute("error") != null ? (language.equals("vi") ? "Tên người dùng hoặc mật khẩu không đúng!" : "Invalid username or password!") : "" %></p>
        <p class="link">
            <a href="<%= request.getContextPath() %>/forgot-password"><%= language.equals("vi") ? "Quên mật khẩu?" : "Forgot password?" %></a>
        </p>
        <p class="link"><%= language.equals("vi") ? "Chưa có tài khoản?" : "Don't have an account?" %> <a href="<%= request.getContextPath() %>/register"><%= language.equals("vi") ? "Đăng ký tại đây" : "Register here" %></a></p>
    </div>

    <script>
        function validateForm() {
            const username = document.getElementById("username").value.trim();
            const password = document.getElementById("password").value.trim();
            const language = '<%= language %>';
            let isValid = true;

            document.getElementById("general-error").textContent = "";

            if (!username) {
                document.getElementById("general-error").textContent = language === "vi" ? "Vui lòng nhập tên người dùng!" : "Please enter username!";
                isValid = false;
            } else if (!password) {
                document.getElementById("general-error").textContent = language === "vi" ? "Vui lòng nhập mật khẩu!" : "Please enter password!";
                isValid = false;
            }

            return isValid;
        }

        // Toggle hiển thị mật khẩu
        document.getElementById("togglePassword").addEventListener("click", function () {
            const passwordInput = document.getElementById("password");
            const toggleIcon = this;
            if (passwordInput.type === "password") {
                passwordInput.type = "text";
                toggleIcon.classList.remove("fa-eye");
                toggleIcon.classList.add("fa-eye-slash");
            } else {
                passwordInput.type = "password";
                toggleIcon.classList.remove("fa-eye-slash");
                toggleIcon.classList.add("fa-eye");
            }
        });
    </script>
</body>
</html>