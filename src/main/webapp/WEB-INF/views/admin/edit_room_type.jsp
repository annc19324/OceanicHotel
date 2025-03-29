<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.mycompany.oceanichotel.models.RoomType" %>
<%@ page import="com.mycompany.oceanichotel.models.RoomTypeImage" %>
<%@ page import="java.util.List" %>
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
    RoomType roomType = (RoomType) request.getAttribute("roomType");
    String error = (String) request.getAttribute("error");
%>
<!DOCTYPE html>
<html lang="<%= language%>">
<head>
    <meta charset="UTF-8">
    <title><%= language.equals("vi") ? "Sửa loại phòng - Khách sạn Oceanic" : "Edit Room Type - Oceanic Hotel"%></title>
    <link rel="icon" href="<%= request.getContextPath()%>/assets/images/logo.png" type="image/x-icon">
    <link rel="stylesheet" href="<%= request.getContextPath()%>/assets/css/main.css">
    <link rel="stylesheet" href="<%= request.getContextPath()%>/assets/css/form.css">
    <link rel="stylesheet" href="<%= request.getContextPath()%>/assets/css/modal.css">
    <style>
        .image-gallery {
            display: flex;
            flex-wrap: wrap;
            gap: 10px;
        }
        .image-gallery .image-item {
            position: relative;
            width: 150px;
            text-align: center;
        }
        .image-gallery img {
            width: 100%;
            height: 100px;
            object-fit: cover;
            border-radius: 5px;
        }
        .image-gallery .primary {
            border: 3px solid #28a745;
        }
        .image-gallery .image-actions {
            position: absolute;
            top: 5px;
            right: 5px;
            display: flex;
            gap: 5px;
        }
        .image-gallery .image-actions a {
            background: #dc3545;
            color: white;
            padding: 2px 5px;
            border-radius: 3px;
            text-decoration: none;
            font-size: 12px;
        }
        .image-gallery .image-actions a.primary-btn {
            background: #28a745;
        }
        .image-label {
            font-size: 14px;
            margin-top: 5px;
            display: block;
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
        <form action="<%= request.getContextPath()%>/admin/room-types/update" method="POST" enctype="multipart/form-data">
            <input type="hidden" name="typeId" value="<%= roomType.getTypeId()%>">
            <div class="form-group">
                <label for="typeName"><%= language.equals("vi") ? "Tên loại phòng" : "Type Name"%></label>
                <input type="text" id="typeName" name="typeName" value="<%= roomType.getTypeName()%>" required>
            </div>
            <div class="form-group">
                <label for="defaultPrice"><%= language.equals("vi") ? "Giá mặc định mỗi đêm" : "Default Price per Night"%></label>
                <input type="number" id="defaultPrice" name="defaultPrice" step="0.01" value="<%= roomType.getDefaultPrice()%>" required>
            </div>
            <div class="form-group">
                <label><%= language.equals("vi") ? "Hình ảnh hiện tại" : "Current Images"%></label>
                <div class="image-gallery">
                    <% 
                        RoomTypeImage primaryImage = roomType.getPrimaryImage();
                        if (primaryImage != null) { 
                    %>
                    <div class="image-item">
                        <img src="<%= request.getContextPath()%>/assets/images/room-types/<%= primaryImage.getImageUrl()%>" 
                             alt="<%= roomType.getTypeName()%>" class="primary">
                        <div class="image-actions">
                            <a href="<%= request.getContextPath()%>/admin/room-types/delete-image?typeId=<%= roomType.getTypeId()%>&imageId=<%= primaryImage.getImageId()%>">Xóa</a>
                        </div>
                        <span class="image-label"><%= language.equals("vi") ? "Ảnh chính" : "Primary Image"%></span>
                    </div>
                    <% 
                        }
                        for (RoomTypeImage image : roomType.getImages()) {
                            if (!image.isPrimary()) {
                    %>
                    <div class="image-item">
                        <img src="<%= request.getContextPath()%>/assets/images/room-types/<%= image.getImageUrl()%>" 
                             alt="<%= roomType.getTypeName()%>">
                        <div class="image-actions">
                            <a href="<%= request.getContextPath()%>/admin/room-types/delete-image?typeId=<%= roomType.getTypeId()%>&imageId=<%= image.getImageId()%>">Xóa</a>
                            <a href="<%= request.getContextPath()%>/admin/room-types/set-primary?typeId=<%= roomType.getTypeId()%>&imageId=<%= image.getImageId()%>" class="primary-btn">
                                <%= language.equals("vi") ? "Đặt làm chính" : "Set as Primary"%>
                            </a>
                        </div>
                        <span class="image-label"><%= language.equals("vi") ? "Ảnh phụ" : "Secondary Image"%></span>
                    </div>
                    <% 
                            }
                        }
                    %>
                </div>
            </div>
            <div class="form-group">
                <label for="images"><%= language.equals("vi") ? "Thêm hình ảnh mới" : "Add New Images"%></label>
                <input type="file" id="images" name="images" accept="image/*" multiple>
            </div>
            <div class="form-group">
                <label for="maxAdults"><%= language.equals("vi") ? "Số người lớn tối đa" : "Max Adults"%></label>
                <input type="number" id="maxAdults" name="maxAdults" min="1" value="<%= roomType.getMaxAdults()%>" required>
            </div>
            <div class="form-group">
                <label for="maxChildren"><%= language.equals("vi") ? "Số trẻ em tối đa" : "Max Children"%></label>
                <input type="number" id="maxChildren" name="maxChildren" min="0" value="<%= roomType.getMaxChildren()%>" required>
            </div>
            <div class="form-group">
                <label for="description"><%= language.equals("vi") ? "Mô tả" : "Description"%></label>
                <textarea id="description" name="description"><%= roomType.getDescription() != null ? roomType.getDescription() : ""%></textarea>
            </div>
            <div class="form-buttons">
                <button type="submit" class="action-btn add-btn"><%= language.equals("vi") ? "Cập nhật" : "Update"%></button>
                <a href="<%= request.getContextPath()%>/admin/room-types" class="action-btn cancel-btn"><%= language.equals("vi") ? "Hủy" : "Cancel"%></a>
            </div>
        </form>
        <% if (error != null) { %>
        <div class="custom-modal" id="errorModal" style="display: flex;">
            <div class="modal-content animate-modal">
                <h3><%= language.equals("vi") ? "Lỗi" : "Error"%></h3>
                <p><%= error %></p>
                <div class="modal-buttons">
                    <button class="modal-btn cancel-btn" onclick="document.getElementById('errorModal').style.display = 'none'">
                        <%= language.equals("vi") ? "Đóng" : "Close"%>
                    </button>
                </div>
            </div>
        </div>
        <% } %>
    </div>
</div>
</body>
</html>