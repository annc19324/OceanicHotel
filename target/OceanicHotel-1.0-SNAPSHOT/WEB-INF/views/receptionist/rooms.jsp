<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List" %>
<%@ page import="com.mycompany.oceanichotel.models.Room" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
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
    List<Room> rooms = (List<Room>) request.getAttribute("rooms");
    int currentPage = request.getAttribute("currentPage") != null ? (Integer) request.getAttribute("currentPage") : 1;
    int totalPages = request.getAttribute("totalPages") != null ? (Integer) request.getAttribute("totalPages") : 1;
%>
<!DOCTYPE html>
<html lang="<%= language %>">
<head>
    <meta charset="UTF-8">
    <title><%= language.equals("vi") ? "Kiểm tra phòng - Lễ tân" : "Room Check - Receptionist" %></title>
    <link rel="icon" href="<%= request.getContextPath() %>/assets/images/logo.png" type="image/x-icon">
    <link rel="stylesheet" href="<%= request.getContextPath() %>/assets/css/main.css">
    <link rel="stylesheet" href="<%= request.getContextPath() %>/assets/css/sidebar.css">
    <link rel="stylesheet" href="<%= request.getContextPath() %>/assets/css/table.css">
    <link rel="stylesheet" href="<%= request.getContextPath() %>/assets/css/modal.css">
</head>
<body class="<%= theme.equals("dark") ? "dark-mode" : "" %>" data-theme="<%= theme %>">
<div class="admin-container">
    <nav class="sidebar">
        <div class="sidebar-header">
            <a style="color: white; margin-bottom: 20px; font-size: 24px; font-weight: 600; letter-spacing: 0.5px;" 
               href="<%= request.getContextPath() %>/receptionist/dashboard">Oceanic Hotel</a>
        </div>
        <ul>
            <li><a href="<%= request.getContextPath() %>/receptionist/dashboard"><%= language.equals("vi") ? "Tổng quan" : "Dashboard" %></a></li>
            <li><a href="<%= request.getContextPath() %>/receptionist/bookings"><%= language.equals("vi") ? "Quản lý đặt phòng" : "Booking Management" %></a></li>
            <li class="active"><a href="<%= request.getContextPath() %>/receptionist/rooms"><%= language.equals("vi") ? "Kiểm tra phòng" : "Room Check" %></a></li>
            <li><a href="<%= request.getContextPath() %>/receptionist/transactions"><%= language.equals("vi") ? "Thanh toán" : "Payments" %></a></li>
            <li><a href="<%= request.getContextPath() %>/logout"><%= language.equals("vi") ? "Đăng xuất" : "Logout" %></a></li>
        </ul>
    </nav>
    <div class="main-content">
        <div class="table-header">
            <div class="search">
                <form action="<%= request.getContextPath() %>/receptionist/rooms" method="GET">
                    <input type="text" name="search" 
                           placeholder="<%= language.equals("vi") ? "Tìm kiếm theo số phòng" : "Search by Room Number" %>"
                           value="<%= request.getParameter("search") != null ? request.getParameter("search") : "" %>">
                    <button type="submit" style="display: none;"></button>
                </form>
            </div>
        </div>
        <table class="data-table">
            <thead>
                <tr>
                    <th><%= language.equals("vi") ? "Số phòng" : "Room Number" %></th>
                    <th><%= language.equals("vi") ? "Loại phòng" : "Room Type" %></th>
                    <th><%= language.equals("vi") ? "Giá mỗi đêm" : "Price per Night" %></th>
                    <th><%= language.equals("vi") ? "Trạng thái" : "Status" %></th>
                </tr>
            </thead>
            <tbody>
                <%
                    if (rooms != null) {
                        for (Room room : rooms) {
                %>
                <tr>
                    <td><%= room.getRoomNumber() %></td>
                    <td><%= room.getRoomType().getTypeName() %></td>
                    <td><fmt:formatNumber value="<%= room.getPricePerNight() %>" type="number" minFractionDigits="0" maxFractionDigits="2"/> VND</td>
                    <td>
                        <span class="status <%= room.isAvailable() ? "confirmed" : "cancelled" %>">
                            <%= language.equals("vi") ? (room.isAvailable() ? "Trống" : "Đã đặt") : (room.isAvailable() ? "Available" : "Occupied") %>
                        </span>
                    </td>
                </tr>
                <%
                        }
                    }
                %>
            </tbody>
        </table>
        <% if (totalPages > 1) { %>
        <div class="pagination">
            <% if (currentPage > 1) { %>
            <a href="<%= request.getContextPath() %>/receptionist/rooms?page=<%= currentPage - 1 %><%= request.getParameter("search") != null ? "&search=" + request.getParameter("search") : "" %>">
                <button class="page-btn">Previous</button>
            </a>
            <% } %>
            <% for (int i = 1; i <= totalPages; i++) { %>
            <a href="<%= request.getContextPath() %>/receptionist/rooms?page=<%= i %><%= request.getParameter("search") != null ? "&search=" + request.getParameter("search") : "" %>">
                <button class="page-btn <%= currentPage == i ? "active" : "" %>"><%= i %></button>
            </a>
            <% } %>
            <% if (currentPage < totalPages) { %>
            <a href="<%= request.getContextPath() %>/receptionist/rooms?page=<%= currentPage + 1 %><%= request.getParameter("search") != null ? "&search=" + request.getParameter("search") : "" %>">
                <button class="page-btn">Next</button>
            </a>
            <% } %>
        </div>
        <% } %>
    </div>
</div>
</body>
</html>