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
    List<Transaction> transactions = (List<Transaction>) request.getAttribute("transactions");
    int currentPage = request.getAttribute("currentPage") != null ? (Integer) request.getAttribute("currentPage") : 1;
    int totalPages = request.getAttribute("totalPages") != null ? (Integer) request.getAttribute("totalPages") : 1;
%>
<!DOCTYPE html>
<html lang="<%= language%>">
    <head>
        <meta charset="UTF-8">
        <title><%= language.equals("vi") ? "Thanh toán tại quầy - Lễ tân" : "Onsite Transactions - Receptionist"%></title>
        <link rel="icon" href="<%= request.getContextPath()%>/assets/images/logo.png" type="image/x-icon">
        <link rel="stylesheet" href="<%= request.getContextPath()%>/assets/css/main.css">
        <link rel="stylesheet" href="<%= request.getContextPath()%>/assets/css/sidebar.css">
        <link rel="stylesheet" href="<%= request.getContextPath()%>/assets/css/table.css">
        <link rel="stylesheet" href="<%= request.getContextPath()%>/assets/css/modal.css">
    </head>
    <body class="<%= theme.equals("dark") ? "dark-mode" : ""%>" data-theme="<%= theme%>">
        <div class="admin-container">
            <nav class="sidebar">
                <div class="sidebar-header">
                    <a style="color: white; margin-bottom: 20px; font-size: 24px; font-weight: 600; letter-spacing: 0.5px;" 
                       href="<%= request.getContextPath()%>/receptionist/dashboard">Oceanic Hotel</a>
                </div>
                <ul>
                    <li><a href="<%= request.getContextPath()%>/receptionist/dashboard"><%= language.equals("vi") ? "Tổng quan" : "Dashboard"%></a></li>
                    <li><a href="<%= request.getContextPath()%>/receptionist/bookings"><%= language.equals("vi") ? "Quản lý đặt phòng" : "Booking Management"%></a></li>
                    <li><a href="<%= request.getContextPath()%>/receptionist/rooms"><%= language.equals("vi") ? "Kiểm tra phòng" : "Room Check"%></a></li>
                    <li class="active"><a href="<%= request.getContextPath()%>/receptionist/transactions"><%= language.equals("vi") ? "Thanh toán" : "Payments"%></a></li>
                    <li><a href="<%= request.getContextPath()%>/logout"><%= language.equals("vi") ? "Đăng xuất" : "Logout"%></a></li>
                </ul>
            </nav>
            <div class="main-content">
                <div class="table-header">
                    <div class="search">
                        <form action="<%= request.getContextPath()%>/receptionist/transactions" method="GET">
                            <input type="text" name="search" 
                                   placeholder="<%= language.equals("vi") ? "Tìm kiếm theo ID giao dịch" : "Search by Transaction ID"%>"
                                   value="<%= request.getParameter("search") != null ? request.getParameter("search") : ""%>">
                            <button type="submit" style="display: none;"></button>
                        </form>
                    </div>
                </div>
                <table class="data-table">
                    <thead>
                        <tr>
                            <th><%= language.equals("vi") ? "ID" : "ID"%></th>
                            <th><%= language.equals("vi") ? "Đặt phòng" : "Booking"%></th>
                            <th><%= language.equals("vi") ? "Khách hàng" : "Customer"%></th>
                            <th><%= language.equals("vi") ? "Phòng" : "Room"%></th>
                            <th><%= language.equals("vi") ? "Số tiền" : "Amount"%></th>
                            <th><%= language.equals("vi") ? "Trạng thái" : "Status"%></th>
                            <th><%= language.equals("vi") ? "Phương thức" : "Method"%></th>
                            <th><%= language.equals("vi") ? "Ngày tạo" : "Created At"%></th>
                            <th><%= language.equals("vi") ? "Hành động" : "Actions"%></th>
                        </tr>
                    </thead>
                    <tbody>
                        <%
                            if (transactions != null) {
                                for (Transaction transaction : transactions) {
                        %>
                        <tr>
                            <td><%= transaction.getTransactionId()%></td>
                            <td><%= transaction.getBookingId()%></td>
                            <td><%= transaction.getUserFullName()%> (<%= transaction.getUserEmail()%>)</td>
                            <td><%= transaction.getRoomNumber()%> - <%= transaction.getRoomTypeName()%></td>
                            <td><fmt:formatNumber value="<%= transaction.getAmount()%>" type="number" minFractionDigits="0" maxFractionDigits="2"/> VND</td>
                            <td><span class="status <%= transaction.getStatus().toLowerCase()%>">
                                    <%= language.equals("vi")
                                            ? (transaction.getStatus().equals("Pending") ? "Đang chờ"
                                            : transaction.getStatus().equals("Success") ? "Thành công"
                                            : transaction.getStatus().equals("Failed") ? "Thất bại" : "Đã hoàn tiền")
                    : transaction.getStatus()%>
                                </span></td>
                            <td><%= language.equals("vi")
                                    ? (transaction.getPaymentMethod().equals("Cash") ? "Tiền mặt"
                                    : transaction.getPaymentMethod().equals("Card") ? "Thẻ" : "Trực tuyến")
                : transaction.getPaymentMethod()%></td>
                            <td><%= transaction.getCreatedAt()%></td>
                            <td>
                                <div class="dropdown">
                                    <button class="dropdown-btn">⋮</button>
                                    <div class="dropdown-content">
                                        <% if (transaction.getStatus().equals("Pending")) {%>
                                        <a href="<%= request.getContextPath()%>/receptionist/transactions/update?transactionId=<%= transaction.getTransactionId()%>&status=Success"
                                           onclick="return confirm('<%= language.equals("vi") ? "Bạn có chắc chắn muốn xác nhận giao dịch #" + transaction.getTransactionId() + " thành công không?" : "Are you sure you want to confirm transaction #" + transaction.getTransactionId() + " as successful?"%>');">
                                            <%= language.equals("vi") ? "Xác nhận thành công" : "Confirm Success"%>
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
                    <% if (currentPage > 1) {%>
                    <a href="<%= request.getContextPath()%>/receptionist/transactions?page=<%= currentPage - 1%><%= request.getParameter("search") != null ? "&search=" + request.getParameter("search") : ""%>">
                        <button class="page-btn">Previous</button>
                    </a>
                    <% } %>
                    <% for (int i = 1; i <= totalPages; i++) {%>
                    <a href="<%= request.getContextPath()%>/receptionist/transactions?page=<%= i%><%= request.getParameter("search") != null ? "&search=" + request.getParameter("search") : ""%>">
                        <button class="page-btn <%= currentPage == i ? "active" : ""%>"><%= i%></button>
                    </a>
                    <% } %>
                    <% if (currentPage < totalPages) {%>
                    <a href="<%= request.getContextPath()%>/receptionist/transactions?page=<%= currentPage + 1%><%= request.getParameter("search") != null ? "&search=" + request.getParameter("search") : ""%>">
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
        </script>
    </body>
</html>