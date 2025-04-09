<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<% 
    com.mycompany.oceanichotel.models.User currentUser = (com.mycompany.oceanichotel.models.User) session.getAttribute("user");
    String language = currentUser != null && currentUser.getLanguage() != null ? currentUser.getLanguage() : (String) session.getAttribute("language");
    if (language == null) {
        language = "en";
        session.setAttribute("language", language);
    }
    String theme = currentUser != null && currentUser.getTheme() != null ? currentUser.getTheme() : (String) session.getAttribute("theme");
    if (theme == null) {
        theme = "light";
        session.setAttribute("theme", theme);
    }
    int pendingBookings = (Integer) request.getAttribute("pendingBookings") != null ? (Integer) request.getAttribute("pendingBookings") : 0;
    int confirmedBookings = (Integer) request.getAttribute("confirmedBookings") != null ? (Integer) request.getAttribute("confirmedBookings") : 0;
    int onlineBookings = (Integer) request.getAttribute("onlineBookings") != null ? (Integer) request.getAttribute("onlineBookings") : 0;
    int onsiteBookings = (Integer) request.getAttribute("onsiteBookings") != null ? (Integer) request.getAttribute("onsiteBookings") : 0;
    int availableRooms = (Integer) request.getAttribute("availableRooms") != null ? (Integer) request.getAttribute("availableRooms") : 0;
    int occupiedRooms = (Integer) request.getAttribute("occupiedRooms") != null ? (Integer) request.getAttribute("occupiedRooms") : 0;
    int todayBookings = (Integer) request.getAttribute("todayBookings") != null ? (Integer) request.getAttribute("todayBookings") : 0;
%>
<!DOCTYPE html>
<html lang="<%= language %>">
<head>
    <meta charset="UTF-8">
    <title><%= language.equals("vi") ? "Bảng điều khiển Lễ tân - Khách sạn Oceanic" : "Receptionist Dashboard - Oceanic Hotel" %></title>
    <link rel="icon" href="<%= request.getContextPath() %>/assets/images/logo.png" type="image/x-icon">
    <link rel="stylesheet" href="<%= request.getContextPath() %>/assets/css/main.css">
    <link rel="stylesheet" href="<%= request.getContextPath() %>/assets/css/dashboard.css">
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
</head>
<body class="<%= theme.equals("dark") ? "dark-mode" : "" %>" data-theme="<%= theme %>">
    <div class="admin-container">
        <nav class="sidebar">
            <div class="sidebar-header">
                <a style="color: white; margin-bottom: 20px; font-size: 24px; font-weight: 600; letter-spacing: 0.5px;" 
                   href="<%= request.getContextPath() %>/receptionist/dashboard">Oceanic Hotel</a>
            </div>
            <ul>
                <li class="active"><a href="<%= request.getContextPath() %>/receptionist/dashboard"><%= language.equals("vi") ? "Tổng quan" : "Dashboard" %></a></li>
                <li><a href="<%= request.getContextPath() %>/receptionist/bookings"><%= language.equals("vi") ? "Quản lý đặt phòng" : "Booking Management" %></a></li>
                <li><a href="<%= request.getContextPath() %>/receptionist/rooms"><%= language.equals("vi") ? "Kiểm tra phòng" : "Room Check" %></a></li>
                <li><a href="<%= request.getContextPath() %>/receptionist/transactions"><%= language.equals("vi") ? "Thanh toán" : "Payments" %></a></li>
                <li><a href="<%= request.getContextPath() %>/logout"><%= language.equals("vi") ? "Đăng xuất" : "Logout" %></a></li>
            </ul>
        </nav>
        <div class="main-content">
            <div class="overview">
                <div class="card">
                    <h4><%= language.equals("vi") ? "Đặt phòng hôm nay" : "Today's Bookings" %></h4>
                    <p><%= todayBookings %></p>
                </div>
                <div class="card">
                    <h4><%= language.equals("vi") ? "Đặt phòng chờ xử lý" : "Pending Bookings" %></h4>
                    <p><%= pendingBookings %></p>
                </div>
                <div class="card">
                    <h4><%= language.equals("vi") ? "Đặt phòng đã xác nhận" : "Confirmed Bookings" %></h4>
                    <p><%= confirmedBookings %></p>
                </div>
                <div class="card">
                    <h4><%= language.equals("vi") ? "Đặt phòng Online" : "Online Bookings" %></h4>
                    <p><%= onlineBookings %></p>
                </div>
                <div class="card">
                    <h4><%= language.equals("vi") ? "Đặt phòng tại chỗ" : "Onsite Bookings" %></h4>
                    <p><%= onsiteBookings %></p>
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

        function changeLanguage(lang) {
            fetch('<%= request.getContextPath() %>/language', {
                method: 'POST',
                headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
                body: 'language=' + encodeURIComponent(lang)
            }).then(() => location.reload());
        }

        function changeTheme(theme) {
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