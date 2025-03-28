<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List" %>
<%@ page import="com.mycompany.oceanichotel.models.User" %>
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
    <title><%= language.equals("vi") ? "Quản lý người dùng - Khách sạn Oceanic" : "User Management - Oceanic Hotel" %></title>
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
                <li><a href="<%= request.getContextPath() %>/logout"><%= language.equals("vi") ? "Đăng xuất" : "Logout" %></a></li>
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
                <h2><%= language.equals("vi") ? "Quản lý người dùng" : "User Management" %></h2>
            </header>

            <!-- Nút Check-in, Check-out -->
            <div class="action-buttons">
                <button class="action-btn check-in-btn"><%= language.equals("vi") ? "Check-in" : "Check-in" %></button>
                <button class="action-btn check-out-btn"><%= language.equals("vi") ? "Check-out" : "Check-out" %></button>
            </div>

            <!-- Bộ lọc và tìm kiếm -->
            <div class="table-header">
                <div class="filter">
                    <button class="filter-btn">
                        <span><%= language.equals("vi") ? "Bộ lọc" : "Filter" %></span>
                        <i class="fas fa-filter"></i>
                    </button>
                </div>
                <div class="search">
                    <input type="text" placeholder="<%= language.equals("vi") ? "Tìm kiếm theo tên người dùng" : "Search by username" %>">
                </div>
            </div>

            <!-- Bảng dữ liệu -->
            <table class="data-table">
                <thead>
                    <tr>
                        <th><%= language.equals("vi") ? "ID" : "ID" %></th>
                        <th><%= language.equals("vi") ? "Tên người dùng" : "Username" %></th>
                        <th><%= language.equals("vi") ? "Email" : "Email" %></th>
                        <th><%= language.equals("vi") ? "Vai trò" : "Role" %></th>
                        <th><%= language.equals("vi") ? "Hoạt động" : "Active" %></th>
                        <th><%= language.equals("vi") ? "Ngày tạo" : "Created At" %></th>
                        <th><%= language.equals("vi") ? "Hành động" : "Actions" %></th>
                    </tr>
                </thead>
                <tbody>
                    <% 
                        List<User> users = (List<User>) request.getAttribute("users");
                        if (users != null) {
                            for (User user : users) {
                    %>
                    <tr>
                        <td><%= user.getUserId() %></td>
                        <td><%= user.getUsername() %></td>
                        <td><%= user.getEmail() %></td>
                        <td><%= user.getRole() %></td>
                        <td>
                            <span class="status <%= user.isActive() ? "clean" : "dirty" %>">
                                <%= user.isActive() ? (language.equals("vi") ? "Có" : "Yes") : (language.equals("vi") ? "Không" : "No") %>
                            </span>
                        </td>
                        <td><%= user.getCreatedAt() %></td>
                        <td>
                            <a href="<%= request.getContextPath() %>/admin/users/edit?userId=<%= user.getUserId() %>">
                                <%= language.equals("vi") ? "Sửa" : "Edit" %>
                            </a> |
                            <a href="<%= request.getContextPath() %>/admin/users/delete?userId=<%= user.getUserId() %>" 
                               onclick="return confirm('<%= language.equals("vi") ? "Bạn có chắc muốn xóa?" : "Are you sure you want to delete?" %>')">
                                <%= language.equals("vi") ? "Xóa" : "Delete" %>
                            </a> |
                            <a href="<%= request.getContextPath() %>/admin/users/login-history?userId=<%= user.getUserId() %>">
                                <%= language.equals("vi") ? "Lịch sử đăng nhập" : "Login History" %>
                            </a>
                        </td>
                    </tr>
                    <% 
                            }
                        } 
                    %>
                </tbody>
            </table>

            <!-- Phân trang -->
            <div class="pagination">
                <button class="page-btn">Previous</button>
                <button class="page-btn active">1</button>
                <button class="page-btn">2</button>
                <button class="page-btn">3</button>
                <span>...</span>
                <button class="page-btn">7</button>
                <button class="page-btn">Next</button>
            </div>
        </div>
    </div>
</body>
</html>