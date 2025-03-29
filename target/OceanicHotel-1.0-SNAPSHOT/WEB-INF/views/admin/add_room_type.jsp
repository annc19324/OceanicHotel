<%@ page contentType="text/html;charset=UTF-8" language="java" %>
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
    String error = (String) request.getAttribute("error");
%>
<!DOCTYPE html>
<html lang="<%= language%>">
    <head>
        <meta charset="UTF-8">
        <title><%= language.equals("vi") ? "Thêm loại phòng - Khách sạn Oceanic" : "Add Room Type - Oceanic Hotel"%></title>
        <link rel="icon" href="<%= request.getContextPath()%>/assets/images/logo.png" type="image/x-icon">
        <link rel="stylesheet" href="<%= request.getContextPath()%>/assets/css/main.css">
        <link rel="stylesheet" href="<%= request.getContextPath()%>/assets/css/form.css">
        <link rel="stylesheet" href="<%= request.getContextPath()%>/assets/css/modal.css">
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
                    <li class="active"><a href="<%= request.getContextPath()%>/admin/room-types" ><%= language.equals("vi") ? "Quản lý loại phòng" : "Room Type Management"%></a></li>
                    <li><a href="<%= request.getContextPath()%>/admin/rooms"><%= language.equals("vi") ? "Quản lý phòng" : "Room Management"%></a></li>
                    <li><a href="<%= request.getContextPath()%>/admin/bookings"><%= language.equals("vi") ? "Quản lý đặt phòng" : "Booking Management"%></a></li>
                    <li><a href="<%= request.getContextPath()%>/admin/transactions"><%= language.equals("vi") ? "Quản lý giao dịch" : "Transaction Management"%></a></li>
                    <li><a href="<%= request.getContextPath()%>/admin/settings"><%= language.equals("vi") ? "Cấu hình hệ thống" : "System Settings"%></a></li>
                    <li><a href="<%= request.getContextPath()%>/admin/reports"><%= language.equals("vi") ? "Báo cáo" : "Reports"%></a></li>
                    <li><a href="<%= request.getContextPath()%>/logout"><%= language.equals("vi") ? "Đăng xuất" : "Logout"%></a></li>
                </ul>
            </nav>
            <div class="main-content">
                <form action="<%= request.getContextPath()%>/admin/room-types/add" method="POST" enctype="multipart/form-data">
                    <div class="form-group">
                        <label for="typeName"><%= language.equals("vi") ? "Tên loại phòng" : "Type Name"%></label>
                        <input type="text" id="typeName" name="typeName" required>
                    </div>
                    <div class="form-group">
                        <label for="defaultPrice"><%= language.equals("vi") ? "Giá mặc định mỗi đêm" : "Default Price per Night"%></label>
                        <input type="number" id="defaultPrice" name="defaultPrice" step="0.01" required>
                    </div>
                    <div class="form-group">
                        <label for="maxAdults"><%= language.equals("vi") ? "Số người lớn tối đa" : "Max Adults"%></label>
                        <input type="number" id="maxAdults" name="maxAdults" min="1" value="1" required>
                    </div>
                    <div class="form-group">
                        <label for="maxChildren"><%= language.equals("vi") ? "Số trẻ em tối đa" : "Max Children"%></label>
                        <input type="number" id="maxChildren" name="maxChildren" min="0" value="0" required>
                    </div>
                    <div class="form-group">
                        <label for="images"><%= language.equals("vi") ? "Hình ảnh" : "Images"%></label>
                        <input type="file" id="images" name="images" accept="image/*" multiple>
                    </div>
                    <div class="form-group">
                        <label for="description"><%= language.equals("vi") ? "Mô tả" : "Description"%></label>
                        <textarea id="description" name="description"></textarea>
                    </div>
                    <div class="form-buttons">
                        <button type="submit" class="action-btn add-btn"><%= language.equals("vi") ? "Thêm" : "Add"%></button>
                        <a href="<%= request.getContextPath()%>/admin/room-types" class="action-btn cancel-btn"><%= language.equals("vi") ? "Hủy" : "Cancel"%></a>
                    </div>
                </form>
                <% if (error != null) {%>
                <div class="custom-modal" id="errorModal" style="display: flex;">
                    <div class="modal-content animate-modal">
                        <h3><%= language.equals("vi") ? "Lỗi" : "Error"%></h3>
                        <p><%= error%></p>
                        <div class="modal-buttons">
                            <button class="modal-btn cancel-btn" onclick="document.getElementById('errorModal').style.display = 'none'">
                                <%= language.equals("vi") ? "Đóng" : "Close"%>
                            </button>
                        </div>
                    </div>
                </div>
                <% }%>
            </div>
        </div>
    </body>
</html>