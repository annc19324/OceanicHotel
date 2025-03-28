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
    // Giả lập dữ liệu tổng quan (sẽ được thay thế bằng dữ liệu từ database)
    int checkInToday = (Integer) request.getAttribute("checkInToday") != null ? (Integer) request.getAttribute("checkInToday") : 0;
    int checkOutToday = (Integer) request.getAttribute("checkOutToday") != null ? (Integer) request.getAttribute("checkOutToday") : 0;
    int totalInHotel = (Integer) request.getAttribute("totalInHotel") != null ? (Integer) request.getAttribute("totalInHotel") : 0;
    int availableRooms = (Integer) request.getAttribute("availableRooms") != null ? (Integer) request.getAttribute("availableRooms") : 0;
    int occupiedRooms = (Integer) request.getAttribute("occupiedRooms") != null ? (Integer) request.getAttribute("occupiedRooms") : 0;
%>
<!DOCTYPE html>
<html lang="<%= language %>">
<head>
    <meta charset="UTF-8">
    <title><%= language.equals("vi") ? "Bảng điều khiển Quản trị - Khách sạn Oceanic" : "Admin Dashboard - Oceanic Hotel" %></title>
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
                <li class="active"><a href="<%= request.getContextPath() %>/admin/dashboard"><%= language.equals("vi") ? "Tổng quan" : "Dashboard" %></a></li>
                <li><a href="<%= request.getContextPath() %>/admin/users"><%= language.equals("vi") ? "Quản lý người dùng" : "User Management" %></a></li>
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
                <h2><%= language.equals("vi") ? "Tổng quan" : "Overview" %></h2>
                <p><%= language.equals("vi") ? "Xin chào" : "Hello" %>, <%= ((com.mycompany.oceanichotel.models.User) session.getAttribute("user")).getUsername() %>!</p>
            </header>

            <!-- Thông tin tổng quan -->
            <div class="overview">
                <div class="card">
                    <h4><%= language.equals("vi") ? "Check-in hôm nay" : "Today's Check-in" %></h4>
                    <p><%= checkInToday %></p>
                </div>
                <div class="card">
                    <h4><%= language.equals("vi") ? "Check-out hôm nay" : "Today's Check-out" %></h4>
                    <p><%= checkOutToday %></p>
                </div>
                <div class="card">
                    <h4><%= language.equals("vi") ? "Tổng số khách trong khách sạn" : "Total In Hotel" %></h4>
                    <p><%= totalInHotel %></p>
                </div>
                <div class="card">
                    <h4><%= language.equals("vi") ? "Phòng trống" : "Available Rooms" %></h4>
                    <p><%= availableRooms %></p>
                </div>
                <div class="card">
                    <h4><%= language.equals("vi") ? "Phòng đã đặt" : "Occupied Rooms" %></h4>
                    <p><%= occupiedRooms %></p>
                </div>
            </div>
        </div>
    </div>
</body>
</html>