<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.mycompany.oceanichotel.models.RoomType" %>
<%@ page import="com.mycompany.oceanichotel.models.RoomTypeImage" %>
<%@ page import="java.util.List" %>
<%@ page import="java.io.File" %>
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
    String message = request.getParameter("message");
    if (roomType == null) {
        response.sendRedirect(request.getContextPath() + "/admin/room-types?error=type_not_found");
        return;
    }
    String uploadPath = application.getRealPath("") + File.separator + "assets/images";
%>
<!DOCTYPE html>
<html lang="<%= language %>">
<head>
    <meta charset="UTF-8">
    <title><%= language.equals("vi") ? "Sửa loại phòng - Khách sạn Oceanic" : "Edit Room Type - Oceanic Hotel" %></title>
    <link rel="icon" href="<%= request.getContextPath() %>/assets/images/logo.png" type="image/x-icon">
    <link rel="stylesheet" href="<%= request.getContextPath() %>/assets/css/main.css">
    <link rel="stylesheet" href="<%= request.getContextPath() %>/assets/css/form.css">
    <link rel="stylesheet" href="<%= request.getContextPath() %>/assets/css/modal.css">
    <link rel="stylesheet" href="<%= request.getContextPath() %>/assets/css/edit_room_type.css">
</head>
<body class="<%= theme.equals("dark") ? "dark-mode" : "" %>" data-theme="<%= theme %>">
<div class="admin-container">
    <nav class="sidebar">
        <div class="sidebar-header">
            <a style="color: white; margin-bottom: 20px; font-size: 24px; font-weight: 600; letter-spacing: 0.5px;" href="<%= request.getContextPath() %>/admin/dashboard">Oceanic Hotel</a>
        </div>
        <ul>
            <li><a href="<%= request.getContextPath() %>/admin/dashboard"><%= language.equals("vi") ? "Tổng quan" : "Dashboard" %></a></li>
            <li><a href="<%= request.getContextPath() %>/admin/users"><%= language.equals("vi") ? "Quản lý người dùng" : "User Management" %></a></li>
            <li class="active"><a href="<%= request.getContextPath() %>/admin/room-types"><%= language.equals("vi") ? "Quản lý loại phòng" : "Room Type Management" %></a></li>
            <li><a href="<%= request.getContextPath() %>/admin/rooms"><%= language.equals("vi") ? "Quản lý phòng" : "Room Management" %></a></li>
            <li><a href="<%= request.getContextPath() %>/admin/bookings"><%= language.equals("vi") ? "Quản lý đặt phòng" : "Booking Management" %></a></li>
            <li><a href="<%= request.getContextPath() %>/admin/transactions"><%= language.equals("vi") ? "Quản lý giao dịch" : "Transaction Management" %></a></li>
            <li><a href="<%= request.getContextPath() %>/admin/settings"><%= language.equals("vi") ? "Cấu hình hệ thống" : "System Settings" %></a></li>
            <li><a href="<%= request.getContextPath() %>/admin/reports"><%= language.equals("vi") ? "Báo cáo" : "Reports" %></a></li>
            <li><a href="<%= request.getContextPath() %>/logout"><%= language.equals("vi") ? "Đăng xuất" : "Logout" %></a></li>
        </ul>
    </nav>
    <div class="main-content">
        <!-- Update Room Type Form -->
        <form action="<%= request.getContextPath() %>/admin/room-types/update" method="POST">
            <input type="hidden" name="typeId" value="<%= roomType.getTypeId() %>">
            <div class="form-group">
                <label for="typeName"><%= language.equals("vi") ? "Tên loại phòng" : "Type Name" %></label>
                <input type="text" id="typeName" name="typeName" value="<%= roomType.getTypeName() %>" required>
            </div>
            <div class="form-group">
                <label for="defaultPrice"><%= language.equals("vi") ? "Giá mặc định mỗi đêm" : "Default Price per Night" %></label>
                <input type="number" id="defaultPrice" name="defaultPrice" step="0.01" value="<%= roomType.getDefaultPrice() %>" required>
            </div>
            <div class="form-group">
                <label for="maxAdults"><%= language.equals("vi") ? "Số người lớn tối đa" : "Max Adults" %></label>
                <input type="number" id="maxAdults" name="maxAdults" min="1" value="<%= roomType.getMaxAdults() %>" required>
            </div>
            <div class="form-group">
                <label for="maxChildren"><%= language.equals("vi") ? "Số trẻ em tối đa" : "Max Children" %></label>
                <input type="number" id="maxChildren" name="maxChildren" min="0" value="<%= roomType.getMaxChildren() %>" required>
            </div>
            <div class="form-group">
                <label for="description"><%= language.equals("vi") ? "Mô tả" : "Description" %></label>
                <textarea id="description" name="description"><%= roomType.getDescription() != null ? roomType.getDescription() : "" %></textarea>
            </div>
            <div class="form-buttons">
                <button type="submit" class="action-btn add-btn"><%= language.equals("vi") ? "Cập nhật" : "Update" %></button>
                <a href="<%= request.getContextPath() %>/admin/room-types" class="action-btn cancel-btn"><%= language.equals("vi") ? "Hủy" : "Cancel" %></a>
            </div>
        </form>

        <!-- Current Images -->
        <div class="mt-8">
            <h3><%= language.equals("vi") ? "Hình ảnh hiện tại" : "Current Images" %></h3>
            <div class="image-gallery">
                <% 
                    for (RoomTypeImage image : roomType.getImages()) {
                        File imageFile = new File(uploadPath + File.separator + image.getImageUrl());
                        boolean fileExists = imageFile.exists();
                %>
                <div class="image-item <%= image.isPrimary() ? "primary" : "" %>">
                    <% if (fileExists) { %>
                    <img src="<%= request.getContextPath() %>/assets/images/<%= image.getImageUrl() %>" alt="<%= roomType.getTypeName() %>">
                    <% } else { %>
                    <span style="color: #dc3545; font-size: 12px;"><%= language.equals("vi") ? "Ảnh không tồn tại!" : "Image not found!" %></span>
                    <% } %>
                    <span class="image-status"><%= image.isPrimary() ? (language.equals("vi") ? "Ảnh chính" : "Primary Image") : (language.equals("vi") ? "Ảnh phụ" : "Secondary Image") %></span>
                    <div class="image-actions">
                        <form action="<%= request.getContextPath() %>/admin/room-types/delete-image" method="POST" style="display:inline;">
                            <input type="hidden" name="typeId" value="<%= roomType.getTypeId() %>">
                            <input type="hidden" name="imageId" value="<%= image.getImageId() %>">
                            <button type="submit" class="delete-btn" onclick="return confirm('<%= language.equals("vi") ? "Bạn có chắc chắn muốn xóa ảnh này không?" : "Are you sure you want to delete this image?" %>')"><%= language.equals("vi") ? "Xóa" : "Delete" %></button>
                        </form>
                        <% if (!image.isPrimary() && fileExists) { %>
                        <form action="<%= request.getContextPath() %>/admin/room-types/set-primary" method="POST" style="display:inline;">
                            <input type="hidden" name="typeId" value="<%= roomType.getTypeId() %>">
                            <input type="hidden" name="imageId" value="<%= image.getImageId() %>">
                            <button type="submit" class="primary-btn"><%= language.equals("vi") ? "Đặt làm chính" : "Set as Primary" %></button>
                        </form>
                        <% } %>
                    </div>
                </div>
                <% } %>
            </div>
        </div>

        <!-- Upload New Images -->
        <form action="<%= request.getContextPath() %>/admin/room-types/upload-images" method="POST" enctype="multipart/form-data" class="mt-8">
            <input type="hidden" name="typeId" value="<%= roomType.getTypeId() %>">
            <div class="form-group">
                <label for="images"><%= language.equals("vi") ? "Thêm hình ảnh mới" : "Add New Images" %></label>
                <input type="file" id="images" name="images" accept="image/*" multiple onchange="previewImages(event)" required>
                <div id="preview-container" class="preview-container"></div>
            </div>
            <div class="form-buttons">
                <button type="submit" class="action-btn add-btn"><%= language.equals("vi") ? "Tải lên" : "Upload" %></button>
            </div>
        </form>

        <!-- Success/Error Messages -->
        <% if (message != null) { %>
        <div class="custom-modal" id="successModal" style="display: flex;">
            <div class="modal-content animate-modal">
                <h3><%= language.equals("vi") ? "Thành công" : "Success" %></h3>
                <p><%= message.equals("image_upload_success") ? (language.equals("vi") ? "Ảnh đã được thêm thành công!" : "Images added successfully!") :
                       message.equals("image_deleted") ? (language.equals("vi") ? "Ảnh đã được xóa thành công!" : "Image deleted successfully!") :
                       message.equals("primary_set") ? (language.equals("vi") ? "Ảnh chính đã được cập nhật!" : "Primary image updated!") : "" %></p>
                <div class="modal-buttons">
                    <button class="modal-btn cancel-btn" onclick="document.getElementById('successModal').style.display = 'none'">
                        <%= language.equals("vi") ? "Đóng" : "Close" %>
                    </button>
                </div>
            </div>
        </div>
        <% } %>
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
    </div>
</div>

<script>
    function previewImages(event) {
        const previewContainer = document.getElementById('preview-container');
        previewContainer.innerHTML = '';
        const files = event.target.files;
        for (let i = 0; i < files.length; i++) {
            const file = files[i];
            const reader = new FileReader();
            reader.onload = function(e) {
                const img = document.createElement('img');
                img.src = e.target.result;
                previewContainer.appendChild(img);
            };
            reader.readAsDataURL(file);
        }
    }
</script>
</body>
</html>