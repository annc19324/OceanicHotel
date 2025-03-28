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
        <title><%= language.equals("vi") ? "Thêm người dùng - Khách sạn Oceanic" : "Add User - Oceanic Hotel"%></title>
        <link rel="icon" href="<%= request.getContextPath()%>/assets/images/logo.png" type="image/x-icon">
        <link rel="stylesheet" href="<%= request.getContextPath()%>/assets/css/main.css">
        <link rel="stylesheet" href="<%= request.getContextPath()%>/assets/css/dashboard.css">
        <script>
        window.contextPath = '<%= request.getContextPath()%>';
        </script>
        <script type="module" src="<%= request.getContextPath()%>/assets/js/main.js"></script>
        <script type="module" src="<%= request.getContextPath()%>/assets/js/theme.js"></script>
        <script type="module" src="<%= request.getContextPath()%>/assets/js/language.js"></script>
    </head>
    <body class="<%= theme.equals("dark") ? "dark-mode" : ""%>" data-theme="<%= theme%>">
        <div class="admin-container">
            <!-- Thanh điều hướng bên trái -->
            <nav class="sidebar">
                <div class="sidebar-header">
                    <h3>Oceanic Hotel</h3>
                </div>
                <ul>
                    <li><a href="<%= request.getContextPath()%>/admin/dashboard"><%= language.equals("vi") ? "Tổng quan" : "Dashboard"%></a></li>
                    <li class="active"><a href="<%= request.getContextPath()%>/admin/users"><%= language.equals("vi") ? "Quản lý người dùng" : "User Management"%></a></li>
                    <li><a href="<%= request.getContextPath()%>/admin/rooms"><%= language.equals("vi") ? "Quản lý phòng" : "Room Management"%></a></li>
                    <li><a href="<%= request.getContextPath()%>/admin/bookings"><%= language.equals("vi") ? "Quản lý đặt phòng" : "Booking Management"%></a></li>
                    <li><a href="<%= request.getContextPath()%>/admin/transactions"><%= language.equals("vi") ? "Quản lý giao dịch" : "Transaction Management"%></a></li>
                    <li><a href="<%= request.getContextPath()%>/admin/settings"><%= language.equals("vi") ? "Cấu hình hệ thống" : "System Settings"%></a></li>
                    <li><a href="<%= request.getContextPath()%>/admin/reports"><%= language.equals("vi") ? "Báo cáo" : "Reports"%></a></li>
                    <li><a href="<%= request.getContextPath()%>/admin/logout"><%= language.equals("vi") ? "Đăng xuất" : "Logout"%></a></li>
                </ul>
            </nav>

            <!-- Nội dung chính -->
            <div class="main-content">
                <header>
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
                    <h2><%= language.equals("vi") ? "Thêm người dùng" : "Add User"%></h2>
                </header>

                <form action="<%= request.getContextPath()%>/admin/users/add" method="POST">
                    <div class="form-group">
                        <label for="username"><%= language.equals("vi") ? "Tên người dùng" : "Username"%></label>
                        <input type="text" id="username" name="username" required>
                    </div>
                    <div class="form-group">
                        <label for="email"><%= language.equals("vi") ? "Email" : "Email"%></label>
                        <input type="email" id="email" name="email" required>
                    </div>
                    <div class="form-group">
                        <label for="password"><%= language.equals("vi") ? "Mật khẩu" : "Password"%></label>
                        <input type="password" id="password" name="password" required>
                    </div>
                    <div class="form-group">
                        <label for="role"><%= language.equals("vi") ? "Vai trò" : "Role"%></label>
                        <select id="role" name="role" required>
                            <option value="user"><%= language.equals("vi") ? "Người dùng" : "User"%></option>
                            <option value="admin"><%= language.equals("vi") ? "Quản trị viên" : "Admin"%></option>
                        </select>
                    </div>
                    <div class="form-group">
                        <label for="isActive"><%= language.equals("vi") ? "Hoạt động" : "Active"%></label>
                        <input type="checkbox" id="isActive" name="isActive" value="true">
                    </div>
                    <button type="submit" class="action-btn add-btn"><%= language.equals("vi") ? "Thêm" : "Add"%></button>
                </form>
            </div>
        </div>
    </body>
</html>