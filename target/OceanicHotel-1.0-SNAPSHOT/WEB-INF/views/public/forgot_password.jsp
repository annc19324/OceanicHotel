<%--
    Copyright (c) 2025 annc19324
    All rights reserved.

    This code is the property of annc19324.
    Unauthorized copying or distribution is prohibited.
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.time.LocalDateTime" %>
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
    String username = (String) request.getAttribute("username");
%>
<!DOCTYPE html>
<html lang="<%= language %>">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><%= language.equals("vi") ? "Quên mật khẩu - Khách sạn Oceanic" : "Forgot Password - Oceanic Hotel" %></title>
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
        .input-wrapper { margin-bottom: 20px; }
        input[type="email"], input[type="text"], input[type="password"] {
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
        .change-email-btn {
            width: 100%;
            padding: 10px;
            background-color: #6c757d;
            color: #fff;
            border: none;
            border-radius: 4px;
            cursor: pointer;
            margin-top: 10px;
        }
        .change-email-btn:hover { background-color: #5a6268; }
        body.dark-mode .change-email-btn { background-color: #5a6268; }
        .error { color: red; text-align: center; margin-top: 10px; font-weight: normal; min-height: 20px; }
        body.dark-mode .error { color: #ff6666; }
        .success { color: green; text-align: center; margin-top: 10px; font-weight: normal; min-height: 20px; }
        body.dark-mode .success { color: #66ff66; }
        .link { text-align: center; margin-top: 15px; font-weight: normal; }
        .link a { color: #007bff; text-decoration: none; }
        .link a:hover { text-decoration: underline; }
        body.dark-mode .link a { color: #66b3ff; }
        .settings { position: absolute; top: 10px; right: 10px; display: flex; gap: 10px; }
        .settings select { padding: 5px; border-radius: 4px; font-family: 'Montserrat', sans-serif; }
        .timer { font-size: 14px; color: #333; margin-top: 10px; }
        body.dark-mode .timer { color: #ccc; }
        .username-display { margin: 10px 0; font-weight: bold; }
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
        <h2><%= language.equals("vi") ? "Quên mật khẩu" : "Forgot Password" %></h2>
        <% if (session.getAttribute("resetToken") == null && username == null) { %>
            <form action="<%= request.getContextPath() %>/forgot-password" method="post" onsubmit="return validateEmailForm()">
                <div class="input-wrapper">
                    <label for="email"><%= language.equals("vi") ? "Email:" : "Email:" %></label>
                    <input type="email" id="email" name="email" value="<%= request.getParameter("email") != null ? request.getParameter("email") : "" %>" required>
                </div>
                <button type="submit"><%= language.equals("vi") ? "Kiểm tra" : "Check" %></button>
            </form>
        <% } else if (session.getAttribute("resetToken") == null && username != null) { %>
            <p class="username-display"><%= language.equals("vi") ? "Tài khoản liên kết: " : "Associated account: " %><%= username %></p>
            <form action="<%= request.getContextPath() %>/forgot-password" method="post">
                <input type="hidden" name="email" value="<%= request.getParameter("email") %>">
                <input type="hidden" name="step" value="sendCode">
                <button type="submit"><%= language.equals("vi") ? "Gửi mã xác nhận" : "Send Verification Code" %></button>
            </form>
            <form action="<%= request.getContextPath() %>/forgot-password" method="get">
                <button type="submit" class="change-email-btn"><%= language.equals("vi") ? "Thử email khác" : "Try another email" %></button>
            </form>
        <% } else { %>
            <p class="success"><%= request.getAttribute("success") != null ? request.getAttribute("success") : "" %></p>
            <div id="timer" class="timer"></div>
            <form action="<%= request.getContextPath() %>/forgot-password" method="post" onsubmit="return validateResetForm()">
                <input type="hidden" name="step" value="reset">
                <div class="input-wrapper">
                    <label for="code"><%= language.equals("vi") ? "Mã xác nhận:" : "Verification Code:" %></label>
                    <input type="text" id="code" name="code" required>
                </div>
                <div class="input-wrapper">
                    <label for="new_password"><%= language.equals("vi") ? "Mật khẩu mới:" : "New Password:" %></label>
                    <input type="password" id="new_password" name="new_password" required>
                </div>
                <button type="submit"><%= language.equals("vi") ? "Đặt lại mật khẩu" : "Reset Password" %></button>
            </form>
            <form action="<%= request.getContextPath() %>/forgot-password" method="get">
                <button type="submit" class="change-email-btn"><%= language.equals("vi") ? "Đổi email khác" : "Change to another email" %></button>
            </form>
        <% } %>
        <p class="error"><%= request.getAttribute("error") != null ? request.getAttribute("error") : "" %></p>
        <p class="link"><a href="<%= request.getContextPath() %>/login"><%= language.equals("vi") ? "Quay lại đăng nhập" : "Back to Login" %></a></p>
    </div>
    <script>
        function validateEmailForm() {
            const email = document.getElementById("email").value.trim();
            const regex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
            const language = '<%= language %>';
            if (!regex.test(email)) {
                document.querySelector(".error").textContent = language === "vi" ? "Email không hợp lệ!" : "Invalid email format!";
                return false;
            }
            return true;
        }

        function validateResetForm() {
            const code = document.getElementById("code").value.trim();
            const newPassword = document.getElementById("new_password").value;
            const regex = /^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@#$%^&+=!]).{8,}$/;
            const language = '<%= language %>';
            let isValid = true;

            if (!code) {
                document.querySelector(".error").textContent = language === "vi" ? "Vui lòng nhập mã xác nhận!" : "Please enter verification code!";
                isValid = false;
            } else if (!regex.test(newPassword)) {
                document.querySelector(".error").textContent = language === "vi" ? "Mật khẩu phải có ít nhất 8 ký tự, bao gồm chữ hoa, chữ thường, số và ký tự đặc biệt!" : "Password must be at least 8 characters with uppercase, lowercase, number, and special character!";
                isValid = false;
            }
            return isValid;
        }

        <% if (session.getAttribute("resetToken") != null) { %>
            const expiryTimeStr = '<%= session.getAttribute("tokenExpiry") != null ? ((LocalDateTime) session.getAttribute("tokenExpiry")).toString() : "" %>';
            const language = '<%= language %>';
            if (expiryTimeStr) {
                const expiryTime = new Date(expiryTimeStr.replace("T", " ")); // Chuyển đổi định dạng ISO thành Date
                function updateTimer() {
                    const now = new Date();
                    const timeLeft = expiryTime - now;
                    if (timeLeft <= 0) {
                        document.getElementById("timer").textContent = language === "vi" ? "Mã đã hết hạn!" : "Code has expired!";
                        document.querySelector(".error").textContent = language === "vi" ? "Mã xác nhận đã hết hạn!" : "Verification code has expired!";
                        document.querySelector("button[type='submit']").disabled = true;
                    } else {
                        const minutes = Math.floor(timeLeft / 60000);
                        const seconds = Math.floor((timeLeft % 60000) / 1000);
                        document.getElementById("timer").textContent = language === "vi" ? 
                            `Thời gian còn lại: ${minutes} phút ${seconds} giây` : 
                            `Time remaining: ${minutes} minutes ${seconds} seconds`;
                    }
                }
                setInterval(updateTimer, 1000);
                updateTimer();
            } else {
                document.getElementById("timer").textContent = "Error: Token expiry time not set!";
            }
        <% } %>
    </script>
</body>
</html>