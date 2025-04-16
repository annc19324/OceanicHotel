<%--
    Copyright (c) 2025 annc19324
    All rights reserved.

    This code is the property of annc19324.
    Unauthorized copying or distribution is prohibited.
--%>
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
    String error = (String) request.getAttribute("error");
%>
<!DOCTYPE html>
<html lang="<%= language%>">
    <head>
        <meta charset="UTF-8">
        <title><%= language.equals("vi") ? "Cấu hình hệ thống - Khách sạn Oceanic" : "System Settings - Oceanic Hotel"%></title>
        <link rel="icon" href="<%= request.getContextPath()%>/assets/images/logo.png" type="image/x-icon">
        <link rel="stylesheet" href="<%= request.getContextPath()%>/assets/css/main.css">
        <link rel="stylesheet" href="<%= request.getContextPath()%>/assets/css/sidebar.css">
        <link rel="stylesheet" href="<%= request.getContextPath()%>/assets/css/form.css">
        <link rel="stylesheet" href="<%= request.getContextPath()%>/assets/css/modal.css">
    </head>
    <body class="<%= theme.equals("dark") ? "dark-mode" : ""%>" data-theme="<%= theme%>">
        <div class="admin-container">
            <nav class="sidebar">
                <div class="sidebar-header">
                    <a style="color: white; margin-bottom: 20px; font-size: 24px; font-weight: 600; letter-spacing: 0.5px;" href="<%= request.getContextPath()%>/admin/dashboard">Oceanic Hotel
                    </a>
                </div>
                <ul>
                    <li><a href="<%= request.getContextPath()%>/admin/dashboard"><%= language.equals("vi") ? "Tổng quan" : "Dashboard"%></a></li>
                    <li><a href="<%= request.getContextPath()%>/admin/users"><%= language.equals("vi") ? "Quản lý người dùng" : "User Management"%></a></li>
                    <li><a href="<%= request.getContextPath()%>/admin/room-types"><%= language.equals("vi") ? "Quản lý loại phòng" : "Room Type Management"%></a></li>

                    <li><a href="<%= request.getContextPath()%>/admin/rooms"><%= language.equals("vi") ? "Quản lý phòng" : "Room Management"%></a></li>
                    <li><a href="<%= request.getContextPath()%>/admin/bookings"><%= language.equals("vi") ? "Quản lý đặt phòng" : "Booking Management"%></a></li>
                    <li><a href="<%= request.getContextPath()%>/admin/transactions"><%= language.equals("vi") ? "Quản lý giao dịch" : "Transaction Management"%></a></li>
                    <li class="active"><a href="<%= request.getContextPath()%>/admin/settings"><%= language.equals("vi") ? "Cấu hình hệ thống" : "System Settings"%></a></li>
                    <li><a href="<%= request.getContextPath()%>/admin/reports"><%= language.equals("vi") ? "Báo cáo" : "Reports"%></a></li>
                    <li><a href="<%= request.getContextPath()%>/logout"><%= language.equals("vi") ? "Đăng xuất" : "Logout"%></a></li>
                </ul>
            </nav>
            <div class="main-content">

                <form action="<%= request.getContextPath()%>/admin/settings/update" method="POST">
                    <div class="form-group">
                        <label for="defaultLanguage"><%= language.equals("vi") ? "Ngôn ngữ mặc định" : "Default Language"%></label>
                        <select id="defaultLanguage" name="defaultLanguage" required>
                            <option value="en" <%= language.equals("en") ? "selected" : ""%>><%= language.equals("vi") ? "Tiếng Anh" : "English"%></option>
                            <option value="vi" <%= language.equals("vi") ? "selected" : ""%>><%= language.equals("vi") ? "Tiếng Việt" : "Vietnamese"%></option>
                        </select>
                    </div>
                    <div class="form-group">
                        <label for="defaultTheme"><%= language.equals("vi") ? "Giao diện mặc định" : "Default Theme"%></label>
                        <select id="defaultTheme" name="defaultTheme" required>
                            <option value="light" <%= theme.equals("light") ? "selected" : ""%>><%= language.equals("vi") ? "Chế độ sáng" : "Light Mode"%></option>
                            <option value="dark" <%= theme.equals("dark") ? "selected" : ""%>><%= language.equals("vi") ? "Chế độ tối" : "Dark Mode"%></option>
                        </select>
                    </div>
                    <div class="form-buttons">
                        <button type="submit" class="action-btn add-btn"><%= language.equals("vi") ? "Lưu" : "Save"%></button>
                    </div>
                </form>
                <% if (error != null) {%>
                <div class="custom-modal" id="errorModal" style="display: flex;">
                    <div class="modal-content animate-modal">
                        <h3><%= language.equals("vi") ? "Lỗi" : "Error"%></h3>
                        <p><%= error%></p>
                        <div class="modal-buttons">
                            <button class="modal-btn cancel-btn" onclick="document.getElementById('errorModal').style.display = 'none'">
                                <%= language.equals("vi") ? "Đóng" : "Close"%>
                            </button>
                        </div>
                    </div>
                </div>
                <% }%>
            </div>
        </div>
        <script>
            function changeLanguage() {
                fetch('<%= request.getContextPath()%>/language', {
                    method: 'POST',
                    headers: {'Content-Type': 'application/x-www-form-urlencoded'},
                    body: 'language=' + encodeURIComponent(document.getElementById('languageSelect').value)
                }).then(() => location.reload());
            }

            function changeTheme() {
                const theme = document.getElementById('themeSelect').value;
                fetch('<%= request.getContextPath()%>/theme', {
                    method: 'POST',
                    headers: {'Content-Type': 'application/x-www-form-urlencoded'},
                    body: 'theme=' + encodeURIComponent(theme)
                }).then(() => {
                    document.body.className = theme === 'dark' ? 'dark-mode' : '';
                    document.body.setAttribute('data-theme', theme);
                });
            }
        </script>
    </body>
</html>