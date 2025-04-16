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
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
</head>
<body class="<%= theme.equals("dark") ? "dark-mode" : "" %>" data-theme="<%= theme %>">
    <div class="admin-container">
        <nav class="sidebar">
                <div class="sidebar-header">
                    <a style="color: white; margin-bottom: 20px; font-size: 24px; font-weight: 600; letter-spacing: 0.5px;" href="<%= request.getContextPath()%>/admin/dashboard">Oceanic Hotel
                    </a>
                </div>
            <ul>
                <li class="active"><a href="<%= request.getContextPath() %>/admin/dashboard"><%= language.equals("vi") ? "Tổng quan" : "Dashboard" %></a></li>
                <li><a href="<%= request.getContextPath() %>/admin/users"><%= language.equals("vi") ? "Quản lý người dùng" : "User Management" %></a></li>
                 <li><a href="<%= request.getContextPath() %>/admin/room-types" class="active"><%= language.equals("vi") ? "Quản lý loại phòng" : "Room Type Management" %></a></li>
                <li><a href="<%= request.getContextPath() %>/admin/rooms"><%= language.equals("vi") ? "Quản lý phòng" : "Room Management" %></a></li>
                <li><a href="<%= request.getContextPath() %>/admin/bookings"><%= language.equals("vi") ? "Quản lý đặt phòng" : "Booking Management" %></a></li>
                <li><a href="<%= request.getContextPath() %>/admin/transactions"><%= language.equals("vi") ? "Quản lý giao dịch" : "Transaction Management" %></a></li>
                <li><a href="<%= request.getContextPath() %>/admin/settings"><%= language.equals("vi") ? "Cấu hình hệ thống" : "System Settings" %></a></li>
                <li><a href="<%= request.getContextPath() %>/admin/reports"><%= language.equals("vi") ? "Báo cáo" : "Reports" %></a></li>
                <li><a href="<%= request.getContextPath() %>/logout"><%= language.equals("vi") ? "Đăng xuất" : "Logout" %></a></li>
            </ul>
        </nav>
        <div class="main-content">

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
            <div class="chart-container" style="margin-top: 20px; width: 500px">
                <canvas id="roomStatusChart" width="400" height="200"></canvas>
            </div>
                
        </div>
    </div>
    <script>
        const ctx = document.getElementById('roomStatusChart').getContext('2d');
        const roomStatusChart = new Chart(ctx, {
            type: 'pie',
            data: {
                labels: ['<%= language.equals("vi") ? "Phòng trống" : "Available Rooms" %>', '<%= language.equals("vi") ? "Phòng đã đặt" : "Occupied Rooms" %>'],
                datasets: [{
                    data: [<%= availableRooms %>, <%= occupiedRooms %>],
                    backgroundColor: ['#28a745', '#dc3545'],
                    borderColor: ['#fff', '#fff'],
                    borderWidth: 1
                }]
            },
            options: {
                responsive: true,
                plugins: {
                    legend: { position: 'top' },
                    title: { display: true, text: '<%= language.equals("vi") ? "Trạng thái phòng" : "Room Status" %>' }
                }
            }
        });

        function changeLanguage() {
            const language = document.getElementById('languageSelect').value;
            fetch('<%= request.getContextPath() %>/language', {
                method: 'POST',
                headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
                body: 'language=' + encodeURIComponent(language)
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