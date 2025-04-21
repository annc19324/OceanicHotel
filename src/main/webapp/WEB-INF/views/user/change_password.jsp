<%-- 
    Document   : change_password
    Created on : Apr 10, 2025, 9:10:40 AM
    Author     : annc1
--%>

<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ page import="com.mycompany.oceanichotel.models.User" %>
<%
    User currentUser = (User) session.getAttribute("user");
    if (currentUser == null) {
        response.sendRedirect(request.getContextPath() + "/login");
        return;
    }
    String language = currentUser != null && currentUser.getLanguage() != null ? currentUser.getLanguage() : "en";
    String theme = currentUser != null && currentUser.getTheme() != null ? currentUser.getTheme() : "light";
    session.setAttribute("language", language);
    session.setAttribute("theme", theme);
%>
<!DOCTYPE html>
<html lang="<%= language %>">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title><%= language.equals("vi") ? "Đổi mật khẩu - Khách sạn Oceanic" : "Change Password - Oceanic Hotel" %></title>
        <link rel="icon" href="<%= request.getContextPath() %>/assets/images/logo.png" type="image/x-icon">
        <link href="https://cdn.jsdelivr.net/npm/tailwindcss@2.2.19/dist/tailwind.min.css" rel="stylesheet">
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0-beta3/css/all.min.css">
        <style>
            body {
                font-family: Arial, sans-serif;
                margin: 0;
                background: #f0f7fa;
                color: #1e3a5f;
            }
            .dark-mode {
                background: #1e3a5f;
                color: #e6f0fa;
            }
            .header-bg {
                background: #1e3a5f;
                position: fixed;
                width: 100%;
                top: 0;
                z-index: 10;
                padding: 1rem 1.5rem;
                display: flex;
                justify-content: space-between;
                align-items: center;
                box-shadow: 0 2px 4px rgba(0, 51, 102, 0.2);
            }
            .header-bg a, .header-bg span {
                color: #fff;
                text-decoration: none;
                cursor: pointer;
            }
            .header-bg a:hover, .header-bg span:hover {
                color: #a3bffa;
            }
            .content {
                margin-top: 100px;
                max-width: 400px;
                margin-left: auto;
                margin-right: auto;
                padding: 20px;
                background: #fff;
                border-radius: 8px;
                box-shadow: 0 2px 4px rgba(0, 51, 102, 0.2);
            }
            .dark-mode .content {
                background: #2c5282;
            }
            h1 {
                font-size: 1.5rem;
                text-align: center;
                margin-bottom: 20px;
            }
            .form-group {
                margin-bottom: 15px;
            }
            label {
                display: block;
                font-weight: bold;
                margin-bottom: 5px;
                font-size: 0.9rem;
            }
            input[type="password"] {
                width: 100%;
                padding: 8px;
                border: 1px solid #ccc;
                border-radius: 4px;
                font-size: 0.9rem;
            }
            .dark-mode input[type="password"] {
                background: #4a6f9c;
                border-color: #a3bffa;
                color: #e6f0fa;
            }
            .btn {
                background: #2b6cb0;
                color: #fff;
                padding: 8px 16px;
                border: none;
                border-radius: 4px;
                cursor: pointer;
                transition: background 0.2s;
                font-size: 0.9rem;
            }
            .btn:hover {
                background: #1e4976;
            }
            .message {
                text-align: center;
                margin-top: 15px;
                color: #10b981;
                font-size: 0.9rem;
            }
            .error {
                color: #ef4444;
            }
        </style>
    </head>
    <body class="<%= theme.equals("dark") ? "dark-mode" : "" %>">
        <!-- Header -->
        <header class="header-bg">
            <div class="flex items-center space-x-3">
                <img src="<%= request.getContextPath() %>/assets/images/width_800.jpg" alt="Logo" class="h-8">
                <a class="font-bold text-lg" href="<%= request.getContextPath() %>/user/dashboard">Oceanic Hotel</a>
            </div>
            <div class="flex items-center space-x-6">
                <nav class="flex items-center space-x-6">
                    <a href="<%= request.getContextPath() %>/user/profile"><%= language.equals("vi") ? "Hồ sơ" : "Profile" %></a>
                    <a href="<%= request.getContextPath() %>/user/bookings" class="text-white hover:text-blue-300 transition"><%= "vi".equals(language) ? "Chi Tiết Đặt phòng" : "Detail Bookings" %></a>


                    <a href="<%= request.getContextPath() %>/user/change-password"><%= language.equals("vi") ? "Đổi mật khẩu" : "Change Password" %></a>
                    <a href="<%= request.getContextPath() %>/logout"><%= language.equals("vi") ? "Đăng xuất" : "Logout" %></a>
                    <span id="languageToggle" onclick="changeLanguage('<%= language.equals("vi") ? "en" : "vi" %>')">
                        <i class="fas fa-globe mr-1"></i><%= language.equals("vi") ? "EN" : "VI" %>
                    </span>
                    <span id="themeToggle" onclick="changeTheme('<%= theme.equals("dark") ? "light" : "dark" %>')">
                        <i class="fas <%= theme.equals("dark") ? "fa-sun" : "fa-moon" %>"></i>
                    </span>
                </nav>
            </div>
        </header>

        <!-- Main Content -->
        <div class="content">
            <h1><%= language.equals("vi") ? "Đổi mật khẩu" : "Change Password" %></h1>
            <form action="<%= request.getContextPath() %>/user/change-password" method="POST">
                <div class="form-group">
                    <label for="currentPassword"><%= language.equals("vi") ? "Mật khẩu hiện tại" : "Current Password" %></label>
                    <input type="password" id="currentPassword" name="currentPassword" required placeholder="<%= language.equals("vi") ? "Nhập mật khẩu hiện tại" : "Enter current password" %>">
                </div>
                <div class="form-group">
                    <label for="newPassword"><%= language.equals("vi") ? "Mật khẩu mới" : "New Password" %></label>
                    <input type="password" id="newPassword" name="newPassword" required placeholder="<%= language.equals("vi") ? "Nhập mật khẩu mới" : "Enter new password" %>">
                </div>
                <div class="form-group">
                    <label for="confirmPassword"><%= language.equals("vi") ? "Xác nhận mật khẩu mới" : "Confirm New Password" %></label>
                    <input type="password" id="confirmPassword" name="confirmPassword" required placeholder="<%= language.equals("vi") ? "Xác nhận mật khẩu" : "Confirm password" %>">
                </div>
                <div class="form-group text-center">
                    <button type="submit" class="btn"><%= language.equals("vi") ? "Cập nhật mật khẩu" : "Update Password" %></button>
                    <a href="<%= request.getContextPath() %>/user/profile" class="ml-4 text-blue-500 hover:underline">
                        <%= language.equals("vi") ? "Quay lại" : "Back" %>
                    </a>
                </div>
            </form>
            <c:if test="${not empty message}">
                <div class="message <%= request.getAttribute("error") != null ? "error" : "" %>">${message}</div>
            </c:if>
        </div>

        <script>
            function changeLanguage(lang) {
                fetch('<%= request.getContextPath() %>/user/change-language', {
                    method: 'POST',
                    headers: {'Content-Type': 'application/x-www-form-urlencoded'},
                    body: 'language=' + encodeURIComponent(lang)
                }).then(response => {
                    if (response.ok) {
                        location.reload();
                    }
                }).catch(error => console.error('Error changing language: ', error));
            }

            function changeTheme(newTheme) {
                fetch('<%= request.getContextPath() %>/user/change-theme', {
                    method: 'POST',
                    headers: {'Content-Type': 'application/x-www-form-urlencoded'},
                    body: 'theme=' + encodeURIComponent(newTheme)
                }).then(response => {
                    if (response.ok) {
                        document.body.classList.toggle('dark-mode', newTheme === 'dark');
                        const themeIcon = document.querySelector('#themeToggle i');
                        themeIcon.className = 'fas ' + (newTheme === 'dark' ? 'fa-sun' : 'fa-moon');
                        document.getElementById('themeToggle').setAttribute('onclick', "changeTheme('" + (newTheme === 'dark' ? 'light' : 'dark') + "')");
                    }
                }).catch(error => console.error('Error changing theme: ', error));
            }
        </script>
    </body>
</html>