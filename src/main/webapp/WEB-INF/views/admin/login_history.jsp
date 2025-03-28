<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List" %>
<%@ page import="com.mycompany.oceanichotel.models.LoginHistory" %>
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
    <title><%= language.equals("vi") ? "Lịch sử đăng nhập - Khách sạn Oceanic" : "Login History - Oceanic Hotel" %></title>
    <link rel="icon" href="<%= request.getContextPath() %>/assets/images/logo.png" type="image/x-icon">
    <link rel="stylesheet" href="<%= request.getContextPath() %>/assets/css/main.css">
    <link rel="stylesheet" href="<%= request.getContextPath() %>/assets/css/dashboard.css">
    <script>
        window.contextPath = '<%= request.getContextPath() %>';
    </script>
    <script src="<%= request.getContextPath() %>/assets/js/main.js" defer></script>
    <script src="<%= request.getContextPath() %>/assets/js/theme.js" defer></script>
    <script src="<%= request.getContextPath() %>/assets/js/language.js" defer></script>
</head>
<body class="<%= theme.equals("dark") ? "dark-mode" : "" %>" data-theme="<%= theme %>">
    <div class="admin-container">
        <!-- Thanh điều hướng bên trái -->
        <nav class="sidebar">
            <div class="sidebar-header">
                <h3>Oceanic Hotel</h3>
            </div>
            <ul>
                <li><a href="<%= request.getContextPath() %>/admin/dashboard"><%= language.equals("vi") ? "Tổng quan" : "Dashboard" %></a></li>
                <li class="active"><a href="<%= request.getContextPath() %>/admin/users"><%= language.equals("vi") ? "Quản lý người dùng" : "User Management" %></a></li>
                <li><a href="<%= request.getContextPath() %>/admin/rooms"><%= language.equals("vi") ? "Quản lý phòng" : "Room Management" %></a></li>
                <li><a href="<%= request.getContextPath() %>/admin/bookings"><%= language.equals("vi") ? "Quản lý đặt phòng" : "Booking Management" %></a></li>
                <li><a href="<%= request.getContextPath() %>/admin/transactions"><%= language.equals("vi") ? "Quản lý giao dịch" : "Transaction Management" %></a></li>
                <li><a href="<%= request.getContextPath() %>/admin/settings"><%= language.equals("vi") ? "Cấu hình hệ thống" : "System Settings" %></a></li>
                <li><a href="<%= request.getContextPath() %>/admin/reports"><%= language.equals("vi") ? "Báo cáo" : "Reports" %></a></li>
                <li><a href="<%= request.getContextPath() %>/admin/logout"><%= language.equals("vi") ? "Đăng xuất" : "Logout" %></a></li>
            </ul>
        </nav>

        <!-- Nội dung chính -->
        <div class="main-content">
            <header>
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
                <h2><%= language.equals("vi") ? "Lịch sử đăng nhập" : "Login History" %></h2>
            </header>

            <table class="data-table">
                <thead>
                    <tr>
                        <th><%= language.equals("vi") ? "ID" : "ID" %></th>
                        <th><%= language.equals("vi") ? "Thời gian đăng nhập" : "Login Time" %></th>
                        <th><%= language.equals("vi") ? "Địa chỉ IP" : "IP Address" %></th>
                        <th><%= language.equals("vi") ? "Trình duyệt" : "Browser" %></th>
                    </tr>
                </thead>
                <tbody>
                    <% 
                        List<LoginHistory> loginHistory = (List<LoginHistory>) request.getAttribute("loginHistory");
                        if (loginHistory != null) {
                            for (LoginHistory history : loginHistory) {
                    %>
                    <tr>
                        <td><%= history.getId() %></td>
                        <td><%= history.getLoginTime() %></td>
                        <td><%= history.getIpAddress() %></td>
                        <td><%= history.getBrowser() %></td>
                    </tr>
                    <% 
                            }
                        } 
                    %>
                </tbody>
            </table>
        </div>
    </div>
</body>
</html>