<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List" %>
<%@ page import="com.mycompany.oceanichotel.models.User" %>
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
        <title><%= language.equals("vi") ? "Quản lý người dùng - Khách sạn Oceanic" : "User Management - Oceanic Hotel"%></title>
        <link rel="icon" href="<%= request.getContextPath()%>/assets/images/logo.png" type="image/x-icon">
        <link rel="stylesheet" href="<%= request.getContextPath()%>/assets/css/main.css">
        <link rel="stylesheet" href="<%= request.getContextPath()%>/assets/css/sidebar.css">
        <link rel="stylesheet" href="<%= request.getContextPath()%>/assets/css/table.css">
        <link rel="stylesheet" href="<%= request.getContextPath()%>/assets/css/modal.css">
        <script>
            window.contextPath = '<%= request.getContextPath()%>';
            window.language = '<%= language%>';
        </script>
        <script src="<%= request.getContextPath()%>/assets/js/main.js" type="module" defer></script>
        <script src="<%= request.getContextPath()%>/assets/js/theme.js" type="module" defer></script>
        <script src="<%= request.getContextPath()%>/assets/js/language.js" type="module" defer></script>
        <script src="<%= request.getContextPath()%>/assets/js/modal.js" type="module" defer></script>
        <script src="<%= request.getContextPath()%>/assets/js/dropdown.js" type="module" defer></script>
        <script type="module">
            import { showConfirmModal, closeModal } from '<%= request.getContextPath()%>/assets/js/modal.js';
            // Gán vào window để dùng trong onclick
            window.showConfirmModal = showConfirmModal;
            window.closeModal = closeModal;
        </script>
    </head>
    <body class="<%= theme.equals("dark") ? "dark-mode" : ""%>" data-theme="<%= theme%>">
        <div class="admin-container">
            <nav class="sidebar">
                <div class="sidebar-header">
                    <h3>Oceanic Hotel</h3>
                </div>
                <ul>
                    <li><a href="<%= request.getContextPath()%>/admin/dashboard"><%= language.equals("vi") ? "Tổng quan" : "Dashboard"%></a></li>
                    <li class="active"><a href="<%= request.getContextPath()%>/admin/users"><%= language.equals("vi") ? "Quản lý người dùng" : "User Management"%></a></li>
                    <li><a href="<%= request.getContextPath()%>/admin/rooms"><%= language.equals("vi") ? "Quản lý phòng" : "Room Management"%></a></li>
                    <li><a href="<%= request.getContextPath()%>/admin/bookings"><%= language.equals("vi") ? "Quản lý đặt phòng" : "Booking Management"%></a></li>
                    <li><a href="<%= request.getContextPath()%>/admin/transactions"><%= language.equals("vi") ? "Quản lý giao dịch" : "Transaction Management"%></a></li>
                    <li><a href="<%= request.getContextPath()%>/admin/settings"><%= language.equals("vi") ? "Cấu hình hệ thống" : "System Settings"%></a></li>
                    <li><a href="<%= request.getContextPath()%>/admin/reports"><%= language.equals("vi") ? "Báo cáo" : "Reports"%></a></li>
                    <li><a href="<%= request.getContextPath()%>/logout"><%= language.equals("vi") ? "Đăng xuất" : "Logout"%></a></li>
                </ul>
            </nav>
            <div class="main-content">
                <% if (request.getParameter("message") != null || request.getParameter("error") != null) {%>
                <div class="custom-modal" id="notificationModal">
                    <div class="modal-content animate-modal">
                        <h3><%= language.equals("vi") ? "Thông báo" : "Notification"%></h3>
                        <p>
                            <%
                                if (request.getParameter("message") != null) {
                                    if (request.getParameter("message").equals("delete_success")) {
                                        out.print(language.equals("vi") ? "Xóa người dùng thành công!" : "User deleted successfully!");
                                    } else if (request.getParameter("message").equals("update_success")) {
                                        out.print(language.equals("vi") ? "Cập nhật người dùng thành công!" : "User updated successfully!");
                                    }
                                } else if (request.getParameter("error") != null) {
                                    if (request.getParameter("error").equals("user_not_found")) {
                                        out.print(language.equals("vi") ? "Không tìm thấy người dùng!" : "User not found!");
                                    } else {
                                        out.print(language.equals("vi") ? "ID người dùng không hợp lệ!" : "Invalid user ID!");
                                    }
                                }
                            %>
                        </p>
                        <div class="modal-buttons">
                            <button class="modal-btn confirm-btn" onclick="closeModal('notificationModal')">OK</button>
                        </div>
                    </div>
                </div>
                <% }%>
                <header>
                    <div class="settings">
                        <select id="languageSelect">
                            <option value="en" <%= language.equals("en") ? "selected" : ""%>><%= language.equals("vi") ? "Tiếng Anh" : "English"%></option>
                            <option value="vi" <%= language.equals("vi") ? "selected" : ""%>><%= language.equals("vi") ? "Tiếng Việt" : "Vietnamese"%></option>
                        </select>
                        <select id="themeSelect">
                            <option value="light" <%= theme.equals("light") ? "selected" : ""%>><%= language.equals("vi") ? "Chế độ sáng" : "Light Mode"%></option>
                            <option value="dark" <%= theme.equals("dark") ? "selected" : ""%>><%= language.equals("vi") ? "Chế độ tối" : "Dark Mode"%></option>
                        </select>
                    </div>
                    <h2><%= language.equals("vi") ? "Quản lý người dùng" : "User Management"%></h2>
                </header>
                <div class="table-header">
                    <div class="add-user">
                        <button class="action-btn add-btn" onclick="window.location.href = '<%= request.getContextPath()%>/admin/users/add'">
                            <%= language.equals("vi") ? "Thêm người dùng" : "Add User"%>
                        </button>
                    </div>
                    <div class="search">
                        <form action="<%= request.getContextPath()%>/admin/users" method="GET">
                            <input type="text" name="search" placeholder="<%= language.equals("vi") ? "Tìm kiếm theo tên người dùng hoặc email" : "Search by username or email"%>" value="<%= request.getParameter("search") != null ? request.getParameter("search") : ""%>">
                            <button type="submit" style="display: none;"></button>
                        </form>
                    </div>
                    <div class="filter">
                        <button class="filter-btn" onclick="document.querySelector('.search form').submit();">
                            <span><%= language.equals("vi") ? "Bộ lọc" : "Filter"%></span>
                            <i class="fas fa-filter"></i>
                        </button>
                    </div>
                </div>
                <table class="data-table">
                    <thead>
                        <tr>
                            <th><%= language.equals("vi") ? "ID" : "ID"%></th>
                            <th><%= language.equals("vi") ? "Tên người dùng" : "Username"%></th>
                            <th><%= language.equals("vi") ? "Email" : "Email"%></th>
                            <th><%= language.equals("vi") ? "Vai trò" : "Role"%></th>
                            <th><%= language.equals("vi") ? "Hoạt động" : "Active"%></th>
                            <th><%= language.equals("vi") ? "Ngày tạo" : "Created At"%></th>
                            <th>...</th>
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
                            <td><%= user.getEmail()%></td>
                            <td><%= user.getRole()%></td>
                            <td>
                                <span class="status <%= user.isActive() ? "clean" : "dirty"%>">
                                    <%= user.isActive() ? (language.equals("vi") ? "hoạt động" : "able") : (language.equals("vi") ? "Không hoạt động" : "disable")%>
                                </span>
                            </td>
                            <td><%= user.getCreatedAt()%></td>
                            <td>
                                <div class="dropdown">
                                    <button class="dropdown-btn">⋮</button>
                                    <div class="dropdown-content">
                                        <a href="#" onclick="event.preventDefault(); showConfirmModal('edit', '<%= user.getUserId()%>')">
                                            <%= language.equals("vi") ? "Sửa thông tin" : "Edit Profile"%>
                                        </a>
                                        <a href="#" onclick="event.preventDefault(); showConfirmModal('delete', '<%= user.getUserId()%>')">
                                            <%= language.equals("vi") ? "Xóa tài khoản" : "Delete Account"%>
                                        </a>
                                        <a href="<%= request.getContextPath()%>/admin/users/login-history?userId=<%= user.getUserId()%>">
                                            <%= language.equals("vi") ? "Xem lịch sử đăng nhập" : "View Login History"%>
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
                <div class="custom-modal" id="confirmModal" style="display: none;">
                    <div class="modal-content animate-modal">
                        <h3><%= language.equals("vi") ? "Xác nhận" : "Confirmation"%></h3>
                        <p id="confirmMessage"></p>
                        <div class="modal-buttons">
                            <button class="modal-btn confirm-btn" id="confirmYes"><%= language.equals("vi") ? "Có" : "Yes"%></button>
                            <button class="modal-btn cancel-btn" onclick="closeModal('confirmModal')"><%= language.equals("vi") ? "Không" : "No"%></button>
                        </div>
                    </div>
                </div>
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
    </body>
</html>