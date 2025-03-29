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
    List<LoginHistory> loginHistory = (List<LoginHistory>) request.getAttribute("loginHistory");
    int userId = request.getParameter("userId") != null ? Integer.parseInt(request.getParameter("userId")) : 0;
%>
<!DOCTYPE html>
<html lang="<%= language%>">
    <head>
        <meta charset="UTF-8">
        <title><%= language.equals("vi") ? "Lịch sử đăng nhập - Khách sạn Oceanic" : "Login History - Oceanic Hotel"%></title>
        <link rel="icon" href="<%= request.getContextPath()%>/assets/images/logo.png" type="image/x-icon">
        <link rel="stylesheet" href="<%= request.getContextPath()%>/assets/css/main.css">
        <link rel="stylesheet" href="<%= request.getContextPath()%>/assets/css/sidebar.css">
        <link rel="stylesheet" href="<%= request.getContextPath()%>/assets/css/table.css">
        <script>
            window.contextPath = '<%= request.getContextPath()%>';
        </script>
        <script src="<%= request.getContextPath()%>/assets/js/main.js" type="module" defer></script>
        <script src="<%= request.getContextPath()%>/assets/js/theme.js" type="module" defer></script>
        <script src="<%= request.getContextPath()%>/assets/js/language.js" type="module" defer></script>
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
                    <li class="active"><a href="<%= request.getContextPath()%>/admin/users"><%= language.equals("vi") ? "Quản lý người dùng" : "User Management"%></a></li>
                    <li class="active"><a href="<%= request.getContextPath()%>/admin/room-types"><%= language.equals("vi") ? "Quản lý loại phòng" : "Room Type Management"%></a></li>

                    <li><a href="<%= request.getContextPath()%>/admin/rooms"><%= language.equals("vi") ? "Quản lý phòng" : "Room Management"%></a></li>
                    <li><a href="<%= request.getContextPath()%>/admin/bookings"><%= language.equals("vi") ? "Quản lý đặt phòng" : "Booking Management"%></a></li>
                    <li><a href="<%= request.getContextPath()%>/admin/transactions"><%= language.equals("vi") ? "Quản lý giao dịch" : "Transaction Management"%></a></li>
                    <li><a href="<%= request.getContextPath()%>/admin/settings"><%= language.equals("vi") ? "Cấu hình hệ thống" : "System Settings"%></a></li>
                    <li><a href="<%= request.getContextPath()%>/admin/reports"><%= language.equals("vi") ? "Báo cáo" : "Reports"%></a></li>
                    <li><a href="<%= request.getContextPath()%>/logout"><%= language.equals("vi") ? "Đăng xuất" : "Logout"%></a></li>
                </ul>
            </nav>
            <div class="main-content">
                <div class="table-header">
                    <a href="<%= request.getContextPath()%>/admin/users" class="action-btn back-btn">
                        <%= language.equals("vi") ? "Quay lại" : "Back"%>
                    </a>
                </div>
                <table class="data-table">
                    <thead>
                        <tr>
                            <th><%= language.equals("vi") ? "ID" : "ID"%></th>
                            <th><%= language.equals("vi") ? "Thời gian đăng nhập" : "Login Time"%></th>
                            <th><%= language.equals("vi") ? "Địa chỉ IP" : "IP Address"%></th>
                        </tr>
                    </thead>
                    <tbody>
                        <%
                            if (loginHistory != null && !loginHistory.isEmpty()) {
                                for (LoginHistory history : loginHistory) {
                        %>
                        <tr>
                            <td><%= history.getLoginId()%></td>
                            <td><%= history.getLoginTime()%></td>
                            <td><%= history.getIpAddress() != null ? history.getIpAddress() : language.equals("vi") ? "Không có" : "N/A"%></td>
                        </tr>
                        <%
                            }
                        } else {
                        %>
                        <tr>
                            <td colspan="3"><%= language.equals("vi") ? "Không có dữ liệu lịch sử đăng nhập" : "No login history available"%></td>
                        </tr>
                        <% }%>
                    </tbody>
                </table>
            </div>
        </div>
    </body>
</html>