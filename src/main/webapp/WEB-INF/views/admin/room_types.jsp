<%--
    Copyright (c) 2025 annc19324
    All rights reserved.

    This code is the property of annc19324.
    Unauthorized copying or distribution is prohibited.
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List" %>
<%@ page import="com.mycompany.oceanichotel.models.RoomType" %>
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
    String error = request.getParameter("error"); // Lấy thông báo lỗi từ URL
    String message = request.getParameter("message"); // Lấy thông báo thành công từ URL
%>
<!DOCTYPE html>
<html lang="<%= language%>">
    <head>
        <meta charset="UTF-8">
        <title><%= language.equals("vi") ? "Quản lý loại phòng - Khách sạn Oceanic" : "Room Type Management - Oceanic Hotel"%></title>
        <link rel="icon" href="<%= request.getContextPath()%>/assets/images/logo.png" type="image/x-icon">
        <link rel="stylesheet" href="<%= request.getContextPath()%>/assets/css/main.css">
        <link rel="stylesheet" href="<%= request.getContextPath()%>/assets/css/table.css">
    </head>
    <body class="<%= theme.equals("dark") ? "dark-mode" : ""%>" data-theme="<%= theme%>">
        <div class="admin-container">
            <nav class="sidebar">
                <div class="sidebar-header">
                    <a style="color: white; margin-bottom: 20px; font-size: 24px; font-weight: 600; letter-spacing: 0.5px;" href="<%= request.getContextPath()%>/admin/dashboard">Oceanic Hotel</a>
                </div>
                <ul>
                    <li><a href="<%= request.getContextPath()%>/admin/dashboard"><%= language.equals("vi") ? "Tổng quan" : "Dashboard"%></a></li>
                    <li><a href="<%= request.getContextPath()%>/admin/users"><%= language.equals("vi") ? "Quản lý người dùng" : "User Management"%></a></li>
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
                            <p><%= message.equals("delete_success") ? (language.equals("vi") ? "Xóa loại phòng thành công!" : "Room type deleted successfully!") :
                                   message.equals("add_success") ? (language.equals("vi") ? "Thêm loại phòng thành công!" : "Room type added successfully!") :
                                   message.equals("update_success") ? (language.equals("vi") ? "Cập nhật loại phòng thành công!" : "Room type updated successfully!") : "" %></p>
                            <div class="modal-buttons">
                                <button class="modal-btn cancel-btn" onclick="document.getElementById('successModal').style.display = 'none'">
                                    <%= language.equals("vi") ? "Đóng" : "Close" %>
                                </button>
                            </div>
                        </div>
                    </div>
                <% } %>

                <div class="table-header">
                    <div class="add-room-type">
                        <button class="action-btn add-btn" onclick="window.location.href = '<%= request.getContextPath()%>/admin/room-types/add'">
                            <%= language.equals("vi") ? "Thêm loại phòng" : "Add Room Type"%>
                        </button>
                    </div>
                </div>
                <table class="data-table">
                    <thead>
                        <tr>
                            <th><%= language.equals("vi") ? "ID" : "ID"%></th>
                            <th><%= language.equals("vi") ? "Tên loại phòng" : "Type Name"%></th>
                            <th><%= language.equals("vi") ? "Giá mặc định" : "Default Price"%></th>
                            <th><%= language.equals("vi") ? "Số người lớn tối đa" : "Max Adults"%></th>
                            <th><%= language.equals("vi") ? "Số trẻ em tối đa" : "Max Children"%></th>
                            <th><%= language.equals("vi") ? "Hình ảnh chính" : "Primary Image"%></th>
                            <th><%= language.equals("vi") ? "Mô tả" : "Description"%></th>
                            <th><%= language.equals("vi") ? "Ngày tạo" : "Created At"%></th>
                            <th>...</th>
                        </tr>
                    </thead>
                    <tbody>
                        <%
                            List<RoomType> roomTypes = (List<RoomType>) request.getAttribute("roomTypes");
                            if (roomTypes != null) {
                                for (RoomType roomType : roomTypes) {
                        %>
                        <tr>
                            <td><%= roomType.getTypeId()%></td>
                            <td><%= roomType.getTypeName()%></td>
                            <%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
                            <td><fmt:formatNumber value="<%= roomType.getDefaultPrice()%>" type="number" minFractionDigits="0" maxFractionDigits="2"/> VND</td>
                            <td><%= roomType.getMaxAdults()%></td>
                            <td><%= roomType.getMaxChildren()%></td>
                            <td>
                                <% if (roomType.getPrimaryImage() != null) {%>
                                <img src="<%= request.getContextPath()%>/assets/images/<%= roomType.getPrimaryImage().getImageUrl()%>" alt="<%= roomType.getTypeName()%>" style="width: 50px; height: 50px;">
                                <% } else { %>
                                N/A
                                <% }%>
                            </td>
                            <td><%= roomType.getDescription() != null ? roomType.getDescription() : "N/A"%></td>
                            <td><%= roomType.getCreatedAt()%></td>
                            <td>
                                <div class="dropdown">
                                    <button class="dropdown-btn">⋮</button>
                                    <div class="dropdown-content">
                                        <a href="<%= request.getContextPath()%>/admin/room-types/edit?typeId=<%= roomType.getTypeId()%>">
                                            <%= language.equals("vi") ? "Sửa" : "Edit"%>
                                        </a>
                                        <a href="javascript:void(0)" onclick="confirmDelete('<%= roomType.getTypeId()%>')">
                                            <%= language.equals("vi") ? "Xóa" : "Delete"%>
                                        </a>
                                    </div>
                                </div>
                            </td>
                        </tr>
                        <% }
                        }%>
                    </tbody>
                </table>
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

            function confirmDelete(typeId) {
                const lang = '<%= language%>';
                const message = lang === 'vi' ? 
                    'Bạn có chắc chắn muốn xóa loại phòng này không? Nếu loại phòng đang được sử dụng bởi phòng nào, hành động này sẽ không thành công.' : 
                    'Are you sure you want to delete this room type? This action will fail if it is in use by any rooms.';
                if (confirm(message)) {
                    const form = document.createElement('form');
                    form.method = 'POST';
                    form.action = '<%= request.getContextPath()%>/admin/room-types/delete';
                    const input = document.createElement('input');
                    input.type = 'hidden';
                    input.name = 'typeId';
                    input.value = typeId;
                    form.appendChild(input);
                    document.body.appendChild(form);
                    form.submit();
                }
            }
        </script>
    </body>
</html>