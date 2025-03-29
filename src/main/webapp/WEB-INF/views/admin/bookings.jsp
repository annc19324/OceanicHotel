<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List" %>
<%@ page import="com.mycompany.oceanichotel.models.Booking" %>
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
<html lang="<%= language%>">
    <head>
        <meta charset="UTF-8">
        <title><%= language.equals("vi") ? "Quản lý đặt phòng - Khách sạn Oceanic" : "Booking Management - Oceanic Hotel"%></title>
        <link rel="icon" href="<%= request.getContextPath()%>/assets/images/logo.png" type="image/x-icon">
        <link rel="stylesheet" href="<%= request.getContextPath()%>/assets/css/main.css">
        <link rel="stylesheet" href="<%= request.getContextPath()%>/assets/css/sidebar.css">
        <link rel="stylesheet" href="<%= request.getContextPath()%>/assets/css/table.css">
        <link rel="stylesheet" href="<%= request.getContextPath()%>/assets/css/modal.css">
        <style>
            .dropdown {
                position: relative;
                display: inline-block;
            }
            .dropdown-btn {
                background: none;
                border: none;
                font-size: 20px;
                cursor: pointer;
                padding: 0 10px;
                color: #333;
            }
            .dropdown-content {
                display: none;
                position: absolute;
                right: 0;
                background-color: #fff;
                min-width: 160px;
                box-shadow: 0 8px 16px rgba(0,0,0,0.2);
                z-index: 1;
                border-radius: 5px;
                border: 1px solid #ddd;
            }
            .dropdown-content a {
                color: #333;
                padding: 8px 16px;
                text-decoration: none;
                display: block;
                border-bottom: 1px solid #ddd;
            }
            .dropdown-content a:last-child {
                border-bottom: none;
            }
            .dropdown-content a:hover {
                background-color: #007bff;
                color: #fff;
            }
            .dark-mode .dropdown-btn {
                color: #fff;
            }
            .dark-mode .dropdown-content {
                background-color: #555;
                border-color: #666;
            }
            .dark-mode .dropdown-content a {
                color: #fff;
            }
            .dark-mode .dropdown-content a:hover {
                background-color: #0056b3;
            }
            .status.pending {
                background-color: #ffc107;
                color: #fff;
            }
            .status.confirmed {
                background-color: #28a745;
                color: #fff;
            }
            .status.cancelled {
                background-color: #dc3545;
                color: #fff;
            }
        </style>
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
                    <li class="active"><a href="<%= request.getContextPath()%>/admin/room-types"><%= language.equals("vi") ? "Quản lý loại phòng" : "Room Type Management"%></a></li>

                    <li><a href="<%= request.getContextPath()%>/admin/rooms"><%= language.equals("vi") ? "Quản lý phòng" : "Room Management"%></a></li>
                    <li class="active"><a href="<%= request.getContextPath()%>/admin/bookings"><%= language.equals("vi") ? "Quản lý đặt phòng" : "Booking Management"%></a></li>
                    <li><a href="<%= request.getContextPath()%>/admin/transactions"><%= language.equals("vi") ? "Quản lý giao dịch" : "Transaction Management"%></a></li>
                    <li><a href="<%= request.getContextPath()%>/admin/settings"><%= language.equals("vi") ? "Cấu hình hệ thống" : "System Settings"%></a></li>
                    <li><a href="<%= request.getContextPath()%>/admin/reports"><%= language.equals("vi") ? "Báo cáo" : "Reports"%></a></li>
                    <li><a href="<%= request.getContextPath()%>/logout"><%= language.equals("vi") ? "Đăng xuất" : "Logout"%></a></li>
                </ul>
            </nav>
            <div class="main-content">

                <div class="table-header">
                    <div class="search">
                        <form action="<%= request.getContextPath()%>/admin/bookings" method="GET">
                            <input type="text" name="search" placeholder="<%= language.equals("vi") ? "Tìm kiếm theo ID đặt phòng" : "Search by Booking ID"%>"
                                   value="<%= request.getParameter("search") != null ? request.getParameter("search") : ""%>">
                            <button type="submit" style="display: none;"></button>
                        </form>
                    </div>
                </div>
                <table class="data-table">
                    <thead>
                        <tr>
                            <th><%= language.equals("vi") ? "ID" : "ID"%></th>
                            <th><%= language.equals("vi") ? "Người dùng" : "User"%></th>
                            <th><%= language.equals("vi") ? "Phòng" : "Room"%></th>
                            <th><%= language.equals("vi") ? "Ngày nhận" : "Check-in"%></th>
                            <th><%= language.equals("vi") ? "Ngày trả" : "Check-out"%></th>
                            <th><%= language.equals("vi") ? "Tổng tiền" : "Total Price"%></th>
                            <th><%= language.equals("vi") ? "Trạng thái" : "Status"%></th>
                            <th>...</th>
                        </tr>
                    </thead>
                    <tbody>
                        <%
                            List<Booking> bookings = (List<Booking>) request.getAttribute("bookings");
                            if (bookings != null) {
                                for (Booking booking : bookings) {
                        %>
                        <tr>
                            <td><%= booking.getBookingId()%></td>
                            <td><%= booking.getUserId()%></td>
                            <td><%= booking.getRoomId()%></td>
                            <td><%= booking.getCheckInDate()%></td>
                            <td><%= booking.getCheckOutDate()%></td>
                            <td><%= booking.getTotalPrice()%></td>
                            <td><span class="status <%= booking.getStatus().toLowerCase()%>">
                                    <%= language.equals("vi")
                                            ? (booking.getStatus().equals("Pending") ? "Đang chờ"
                                            : booking.getStatus().equals("Confirmed") ? "Đã xác nhận" : "Đã hủy")
                                    : booking.getStatus()%>
                                </span></td>
                            <td>
                                <div class="dropdown">
                                    <button class="dropdown-btn">⋮</button>
                                    <div class="dropdown-content">
                                        <a href="javascript:void(0)" onclick="updateStatus('<%= booking.getBookingId()%>', 'Confirmed')">
                                            <%= language.equals("vi") ? "Xác nhận" : "Confirm"%>
                                        </a>
                                        <a href="javascript:void(0)" onclick="updateStatus('<%= booking.getBookingId()%>', 'Cancelled')">
                                            <%= language.equals("vi") ? "Hủy" : "Cancel"%>
                                        </a>
                                        <a href="<%= request.getContextPath()%>/admin/bookings/history?bookingId=<%= booking.getBookingId()%>">
                                            <%= language.equals("vi") ? "Xem lịch sử" : "View History"%>
                                        </a>
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
                    <% if (currentPage > 1) {%>
                    <a href="<%= request.getContextPath()%>/admin/bookings?page=<%= currentPage - 1%><%= request.getParameter("search") != null ? "&search=" + request.getParameter("search") : ""%>">
                        <button class="page-btn">Previous</button>
                    </a>
                    <% } %>
                    <% for (int i = 1; i <= totalPages; i++) {%>
                    <a href="<%= request.getContextPath()%>/admin/bookings?page=<%= i%><%= request.getParameter("search") != null ? "&search=" + request.getParameter("search") : ""%>">
                        <button class="page-btn <%= currentPage == i ? "active" : ""%>"><%= i%></button>
                    </a>
                    <% } %>
                    <% if (currentPage < totalPages) {%>
                    <a href="<%= request.getContextPath()%>/admin/bookings?page=<%= currentPage + 1%><%= request.getParameter("search") != null ? "&search=" + request.getParameter("search") : ""%>">
                        <button class="page-btn">Next</button>
                    </a>
                    <% } %>
                </div>
                <% }%>
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

            function updateStatus(bookingId, status) {
                const lang = '<%= language%>';
                const message = lang === 'vi' ? (status === 'Confirmed' ? 'Bạn có chắc chắn muốn xác nhận đặt phòng này không?' : 'Bạn có chắc chắn muốn hủy đặt phòng này không?')
                        : `Are you sure you want to ${status.toLowerCase()} this booking?`;
                if (confirm(message)) {
                    const form = document.createElement('form');
                    form.method = 'POST';
                    form.action = '<%= request.getContextPath()%>/admin/bookings/update';
                    form.innerHTML = `<input type="hidden" name="bookingId" value="${bookingId}">
                              <input type="hidden" name="status" value="${status}">`;
                    document.body.appendChild(form);
                    form.submit();
                }
            }

            function changeLanguage() {
                fetch('<%= request.getContextPath()%>/language', {
                    method: 'POST',
                    headers: {'Content-Type': 'application/x-www-form-urlencoded'},
                    body: 'language=' + encodeURIComponent(document.getElementById('languageSelect').value)
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