<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List" %>
<%@ page import="com.mycompany.oceanichotel.models.Transaction" %>
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
        <title><%= language.equals("vi") ? "Quản lý giao dịch - Khách sạn Oceanic" : "Transaction Management - Oceanic Hotel"%></title>
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
                    <a style="color: white; margin-bottom: 20px; font-size: 24px; font-weight: 600; letter-spacing: 0.5px;" href="<%= request.getContextPath()%>/admin/dashboard">Oceanic Hotel
                    </a>
                </div>
                <ul>
                    <li><a href="<%= request.getContextPath()%>/admin/dashboard"><%= language.equals("vi") ? "Tổng quan" : "Dashboard"%></a></li>
                    <li><a href="<%= request.getContextPath()%>/admin/users"><%= language.equals("vi") ? "Quản lý người dùng" : "User Management"%></a></li>
                    <li><a href="<%= request.getContextPath()%>/admin/room-types"><%= language.equals("vi") ? "Quản lý loại phòng" : "Room Type Management"%></a></li>

                    <li><a href="<%= request.getContextPath()%>/admin/rooms"><%= language.equals("vi") ? "Quản lý phòng" : "Room Management"%></a></li>
                    <li><a href="<%= request.getContextPath()%>/admin/bookings"><%= language.equals("vi") ? "Quản lý đặt phòng" : "Booking Management"%></a></li>
                    <li class="active"><a href="<%= request.getContextPath()%>/admin/transactions"><%= language.equals("vi") ? "Quản lý giao dịch" : "Transaction Management"%></a></li>
                    <li><a href="<%= request.getContextPath()%>/admin/settings"><%= language.equals("vi") ? "Cấu hình hệ thống" : "System Settings"%></a></li>
                    <li><a href="<%= request.getContextPath()%>/admin/reports"><%= language.equals("vi") ? "Báo cáo" : "Reports"%></a></li>
                    <li><a href="<%= request.getContextPath()%>/logout"><%= language.equals("vi") ? "Đăng xuất" : "Logout"%></a></li>
                </ul>
            </nav>
            <div class="main-content">

                <div class="stats">
                    <div><%= language.equals("vi") ? "Tổng doanh thu: " : "Total Revenue: "%><%= request.getAttribute("totalRevenue")%></div>
                    <div><%= language.equals("vi") ? "Thành công: " : "Successful: "%><%= request.getAttribute("successfulTransactions")%></div>
                    <div><%= language.equals("vi") ? "Thất bại: " : "Failed: "%><%= request.getAttribute("failedTransactions")%></div>
                </div>
                <div class="table-header">
                    <div class="search">
                        <form action="<%= request.getContextPath()%>/admin/transactions" method="GET">
                            <input type="text" name="search" placeholder="<%= language.equals("vi") ? "Tìm kiếm theo ID giao dịch" : "Search by Transaction ID"%>"
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
                            <th><%= language.equals("vi") ? "Số tiền" : "Amount"%></th>
                            <th><%= language.equals("vi") ? "Trạng thái" : "Status"%></th>
                            <th><%= language.equals("vi") ? "Ngày tạo" : "Created At"%></th>
                        </tr>
                    </thead>
                    <tbody>
                        <%
                            List<Transaction> transactions = (List<Transaction>) request.getAttribute("transactions");
                            if (transactions != null) {
                                for (Transaction transaction : transactions) {
                        %>
                        <tr>
                            <td><%= transaction.getTransactionId()%></td>
                            <td><%= transaction.getBookingId()%></td>
                            <td><%= transaction.getAmount()%> VNĐ</td>
                            <td><%= language.equals("vi") ? (transaction.getStatus().equals("Success") ? "Thành công" : "Thất bại") : transaction.getStatus()%></td>
                            <td><%= transaction.getCreatedAt()%></td>
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
                    <a href="<%= request.getContextPath()%>/admin/transactions?page=<%= currentPage - 1%><%= request.getParameter("search") != null ? "&search=" + request.getParameter("search") : ""%>">
                        <button class="page-btn">Previous</button>
                    </a>
                    <% } %>
                    <% for (int i = 1; i <= totalPages; i++) {%>
                    <a href="<%= request.getContextPath()%>/admin/transactions?page=<%= i%><%= request.getParameter("search") != null ? "&search=" + request.getParameter("search") : ""%>">
                        <button class="page-btn <%= currentPage == i ? "active" : ""%>"><%= i%></button>
                    </a>
                    <% } %>
                    <% if (currentPage < totalPages) {%>
                    <a href="<%= request.getContextPath()%>/admin/transactions?page=<%= currentPage + 1%><%= request.getParameter("search") != null ? "&search=" + request.getParameter("search") : ""%>">
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