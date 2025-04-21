<%--
    Copyright (c) 2025 annc19324
    All rights reserved.

    This code is the property of annc19324.
    Unauthorized copying or distribution is prohibited.
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ page import="com.mycompany.oceanichotel.models.User" %>
<%@ page import="java.text.SimpleDateFormat" %>
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

    SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
    String dobStr = currentUser.getDateOfBirth() != null ? sdf.format(currentUser.getDateOfBirth()) : "";
%>
<!DOCTYPE html>
<html lang="<%= language %>">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title><%= language.equals("vi") ? "Hồ sơ - Khách sạn Oceanic" : "Profile - Oceanic Hotel" %></title>
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
                max-width: 400px; /* Giảm từ 600px xuống 400px */
                margin-left: auto;
                margin-right: auto;
                padding: 10px; /* Giảm từ 15px xuống 10px */
                background: #fff;
                border-radius: 8px;
                box-shadow: 0 2px 4px rgba(0, 51, 102, 0.2);

            }
            .dark-mode .content {
                background: #2c5282;

            }
            h1 {
                font-size: 1.25rem; /* Giảm từ 1.5rem xuống 1.25rem */
                text-align: center;
                margin-bottom: 10px; /* Giảm từ 15px xuống 10px */
            }
            .form-container {
                display: grid;
                grid-template-columns: 1fr 1fr; /* Chia thành 2 cột đều nhau */
                gap: 10px; /* Khoảng cách giữa các cột và hàng */
            }
            .form-group {
                margin-bottom: 8px; /* Giảm từ 10px xuống 8px */
            }
            .form-group.full-width {
                grid-column: span 2; /* Các phần tử full-width chiếm cả 2 cột */
            }
            label {
                display: block;
                font-weight: bold;
                margin-bottom: 2px; /* Giảm từ 3px xuống 2px */
                font-size: 0.85rem; /* Giảm từ 0.9rem xuống 0.85rem */
            }
            input[type="text"], input[type="email"], input[type="tel"], input[type="date"], input[type="file"], select {
                width: 100%;
                padding: 6px; /* Giảm từ 8px xuống 6px */
                border: 1px solid #ccc;
                border-radius: 4px;
                font-size: 0.85rem; /* Giảm từ 0.9rem xuống 0.85rem */
            }
            .dark-mode input[type="text"], .dark-mode input[type="email"], .dark-mode input[type="tel"],
            .dark-mode input[type="date"], .dark-mode input[type="file"], .dark-mode select {
                background: #4a6f9c;
                border-color: #a3bffa;
                color: #e6f0fa;
            }
            .btn {
                background: #2b6cb0;
                color: #fff;
                padding: 6px 12px; /* Giảm từ 8px 16px xuống 6px 12px */
                border: none;
                border-radius: 4px;
                cursor: pointer;
                transition: background 0.2s;
                font-size: 0.85rem; /* Giảm từ 0.9rem xuống 0.85rem */
            }
            .btn:hover {
                background: #1e4976;
            }
            .message {
                text-align: center;
                margin-top: 8px; /* Giảm từ 10px xuống 8px */
                color: #10b981;
                font-size: 0.85rem; /* Giảm từ 0.9rem xuống 0.85rem */
            }
            .error {
                color: #ef4444;
            }
            .avatar-preview {
                width: 80px; /* Giảm từ 100px xuống 80px */
                height: 80px; /* Giảm từ 100px xuống 80px */
                object-fit: cover;
                border-radius: 50%;
                margin-bottom: 8px; /* Giảm từ 10px xuống 8px */
                display: block;
                margin-left: auto;
                margin-right: auto;
            }
            .avatar {
                width: 48px;
                height: 48px;
                border-radius: 50%;
                object-fit: cover;
                cursor: pointer;
            }
            .avatar-container {
                display: flex;
                align-items: center;
            }
            .modal {
                display: none;
                position: fixed;
                top: 0;
                left: 0;
                width: 100%;
                height: 100%;
                background-color: rgba(0,0,0,0.8);
                z-index: 1000;
            }
            .modal-content {
                position: absolute;
                top: 50%;
                left: 50%;
                transform: translate(-50%, -50%);
                max-width: 90%;
                max-height: 90%;
            }
            .modal-image {
                width: 300px;
                height: auto;
                border-radius: 10px;
            }
        </style>
    </head>
    <body class="<%= theme.equals("dark") ? "dark-mode" : "" %>">
        <div class="">
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
                    <% if (currentUser != null) { %>
                    <div class="avatar-container">
                        <img src="<%= currentUser.getAvatar() != null && !currentUser.getAvatar().isEmpty() ? request.getContextPath() + "/assets/images/" + currentUser.getAvatar() : request.getContextPath() + "/assets/images/avatar-default.jpg" %>" 
                             alt="Avatar" class="avatar" 
                             onclick="showModal()"
                             onerror="this.src='<%= request.getContextPath() %>/assets/images/avatar-default.jpg'; this.onerror=null;">
                    </div>
                    <% } %>
                </div>
            </header>

            <!-- Modal để hiển thị ảnh lớn -->
            <% if (currentUser != null) { %>
            <div id="avatarModal" class="modal">
                <div class="modal-content">
                    <img src="<%= currentUser.getAvatar() != null && !currentUser.getAvatar().isEmpty() ? request.getContextPath() + "/assets/images/" + currentUser.getAvatar() : request.getContextPath() + "/assets/images/avatar-default.jpg" %>" 
                         alt="Large Avatar" class="modal-image"
                         onerror="this.src='<%= request.getContextPath() %>/assets/images/avatar-default.jpg'; this.onerror=null;">
                </div>
            </div>
            <% } %>

            <!-- Main Content -->
            <div class="content">
                <h1><%= language.equals("vi") ? "Hồ sơ của bạn" : "Your Profile" %></h1>
                <form action="<%= request.getContextPath() %>/user/profile" method="POST" enctype="multipart/form-data">
                    <div class="form-group full-width text-center">
                        <img src="<%= currentUser.getAvatar() != null && !currentUser.getAvatar().isEmpty() ? request.getContextPath() + "/assets/images/" + currentUser.getAvatar() : request.getContextPath() + "/assets/images/avatar-default.jpg" %>" 
                             alt="Avatar" class="avatar-preview" id="avatarPreview">
                        <label for="avatar"><%= language.equals("vi") ? "Ảnh đại diện" : "Avatar" %></label>
                        <input type="file" id="avatar" name="avatar" accept="image/*" onchange="previewAvatar(event)">
                    </div>
                    <div class="form-container">
                        <div class="form-group">
                            <label for="username"><%= language.equals("vi") ? "Tên người dùng" : "Username" %></label>
                            <input type="text" id="username" name="username" value="<%= currentUser.getUsername() != null ? currentUser.getUsername() : "" %>" readonly>
                        </div>
                        <div class="form-group">
                            <label for="fullName"><%= language.equals("vi") ? "Họ và tên" : "Full Name" %></label>
                            <input type="text" id="fullName" name="fullName" value="<%= currentUser.getFullName() != null ? currentUser.getFullName() : "" %>" required>
                        </div>
                        <div class="form-group">
                            <label for="email"><%= language.equals("vi") ? "Email" : "Email" %></label>
                            <input type="email" id="email" name="email" value="<%= currentUser.getEmail() != null ? currentUser.getEmail() : "" %>" required>
                        </div>
                        <div class="form-group">
                            <label for="phoneNumber"><%= language.equals("vi") ? "Số điện thoại" : "Phone Number" %></label>
                            <input type="tel" id="phoneNumber" name="phoneNumber" value="<%= currentUser.getPhoneNumber() != null ? currentUser.getPhoneNumber() : "" %>">
                        </div>
                        <div class="form-group">
                            <label for="cccd"><%= language.equals("vi") ? "CCCD" : "ID Card" %></label>
                            <input type="text" id="cccd" name="cccd" value="<%= currentUser.getCccd() != null ? currentUser.getCccd() : "" %>">
                        </div>
                        <div class="form-group">
                            <label for="dateOfBirth"><%= language.equals("vi") ? "Ngày sinh" : "Date of Birth" %></label>
                            <input type="date" id="dateOfBirth" name="dateOfBirth" value="<%= dobStr %>">
                        </div>
                        <div class="form-group">
                            <label for="gender"><%= language.equals("vi") ? "Giới tính" : "Gender" %></label>
                            <select id="gender" name="gender" class="w-full p-2 border border-gray-300 rounded">
                                <option value="" <%= currentUser.getGender() == null ? "selected" : "" %>><%= language.equals("vi") ? "Chọn" : "Select" %></option>
                                <option value="Male" <%= "Male".equals(currentUser.getGender()) ? "selected" : "" %>><%= language.equals("vi") ? "Nam" : "Male" %></option>
                                <option value="Female" <%= "Female".equals(currentUser.getGender()) ? "selected" : "" %>><%= language.equals("vi") ? "Nữ" : "Female" %></option>
                                <option value="Other" <%= "Other".equals(currentUser.getGender()) ? "selected" : "" %>><%= language.equals("vi") ? "Khác" : "Other" %></option>
                            </select>
                        </div>
                    </div>
                    <div class="form-group full-width text-center">
                        <button type="submit" class="btn"><%= language.equals("vi") ? "Cập nhật" : "Update" %></button>
                        <a href="<%= request.getContextPath() %>/user/dashboard" class="ml-4 text-blue-500 hover:underline">
                            <%= language.equals("vi") ? "Quay lại" : "Back" %>
                        </a>
                    </div>
                </form>
                <c:if test="${not empty message}">
                    <div class="message <%= request.getAttribute("error") != null ? "error" : "" %>">${message}</div>
                </c:if>
            </div>
        </div>

        <script>
            function showModal() {
                const modal = document.getElementById('avatarModal');
                modal.style.display = 'block';
                modal.onclick = function () {
                    modal.style.display = 'none';
                }
            }

            function changeLanguage(lang) {
                fetch('<%= request.getContextPath() %>/user/change-language', {
                    method: 'POST',
                    headers: {'Content-Type': 'application/x-www-form-urlencoded'},
                    body: 'language=' + encodeURIComponent(lang)
                }).then(response => {
                    if (response.ok) {
                        location.reload();
                    } else {
                        console.error('Lỗi khi thay đổi ngôn ngữ: ' + response.status);
                    }
                }).catch(error => console.error('Lỗi mạng: ', error));
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
                    } else {
                        console.error('Lỗi khi thay đổi chủ đề: ' + response.status);
                    }
                }).catch(error => console.error('Lỗi mạng: ', error));
            }

            function previewAvatar(event) {
                const file = event.target.files[0];
                if (file) {
                    const reader = new FileReader();
                    reader.onload = function (e) {
                        document.getElementById('avatarPreview').src = e.target.result;
                    };
                    reader.readAsDataURL(file);
                }
            }
        </script>
    </body>
</html>