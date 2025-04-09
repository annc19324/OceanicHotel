<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List" %>
<%@ page import="com.mycompany.oceanichotel.models.User" %>
<%@ page import="java.text.SimpleDateFormat" %>
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
    SimpleDateFormat dateFormat = new SimpleDateFormat("dd/MM/yyyy");
%>
<!DOCTYPE html>
<html lang="<%= language%>">
<head>
    <meta charset="UTF-8">
    <title><%= language.equals("vi") ? "Quản lý người dùng - Khách sạn Oceanic" : "User Management - Oceanic Hotel"%></title>
    <link rel="icon" href="<%= request.getContextPath()%>/assets/images/logo.png" type="image/x-icon">
    <link rel="stylesheet" href="<%= request.getContextPath()%>/assets/css/main.css">
    <link rel="stylesheet" href="<%= request.getContextPath()%>/assets/css/sidebar.css">
    <link rel="stylesheet" href="<%= request.getContextPath()%>/assets/css/table.css">
    <link rel="stylesheet" href="<%= request.getContextPath()%>/assets/css/modal.css">
    <style>
        .data-table th, .data-table td {
            padding: 10px;
            text-align: left;
            white-space: nowrap;
        }
        .data-table {
            width: 100%;
            overflow-x: auto;
        }
        .avatar-img {
            width: 40px;
            height: 40px;
            border-radius: 50%;
            object-fit: cover;
        }
    </style>
</head>
<body class="<%= theme.equals("dark") ? "dark-mode" : ""%>" data-theme="<%= theme%>">
    <div class="admin-container">
        <nav class="sidebar">
            <div class="sidebar-header">
                <a style="color: white; margin-bottom: 20px; font-size: 24px; font-weight: 600; letter-spacing: 0.5px;" href="<%= request.getContextPath()%>/admin/dashboard">Oceanic Hotel</a>
            </div>
            <ul>
                <li><a href="<%= request.getContextPath()%>/admin/dashboard"><%= language.equals("vi") ? "Tổng quan" : "Dashboard"%></a></li>
                <li class="active"><a href="<%= request.getContextPath()%>/admin/users"><%= language.equals("vi") ? "Quản lý người dùng" : "User Management"%></a></li>
                <li><a href="<%= request.getContextPath()%>/admin/room-types"><%= language.equals("vi") ? "Quản lý loại phòng" : "Room Type Management"%></a></li>
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
                <div class="add-user">
                    <button class="action-btn add-btn" onclick="window.location.href = '<%= request.getContextPath()%>/admin/users/add'">
                        <%= language.equals("vi") ? "Thêm người dùng" : "Add User"%>
                    </button>
                </div>
                <div class="search">
                    <form action="<%= request.getContextPath()%>/admin/users" method="GET">
                        <input type="text" name="search" placeholder="<%= language.equals("vi") ? "Tìm kiếm theo tên người dùng" : "Search by username"%>"
                               value="<%= request.getParameter("search") != null ? request.getParameter("search") : ""%>">
                        <button type="submit" style="display: none;"></button>
                    </form>
                </div>
            </div>
            <table class="data-table">
                <thead>
                    <tr>
                        <th><%= language.equals("vi") ? "ID" : "ID"%></th>
                        <th><%= language.equals("vi") ? "Tên người dùng" : "Username"%></th>
                        <th><%= language.equals("vi") ? "Họ và tên" : "Full Name"%></th>
                        <th><%= language.equals("vi") ? "Email" : "Email"%></th>
                        <th><%= language.equals("vi") ? "CCCD" : "ID Card"%></th>
                        <th><%= language.equals("vi") ? "Số điện thoại" : "Phone Number"%></th>
                        <th><%= language.equals("vi") ? "Ngày sinh" : "Date of Birth"%></th>
                        <th><%= language.equals("vi") ? "Giới tính" : "Gender"%></th>
                        <th><%= language.equals("vi") ? "Vai trò" : "Role"%></th>
                        <th></th>
                    </tr>
                </thead>
                <tbody>
                    <%
                        List<User> users = (List<User>) request.getAttribute("users");
                        if (users != null) {
                            for (User user : users) {
                    %>
                    <tr>
                        <td><%= user.getUserId()%></td>
                        <td><%= user.getUsername()%></td>
                        <td><%= user.getFullName() != null ? user.getFullName() : ""%></td>
                        <td><%= user.getEmail()%></td>
                        <td><%= user.getCccd() != null ? user.getCccd() : ""%></td>
                        <td><%= user.getPhoneNumber() != null ? user.getPhoneNumber() : ""%></td>
                        <td><%= user.getDateOfBirth() != null ? dateFormat.format(user.getDateOfBirth()) : ""%></td>
                        <td><%= user.getGender() != null ? user.getGender() : "Other"%></td>
                        <td><%= user.getRole()%></td>
                        <td>
                            <div class="dropdown">
                                <button class="dropdown-btn">⋮</button>
                                <div class="dropdown-content">
                                    <a href="<%= request.getContextPath()%>/admin/users/edit?userId=<%= user.getUserId()%>">
                                        <%= language.equals("vi") ? "Sửa thông tin" : "Edit User"%>
                                    </a>
                                    <a href="javascript:void(0)" onclick="confirmDelete('<%= user.getUserId()%>')">
                                        <%= language.equals("vi") ? "Xóa người dùng" : "Delete User"%>
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
                <a href="<%= request.getContextPath()%>/admin/users?page=<%= currentPage - 1%><%= request.getParameter("search") != null ? "&search=" + request.getParameter("search") : ""%>">
                    <button class="page-btn">Previous</button>
                </a>
                <% } %>
                <% for (int i = 1; i <= totalPages; i++) {%>
                <a href="<%= request.getContextPath()%>/admin/users?page=<%= i%><%= request.getParameter("search") != null ? "&search=" + request.getParameter("search") : ""%>">
                    <button class="page-btn <%= currentPage == i ? "active" : ""%>"><%= i%></button>
                </a>
                <% } %>
                <% if (currentPage < totalPages) {%>
                <a href="<%= request.getContextPath()%>/admin/users?page=<%= currentPage + 1%><%= request.getParameter("search") != null ? "&search=" + request.getParameter("search") : ""%>">
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
                    document.querySelectorAll('.dropdown-content').forEach(content => {
                        content.style.display = 'none';
                    });
                    dropdownContent.style.display = isVisible ? 'none' : 'block';
                });
            });

            document.addEventListener('click', function (e) {
                if (!e.target.closest('.dropdown')) {
                    document.querySelectorAll('.dropdown-content').forEach(content => {
                        content.style.display = 'none';
                    });
                }
            });
        });

        function confirmDelete(userId) {
            const lang = '<%= language%>';
            const message = lang === 'vi' ? 'Bạn có chắc chắn muốn xóa người dùng này không?' : 'Are you sure you want to delete this user?';
            if (confirm(message)) {
                const form = document.createElement('form');
                form.method = 'POST';
                form.action = '<%= request.getContextPath()%>/admin/users/delete';
                const input = document.createElement('input');
                input.type = 'hidden';
                input.name = 'userId';
                input.value = userId;
                form.appendChild(input);
                document.body.appendChild(form);
                form.submit();
            }
        }

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