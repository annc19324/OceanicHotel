<%--
    Copyright (c) 2025 annc19324
    All rights reserved.

    This code is the property of annc19324.
    Unauthorized copying or distribution is prohibited.
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List" %>
<%@ page import="com.mycompany.oceanichotel.models.Transaction" %>
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
    <title><%= language.equals("vi") ? "Quản lý giao dịch - Khách sạn Oceanic" : "Transaction Management - Oceanic Hotel" %></title>
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
               href="<%= request.getContextPath() %>/admin/dashboard">Oceanic Hotel</a>
        </div>
        <ul>
            <li><a href="<%= request.getContextPath() %>/admin/dashboard"><%= language.equals("vi") ? "Tổng quan" : "Dashboard" %></a></li>
            <li><a href="<%= request.getContextPath() %>/admin/users"><%= language.equals("vi") ? "Quản lý người dùng" : "User Management" %></a></li>
            <li><a href="<%= request.getContextPath() %>/admin/room-types"><%= language.equals("vi") ? "Quản lý loại phòng" : "Room Type Management" %></a></li>
            <li><a href="<%= request.getContextPath() %>/admin/rooms"><%= language.equals("vi") ? "Quản lý phòng" : "Room Management" %></a></li>
            <li><a href="<%= request.getContextPath() %>/admin/bookings"><%= language.equals("vi") ? "Quản lý đặt phòng" : "Booking Management" %></a></li>
            <li class="active"><a href="<%= request.getContextPath() %>/admin/transactions"><%= language.equals("vi") ? "Quản lý giao dịch" : "Transaction Management" %></a></li>
            <li><a href="<%= request.getContextPath() %>/admin/settings"><%= language.equals("vi") ? "Cấu hình hệ thống" : "System Settings" %></a></li>
            <li><a href="<%= request.getContextPath() %>/admin/reports"><%= language.equals("vi") ? "Báo cáo" : "Reports" %></a></li>
            <li><a href="<%= request.getContextPath() %>/logout"><%= language.equals("vi") ? "Đăng xuất" : "Logout" %></a></li>
        </ul>
    </nav>
    <div class="main-content">
        <% 
            String error = request.getParameter("error");
            if (error != null) { 
        %>
            <div class="custom-modal" id="errorModal" style="display: flex;">
                <div class="modal-content animate-modal">
                    <h3><%= language.equals("vi") ? "Lỗi" : "Error" %></h3>
                    <p>
                        <%= error.equals("refund_time_restriction") ? 
                            (language.equals("vi") ? "Không thể hoàn tiền sau 24 giờ kể từ khi giao dịch được tạo." : "Cannot refund after 24 hours from the transaction creation time.") 
                            : error %>
                    </p>
                    <div class="modal-buttons">
                        <button class="modal-btn cancel-btn" onclick="document.getElementById('errorModal').style.display = 'none'">
                            <%= language.equals("vi") ? "Đóng" : "Close" %>
                        </button>
                    </div>
                </div>
            </div>
        <% } %>
        <div class="stats">
            <div><%= language.equals("vi") ? "Tổng doanh thu: " : "Total Revenue: " %><fmt:formatNumber value="${totalRevenue}" type="number" minFractionDigits="0" maxFractionDigits="2"/> VNĐ</div>
            <div><%= language.equals("vi") ? "Thành công: " : "Successful: " %><%= request.getAttribute("successfulTransactions") %></div>
            <div><%= language.equals("vi") ? "Thất bại: " : "Failed: " %><%= request.getAttribute("failedTransactions") %></div>
        </div>
        <div class="table-header">
            <div class="search">
                <form action="<%= request.getContextPath() %>/admin/transactions" method="GET">
                    <input type="text" name="search" 
                           placeholder="<%= language.equals("vi") ? "Tìm kiếm theo ID giao dịch" : "Search by Transaction ID" %>"
                           value="<%= request.getParameter("search") != null ? request.getParameter("search") : "" %>">
                    <button type="submit" style="display: none;"></button>
                </form>
            </div>
        </div>
        <table class="data-table">
            <thead>
                <tr>
                    <th><%= language.equals("vi") ? "ID" : "ID" %></th>
                    <th><%= language.equals("vi") ? "Đặt phòng" : "Booking" %></th>
                    <th><%= language.equals("vi") ? "Khách hàng" : "Customer" %></th>
                    <th><%= language.equals("vi") ? "Phòng" : "Room" %></th>
                    <th><%= language.equals("vi") ? "Số tiền" : "Amount" %></th>
                    <th><%= language.equals("vi") ? "Trạng thái" : "Status" %></th>
                    <th><%= language.equals("vi") ? "Ngày tạo" : "Created At" %></th>
                    <th>...</th>
                </tr>
            </thead>
            <tbody>
                <%
                    List<Transaction> transactions = (List<Transaction>) request.getAttribute("transactions");
                    if (transactions != null) {
                        for (Transaction transaction : transactions) {
                %>
                <tr>
                    <td><%= transaction.getTransactionId() %></td>
                    <td><%= transaction.getBookingId() %></td>
                    <td><%= transaction.getUserFullName() %> (<%= transaction.getUserEmail() %>)</td>
                    <td><%= transaction.getRoomNumber() %> - <%= transaction.getRoomTypeName() %></td>
                    <td><fmt:formatNumber value="<%= transaction.getAmount() %>" type="number" minFractionDigits="0" maxFractionDigits="2"/> VNĐ</td>
                    <td><span class="status <%= transaction.getStatus().toLowerCase() %>">
                        <%= language.equals("vi") ? 
                            (transaction.getStatus().equals("Pending") ? "Đang chờ" : 
                             transaction.getStatus().equals("Success") ? "Thành công" : 
                             transaction.getStatus().equals("Failed") ? "Thất bại" : "Đã hoàn tiền") 
                            : transaction.getStatus() %>
                    </span></td>
                    <td><%= transaction.getCreatedAt() %></td>
                    <td>
                        <div class="dropdown">
                            <button class="dropdown-btn">⋮</button>
                            <div class="dropdown-content">
                                <% if (transaction.getStatus().equals("Pending")) { %>
                                    <a href="<%= request.getContextPath() %>/admin/transactions/update?transactionId=<%= transaction.getTransactionId() %>&status=Success"
                                       onclick="return confirm('<%= language.equals("vi") ? "Bạn có chắc chắn muốn xác nhận giao dịch #" + transaction.getTransactionId() + " thành công không?" : "Are you sure you want to confirm transaction #" + transaction.getTransactionId() + " as successful?" %>');">
                                        <%= language.equals("vi") ? "Xác nhận thành công" : "Confirm Success" %>
                                    </a>
                                <% } else if (transaction.getStatus().equals("Success")) { %>
                                    <a href="<%= request.getContextPath() %>/admin/transactions/update?transactionId=<%= transaction.getTransactionId() %>&status=Refunded"
                                       onclick="return confirm('<%= language.equals("vi") ? "Bạn có chắc chắn muốn hoàn tiền cho giao dịch #" + transaction.getTransactionId() + " không?" : "Are you sure you want to refund transaction #" + transaction.getTransactionId() + "?" %>');">
                                        <%= language.equals("vi") ? "Hoàn tiền" : "Refund" %>
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
            <a href="<%= request.getContextPath() %>/admin/transactions?page=<%= currentPage - 1 %><%= request.getParameter("search") != null ? "&search=" + request.getParameter("search") : "" %>">
                <button class="page-btn">Previous</button>
            </a>
            <% } %>
            <% for (int i = 1; i <= totalPages; i++) { %>
            <a href="<%= request.getContextPath() %>/admin/transactions?page=<%= i %><%= request.getParameter("search") != null ? "&search=" + request.getParameter("search") : "" %>">
                <button class="page-btn <%= currentPage == i ? "active" : "" %>"><%= i %></button>
            </a>
            <% } %>
            <% if (currentPage < totalPages) { %>
            <a href="<%= request.getContextPath() %>/admin/transactions?page=<%= currentPage + 1 %><%= request.getParameter("search") != null ? "&search=" + request.getParameter("search") : "" %>">
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

    function changeLanguage() {
        fetch('<%= request.getContextPath() %>/language', {
            method: 'POST',
            headers: {'Content-Type': 'application/x-www-form-urlencoded'},
            body: 'language=' + encodeURIComponent(document.getElementById('languageSelect').value)
        }).then(() => location.reload());
    }

    function changeTheme() {
        const theme = document.getElementById('themeSelect').value;
        fetch('<%= request.getContextPath() %>/theme', {
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