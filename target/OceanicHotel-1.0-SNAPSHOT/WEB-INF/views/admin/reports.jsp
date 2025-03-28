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
    <title><%= language.equals("vi") ? "Báo cáo - Khách sạn Oceanic" : "Reports - Oceanic Hotel" %></title>
    <link rel="icon" href="<%= request.getContextPath() %>/assets/images/logo.png" type="image/x-icon">
    <link rel="stylesheet" href="<%= request.getContextPath() %>/assets/css/main.css">
    <link rel="stylesheet" href="<%= request.getContextPath() %>/assets/css/sidebar.css">
    <link rel="stylesheet" href="<%= request.getContextPath() %>/assets/css/table.css">
    <style>
        .report-section { margin: 20px 0; }
        .report-section h3 { margin-bottom: 10px; }
        .dark-mode .report-section { color: #fff; }
    </style>
</head>
<body class="<%= theme.equals("dark") ? "dark-mode" : "" %>" data-theme="<%= theme %>">
    <div class="admin-container">
        <nav class="sidebar">
            <div class="sidebar-header"><h3>Oceanic Hotel</h3></div>
            <ul>
                <li><a href="<%= request.getContextPath() %>/admin/dashboard"><%= language.equals("vi") ? "Tổng quan" : "Dashboard" %></a></li>
                <li><a href="<%= request.getContextPath() %>/admin/users"><%= language.equals("vi") ? "Quản lý người dùng" : "User Management" %></a></li>
                <li><a href="<%= request.getContextPath() %>/admin/rooms"><%= language.equals("vi") ? "Quản lý phòng" : "Room Management" %></a></li>
                <li><a href="<%= request.getContextPath() %>/admin/bookings"><%= language.equals("vi") ? "Quản lý đặt phòng" : "Booking Management" %></a></li>
                <li><a href="<%= request.getContextPath() %>/admin/transactions"><%= language.equals("vi") ? "Quản lý giao dịch" : "Transaction Management" %></a></li>
                <li><a href="<%= request.getContextPath() %>/admin/settings"><%= language.equals("vi") ? "Cấu hình hệ thống" : "System Settings" %></a></li>
                <li class="active"><a href="<%= request.getContextPath() %>/admin/reports"><%= language.equals("vi") ? "Báo cáo" : "Reports" %></a></li>
                <li><a href="<%= request.getContextPath() %>/logout"><%= language.equals("vi") ? "Đăng xuất" : "Logout" %></a></li>
            </ul>
        </nav>
        <div class="main-content">
            <header>
                <div class="settings">
                    <select id="languageSelect" onchange="changeLanguage()">
                        <option value="en" <%= language.equals("en") ? "selected" : "" %>><%= language.equals("vi") ? "Tiếng Anh" : "English" %></option>
                        <option value="vi" <%= language.equals("vi") ? "selected" : "" %>><%= language.equals("vi") ? "Tiếng Việt" : "Vietnamese" %></option>
                    </select>
                    <select id="themeSelect" onchange="changeTheme()">
                        <option value="light" <%= theme.equals("light") ? "selected" : "" %>><%= language.equals("vi") ? "Chế độ sáng" : "Light Mode" %></option>
                        <option value="dark" <%= theme.equals("dark") ? "selected" : "" %>><%= language.equals("vi") ? "Chế độ tối" : "Dark Mode" %></option>
                    </select>
                </div>
                <h2><%= language.equals("vi") ? "Báo cáo" : "Reports" %></h2>
            </header>
            <div class="report-section">
                <h3><%= language.equals("vi") ? "Doanh thu" : "Revenue" %></h3>
                <p><%= language.equals("vi") ? "Tổng doanh thu theo ngày: " : "Daily Revenue: " %> <%= request.getAttribute("dailyRevenue") %></p>
                <p><%= language.equals("vi") ? "Tổng doanh thu theo tháng: " : "Monthly Revenue: " %> <%= request.getAttribute("monthlyRevenue") %></p>
            </div>
            <div class="report-section">
                <h3><%= language.equals("vi") ? "Tỷ lệ sử dụng phòng" : "Room Utilization" %></h3>
                <p><%= language.equals("vi") ? "Tổng số phòng: " : "Total Rooms: " %> <%= request.getAttribute("totalRooms") %></p>
                <p><%= language.equals("vi") ? "Phòng trống: " : "Available Rooms: " %> <%= request.getAttribute("availableRooms") %></p>
                <p><%= language.equals("vi") ? "Đặt phòng đã xác nhận: " : "Confirmed Bookings: " %> <%= request.getAttribute("confirmedBookings") %></p>
                <p><%= language.equals("vi") ? "Tỷ lệ sử dụng: " : "Utilization Rate: " %> <%= request.getAttribute("utilizationRate") %>%</p>
            </div>
        </div>
    </div>
    <script>
        function changeLanguage() {
            fetch('<%= request.getContextPath() %>/language', {
                method: 'POST',
                headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
                body: 'language=' + encodeURIComponent(document.getElementById('languageSelect').value)
            }).then(() => location.reload());
        }

        function changeTheme() {
            const theme = document.getElementById('themeSelect').value;
            fetch('<%= request.getContextPath() %>/theme', {
                method: 'POST',
                headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
                body: 'theme=' + encodeURIComponent(theme)
            }).then(() => {
                document.body.className = theme === 'dark' ? 'dark-mode' : '';
                document.body.setAttribute('data-theme', theme);
            });
        }
    </script>
</body>
</html>