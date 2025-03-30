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
        <title><%= language.equals("vi") ? "Báo cáo - Khách sạn Oceanic" : "Reports - Oceanic Hotel"%></title>
        <link rel="icon" href="<%= request.getContextPath()%>/assets/images/logo.png" type="image/x-icon">
        <link rel="stylesheet" href="<%= request.getContextPath()%>/assets/css/main.css">
        <link rel="stylesheet" href="<%= request.getContextPath()%>/assets/css/sidebar.css">
        <link rel="stylesheet" href="<%= request.getContextPath()%>/assets/css/table.css">
        <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>

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
                    <li><a href="<%= request.getContextPath()%>/admin/settings"><%= language.equals("vi") ? "Cấu hình hệ thống" : "System Settings"%></a></li>
                    <li class="active"><a href="<%= request.getContextPath()%>/admin/reports"><%= language.equals("vi") ? "Báo cáo" : "Reports"%></a></li>
                    <li><a href="<%= request.getContextPath()%>/logout"><%= language.equals("vi") ? "Đăng xuất" : "Logout"%></a></li>
                </ul>
            </nav>
            <div class="main-content">
                <div class="filter-section">
                    <form action="<%= request.getContextPath()%>/admin/reports" method="GET">
                        <label><%= language.equals("vi") ? "Loại báo cáo:" : "Report Type:"%></label>
                        <select name="reportType" onchange="this.form.submit()">
                            <option value="daily" <%= "daily".equals(request.getParameter("reportType")) ? "selected" : ""%>><%= language.equals("vi") ? "Hàng ngày" : "Daily"%></option>
                            <option value="monthly" <%= "monthly".equals(request.getParameter("reportType")) ? "selected" : ""%>><%= language.equals("vi") ? "Hàng tháng" : "Monthly"%></option>
                            <option value="yearly" <%= "yearly".equals(request.getParameter("reportType")) ? "selected" : ""%>><%= language.equals("vi") ? "Hàng năm" : "Yearly"%></option>
                        </select>
                        <label><%= language.equals("vi") ? "Ngày bắt đầu:" : "Start Date:"%></label>
                        <input type="date" name="startDate" value="<%= request.getParameter("startDate") != null ? request.getParameter("startDate") : ""%>">
                        <label><%= language.equals("vi") ? "Ngày kết thúc:" : "End Date:"%></label>
                        <input type="date" name="endDate" value="<%= request.getParameter("endDate") != null ? request.getParameter("endDate") : ""%>">
                        <button type="submit"><%= language.equals("vi") ? "Lọc" : "Filter"%></button>
                    </form>
                </div>
                <div class="report-section">
                    <h3><%= language.equals("vi") ? "Doanh thu" : "Revenue"%></h3>
                    <p><%= language.equals("vi") ? "Tổng doanh thu: " : "Total Revenue: "%> <%= request.getAttribute("totalRevenue")%> VNĐ</p>
                    <div class="chart-container">
                        <canvas id="revenueChart"></canvas>
                    </div>
                </div>
                <div class="report-section">
                    <h3><%= language.equals("vi") ? "Tỷ lệ sử dụng phòng" : "Room Utilization"%></h3>
                    <p><%= language.equals("vi") ? "Tổng số phòng: " : "Total Rooms: "%> <%= request.getAttribute("totalRooms")%></p>
                    <p><%= language.equals("vi") ? "Phòng trống: " : "Available Rooms: "%> <%= request.getAttribute("availableRooms")%></p>
                    <p><%= language.equals("vi") ? "Đặt phòng đã xác nhận: " : "Confirmed Bookings: "%> <%= request.getAttribute("confirmedBookings")%></p>
                    <p><%= language.equals("vi") ? "Tỷ lệ sử dụng: " : "Utilization Rate: "%> <%= request.getAttribute("utilizationRate")%>%</p>
                    <div class="chart-container">
                        <canvas id="utilizationChart"></canvas>
                    </div>
                </div>
            </div>
        </div>
        <script>
            const revenueCtx = document.getElementById('revenueChart').getContext('2d');
            const revenueChart = new Chart(revenueCtx, {
                type: 'bar',
                data: {
                    labels: ['<%= language.equals("vi") ? "Doanh thu" : "Revenue"%>'],
                    datasets: [{
                            label: '<%= language.equals("vi") ? "Tổng doanh thu" : "Total Revenue"%>',
                            data: [<%= request.getAttribute("totalRevenue")%>],
                            backgroundColor: '#007bff',
                            borderColor: '#0056b3',
                            borderWidth: 1
                        }]
                },
                options: {
                    responsive: true,
                    maintainAspectRatio: false,
                    scales: {y: {beginAtZero: true}},
                    plugins: {legend: {display: false}}
                }
            });

            const utilizationCtx = document.getElementById('utilizationChart').getContext('2d');
            const utilizationChart = new Chart(utilizationCtx, {
                type: 'pie',
                data: {
                    labels: ['<%= language.equals("vi") ? "Phòng đã sử dụng" : "Occupied"%>', '<%= language.equals("vi") ? "Phòng trống" : "Available"%>'],
                    datasets: [{
                            data: [<%= (Integer) request.getAttribute("totalRooms") - (Integer) request.getAttribute("availableRooms")%>, <%= request.getAttribute("availableRooms")%>],
                            backgroundColor: ['#dc3545', '#28a745'],
                            borderColor: ['#fff', '#fff'],
                            borderWidth: 1
                        }]
                },
                options: {
                    responsive: true,
                    maintainAspectRatio: false,
                    plugins: {legend: {position: 'top'}}
                }
            });

            function changeLanguage() {
                const language = document.getElementById('languageSelect').value;
                fetch('<%= request.getContextPath()%>/language', {
                    method: 'POST',
                    headers: {'Content-Type': 'application/x-www-form-urlencoded'},
                    body: 'language=' + encodeURIComponent(language)
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