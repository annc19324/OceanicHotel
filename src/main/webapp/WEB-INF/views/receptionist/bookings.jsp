<%--
    Copyright (c) 2025 annc19324
    All rights reserved.

    This code is the property of annc19324.
    Unauthorized copying or distribution is prohibited.
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List" %>
<%@ page import="com.mycompany.oceanichotel.models.Booking" %>
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
    int currentPage = request.getAttribute("currentPage") != null ? (Integer) request.getAttribute("currentPage") : 1;
    int totalPages = request.getAttribute("totalPages") != null ? (Integer) request.getAttribute("totalPages") : 1;
%>
<!DOCTYPE html>
<html lang="<%= language %>">
<head>
    <meta charset="UTF-8">
    <title><%= language.equals("vi") ? "Quản lý đặt phòng - Lễ tân" : "Booking Management - Receptionist" %></title>
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
            <li class="active"><a href="<%= request.getContextPath() %>/receptionist/bookings"><%= language.equals("vi") ? "Quản lý đặt phòng" : "Booking Management" %></a></li>
            <li><a href="<%= request.getContextPath() %>/receptionist/rooms"><%= language.equals("vi") ? "Kiểm tra phòng" : "Room Check" %></a></li>
            <li><a href="<%= request.getContextPath() %>/receptionist/transactions"><%= language.equals("vi") ? "Thanh toán" : "Payments" %></a></li>
            <li><a href="<%= request.getContextPath() %>/logout"><%= language.equals("vi") ? "Đăng xuất" : "Logout" %></a></li>
        </ul>
    </nav>
    <div class="main-content">
        <div class="table-header">
            <div class="add-booking">
                <button class="action-btn add-btn" onclick="window.location.href = '<%= request.getContextPath() %>/receptionist/bookings/add'">
                    <%= language.equals("vi") ? "Thêm đặt phòng tại chỗ" : "Add Onsite Booking" %>
                </button>
            </div>
            <div class="search">
                <form action="<%= request.getContextPath() %>/receptionist/bookings" method="GET">
                    <input type="text" name="search" 
                           placeholder="<%= language.equals("vi") ? "Tìm kiếm theo ID đặt phòng" : "Search by Booking ID" %>"
                           value="<%= request.getParameter("search") != null ? request.getParameter("search") : "" %>">
                    <button type="submit" style="display: none;"></button>
                </form>
            </div>
        </div>
        <table class="data-table">
            <thead>
            <tr>
                <th><%= language.equals("vi") ? "ID" : "ID" %></th>
                <th><%= language.equals("vi") ? "Khách hàng" : "Customer" %></th>
                <th><%= language.equals("vi") ? "Phòng" : "Room" %></th>
                <th><%= language.equals("vi") ? "Ngày nhận" : "Check-in" %></th>
                <th><%= language.equals("vi") ? "Ngày trả" : "Check-out" %></th>
                <th><%= language.equals("vi") ? "Tổng tiền" : "Total Price" %></th>
                <th><%= language.equals("vi") ? "Trạng thái" : "Status" %></th>
                <th><%= language.equals("vi") ? "Hành động" : "Actions" %></th>
            </tr>
            </thead>
            <tbody>
            <%
                List<Booking> bookings = (List<Booking>) request.getAttribute("bookings");
                if (bookings != null) {
                    for (Booking booking : bookings) {
            %>
            <tr>
                <td><%= booking.getBookingId() %></td>
                <td><%= booking.getUserFullName() %> (<%= booking.getUserEmail() %>)</td>
                <td><%= booking.getRoomNumber() %> - <%= booking.getRoomTypeName() %></td>
                <td><%= booking.getCheckInDate() %></td>
                <td><%= booking.getCheckOutDate() %></td>
                <td><fmt:formatNumber value="<%= booking.getTotalPrice() %>" type="number" minFractionDigits="0" maxFractionDigits="2"/> VND</td>
                <td><span class="status <%= booking.getStatus().toLowerCase() %>">
                    <%= language.equals("vi") 
                        ? (booking.getStatus().equals("Pending") ? "Đang chờ" 
                        : booking.getStatus().equals("Confirmed") ? "Đã xác nhận" : "Đã hủy")
                        : booking.getStatus() %>
                </span></td>
                <td>
                    <div class="dropdown">
                        <button class="dropdown-btn">⋮</button>
                        <div class="dropdown-content">
                            <% if (booking.getStatus().equals("Pending")) { %>
                                <a href="<%= request.getContextPath() %>/receptionist/bookings/update?bookingId=<%= booking.getBookingId() %>&status=Confirmed"
                                   onclick="return confirm('<%= language.equals("vi") ? "Bạn có chắc chắn muốn xác nhận đặt phòng #" + booking.getBookingId() + " không?" : "Are you sure you want to confirm booking #" + booking.getBookingId() + "?" %>');">
                                    <%= language.equals("vi") ? "Xác nhận" : "Confirm" %>
                                </a>
                                <a href="<%= request.getContextPath() %>/receptionist/bookings/update?bookingId=<%= booking.getBookingId() %>&status=Cancelled"
                                   onclick="return confirm('<%= language.equals("vi") ? "Bạn có chắc chắn muốn hủy đặt phòng #" + booking.getBookingId() + " không?" : "Are you sure you want to cancel booking #" + booking.getBookingId() + "?" %>');">
                                    <%= language.equals("vi") ? "Hủy" : "Cancel" %>
                                </a>
                            <% } else if (booking.getStatus().equals("Confirmed")) { %>
                                <a href="<%= request.getContextPath() %>/receptionist/bookings/checkin?bookingId=<%= booking.getBookingId() %>"
                                   onclick="return confirm('<%= language.equals("vi") ? "Xác nhận check-in cho đặt phòng #" + booking.getBookingId() + " không?" : "Confirm check-in for booking #" + booking.getBookingId() + "?" %>');">
                                    <%= language.equals("vi") ? "Check-in" : "Check-in" %>
                                </a>
                                <a href="<%= request.getContextPath() %>/receptionist/bookings/checkout?bookingId=<%= booking.getBookingId() %>"
                                   onclick="return confirm('<%= language.equals("vi") ? "Xác nhận check-out cho đặt phòng #" + booking.getBookingId() + " không?" : "Confirm check-out for booking #" + booking.getBookingId() + "?" %>');">
                                    <%= language.equals("vi") ? "Check-out" : "Check-out" %>
                                </a>
                                <a href="<%= request.getContextPath() %>/receptionist/bookings/update?bookingId=<%= booking.getBookingId() %>&status=Cancelled"
                                   onclick="return confirm('<%= language.equals("vi") ? "Bạn có chắc chắn muốn hủy đặt phòng #" + booking.getBookingId() + " không?" : "Are you sure you want to cancel booking #" + booking.getBookingId() + "?" %>');">
                                    <%= language.equals("vi") ? "Hủy" : "Cancel" %>
                                </a>
                            <% } %>
                        </div>
                    </div>
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
            <a href="<%= request.getContextPath() %>/receptionist/bookings?page=<%= currentPage - 1 %><%= request.getParameter("search") != null ? "&search=" + request.getParameter("search") : "" %>">
                <button class="page-btn">Previous</button>
            </a>
            <% } %>
            <% for (int i = 1; i <= totalPages; i++) { %>
            <a href="<%= request.getContextPath() %>/receptionist/bookings?page=<%= i %><%= request.getParameter("search") != null ? "&search=" + request.getParameter("search") : "" %>">
                <button class="page-btn <%= currentPage == i ? "active" : "" %>"><%= i %></button>
            </a>
            <% } %>
            <% if (currentPage < totalPages) { %>
            <a href="<%= request.getContextPath() %>/receptionist/bookings?page=<%= currentPage + 1 %><%= request.getParameter("search") != null ? "&search=" + request.getParameter("search") : "" %>">
                <button class="page-btn">Next</button>
            </a>
            <% } %>
        </div>
        <% } %>
    </div>
</div>
<script>
    document.addEventListener('DOMContentLoaded', function () {
        document.querySelectorAll('.dropdown-btn').forEach(btn => {
            btn.addEventListener('click', function (e) {
                e.preventDefault();
                e.stopPropagation();
                const dropdownContent = this.nextElementSibling;
                const isVisible = dropdownContent.style.display === 'block';
                document.querySelectorAll('.dropdown-content').forEach(content => content.style.display = 'none');
                dropdownContent.style.display = isVisible ? 'none' : 'block';
            });
        });
        document.addEventListener('click', function (e) {
            if (!e.target.closest('.dropdown')) {
                document.querySelectorAll('.dropdown-content').forEach(content => content.style.display = 'none');
            }
        });
    });
</script>
</body>
</html>