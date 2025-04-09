<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List" %>
<%@ page import="com.mycompany.oceanichotel.models.Room" %>
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
    String error = request.getParameter("error"); // Lấy thông báo lỗi từ URL
    String message = request.getParameter("message"); // Lấy thông báo thành công từ URL
%>
<!DOCTYPE html>
<html lang="<%= language%>">
    <head>
        <meta charset="UTF-8">
        <title><%= language.equals("vi") ? "Quản lý phòng - Khách sạn Oceanic" : "Room Management - Oceanic Hotel"%></title>
        <link rel="icon" href="<%= request.getContextPath()%>/assets/images/logo.png" type="image/x-icon">
        <link rel="stylesheet" href="<%= request.getContextPath()%>/assets/css/main.css">
        <link rel="stylesheet" href="<%= request.getContextPath()%>/assets/css/sidebar.css">
        <link rel="stylesheet" href="<%= request.getContextPath()%>/assets/css/table.css">
        <link rel="stylesheet" href="<%= request.getContextPath()%>/assets/css/modal.css">
    </head>
    <body class="<%= theme.equals("dark") ? "dark-mode" : ""%>" data-theme="<%= theme%>">
        <div class="admin-container">
            <nav class="sidebar">
                <div class="sidebar-header"><a style="color: white; margin-bottom: 20px; font-size: 24px; font-weight: 600; letter-spacing: 0.5px;" href="<%= request.getContextPath()%>/admin/dashboard">Oceanic Hotel</a></div>
                <ul>
                    <li><a href="<%= request.getContextPath()%>/admin/dashboard"><%= language.equals("vi") ? "Tổng quan" : "Dashboard"%></a></li>
                    <li><a href="<%= request.getContextPath()%>/admin/users"><%= language.equals("vi") ? "Quản lý người dùng" : "User Management"%></a></li>
                    <li><a href="<%= request.getContextPath()%>/admin/room-types"><%= language.equals("vi") ? "Quản lý loại phòng" : "Room Type Management"%></a></li>
                    <li class="active"><a href="<%= request.getContextPath()%>/admin/rooms" class="active"><%= language.equals("vi") ? "Quản lý phòng" : "Room Management"%></a></li>
                    <li><a href="<%= request.getContextPath()%>/admin/bookings"><%= language.equals("vi") ? "Quản lý đặt phòng" : "Booking Management"%></a></li>
                    <li><a href="<%= request.getContextPath()%>/admin/transactions"><%= language.equals("vi") ? "Quản lý giao dịch" : "Transaction Management"%></a></li>
                    <li><a href="<%= request.getContextPath()%>/admin/settings"><%= language.equals("vi") ? "Cấu hình hệ thống" : "System Settings"%></a></li>
                    <li><a href="<%= request.getContextPath()%>/admin/reports"><%= language.equals("vi") ? "Báo cáo" : "Reports"%></a></li>
                    <li><a href="<%= request.getContextPath()%>/logout"><%= language.equals("vi") ? "Đăng xuất" : "Logout"%></a></li>
                </ul>
            </nav>
            <div class="main-content">
                <!-- Hiển thị thông báo lỗi -->
                <% if (error != null) { %>
                    <div class="custom-modal" id="errorModal" style="display: flex;">
                        <div class="modal-content animate-modal">
                            <h3><%= language.equals("vi") ? "Lỗi" : "Error" %></h3>
                            <p><%= error %></p>
                            <div class="modal-buttons">
                                <button class="modal-btn cancel-btn" onclick="document.getElementById('errorModal').style.display = 'none'">
                                    <%= language.equals("vi") ? "Đóng" : "Close" %>
                                </button>
                            </div>
                        </div>
                    </div>
                <% } %>

                <!-- Hiển thị thông báo thành công -->
                <% if (message != null) { %>
                    <div class="custom-modal" id="successModal" style="display: flex;">
                        <div class="modal-content animate-modal">
                            <h3><%= language.equals("vi") ? "Thành công" : "Success" %></h3>
                            <p><%= message.equals("delete_success") ? (language.equals("vi") ? "Xóa phòng thành công!" : "Room deleted successfully!") :
                                   message.equals("add_success") ? (language.equals("vi") ? "Thêm phòng thành công!" : "Room added successfully!") :
                                   message.equals("update_success") ? (language.equals("vi") ? "Cập nhật phòng thành công!" : "Room updated successfully!") : "" %></p>
                            <div class="modal-buttons">
                                <button class="modal-btn cancel-btn" onclick="document.getElementById('successModal').style.display = 'none'">
                                    <%= language.equals("vi") ? "Đóng" : "Close" %>
                                </button>
                            </div>
                        </div>
                    </div>
                <% } %>

                <div class="table-header">
                    <div class="add-room">
                        <button class="action-btn add-btn" onclick="window.location.href = '<%= request.getContextPath()%>/admin/rooms/add'">
                            <%= language.equals("vi") ? "Thêm phòng" : "Add Room"%>
                        </button>
                    </div>
                    <div class="search">
                        <form action="<%= request.getContextPath()%>/admin/rooms" method="GET">
                            <input type="text" name="search" placeholder="<%= language.equals("vi") ? "Tìm kiếm theo số phòng" : "Search by room number"%>"
                                   value="<%= request.getParameter("search") != null ? request.getParameter("search") : ""%>">
                            <button type="submit" style="display: none;"></button>
                        </form>
                    </div>
                </div>
                <table class="data-table">
                    <thead>
                        <tr>
                            <th><%= language.equals("vi") ? "ID" : "ID"%></th>
                            <th><%= language.equals("vi") ? "Số phòng" : "Room Number"%></th>
                            <th><%= language.equals("vi") ? "Loại phòng" : "Room Type"%></th>
                            <th><%= language.equals("vi") ? "Giá mỗi đêm" : "Price/Night"%></th>
                            <th><%= language.equals("vi") ? "Số người lớn tối đa" : "Max Adults"%></th>
                            <th><%= language.equals("vi") ? "Số trẻ em tối đa" : "Max Children"%></th>
                            <th><%= language.equals("vi") ? "Trạng thái" : "Status"%></th>
                            <th> </th>
                        </tr>
                    </thead>
                    <tbody>
                        <%
                            List<Room> rooms = (List<Room>) request.getAttribute("rooms");
                            if (rooms != null) {
                                for (Room room : rooms) {
                        %>
                        <tr>
                            <td><%= room.getRoomId()%></td>
                            <td><%= room.getRoomNumber()%></td>
                            <td><%= room.getRoomType() != null ? room.getRoomType().getTypeName() : "N/A"%></td>
                            <%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
                            <td><fmt:formatNumber value="<%= room.getPricePerNight()%>" type="number" minFractionDigits="0" maxFractionDigits="2"/> VNĐ</td>
                            <td><%= room.getMaxAdults()%></td>
                            <td><%= room.getMaxChildren()%></td>
                            <td>
                                <span class="status <%= room.isAvailable() ? "clean" : "dirty"%>">
                                    <%= room.isAvailable() ? (language.equals("vi") ? "Trống" : "Available") : (language.equals("vi") ? "Đã đặt" : "Occupied")%>
                                </span>
                            </td>
                            <td>
                                <div class="dropdown">
                                    <button class="dropdown-btn">⋮</button>
                                    <div class="dropdown-content">
                                        <a href="<%= request.getContextPath()%>/admin/rooms/edit?roomId=<%= room.getRoomId()%>">
                                            <%= language.equals("vi") ? "Sửa thông tin" : "Edit Room"%>
                                        </a>
                                        <a href="javascript:void(0)" onclick="confirmDelete('<%= room.getRoomId()%>')">
                                            <%= language.equals("vi") ? "Xóa phòng" : "Delete Room"%>
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
                    <a href="<%= request.getContextPath()%>/admin/rooms?page=<%= currentPage - 1%><%= request.getParameter("search") != null ? "&search=" + request.getParameter("search") : ""%>">
                        <button class="page-btn">Previous</button>
                    </a>
                    <% } %>
                    <% for (int i = 1; i <= totalPages; i++) {%>
                    <a href="<%= request.getContextPath()%>/admin/rooms?page=<%= i%><%= request.getParameter("search") != null ? "&search=" + request.getParameter("search") : ""%>">
                        <button class="page-btn <%= currentPage == i ? "active" : ""%>"><%= i%></button>
                    </a>
                    <% } %>
                    <% if (currentPage < totalPages) {%>
                    <a href="<%= request.getContextPath()%>/admin/rooms?page=<%= currentPage + 1%><%= request.getParameter("search") != null ? "&search=" + request.getParameter("search") : ""%>">
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

            function confirmDelete(roomId) {
                const lang = '<%= language%>';
                const message = lang === 'vi' ? 
                    'Bạn có chắc chắn muốn xóa phòng này không? Nếu phòng đang được sử dụng hoặc có đặt phòng liên quan, hành động này sẽ không thành công.' : 
                    'Are you sure you want to delete this room? This action will fail if the room is occupied or has active bookings.';
                if (confirm(message)) {
                    const form = document.createElement('form');
                    form.method = 'POST';
                    form.action = '<%= request.getContextPath()%>/admin/rooms/delete';
                    const input = document.createElement('input');
                    input.type = 'hidden';
                    input.name = 'roomId';
                    input.value = roomId;
                    form.appendChild(input);
                    document.body.appendChild(form);
                    form.submit();
                }
            }
        </script>
    </body>
</html>