<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.mycompany.oceanichotel.models.Room" %>
<%@ page import="com.mycompany.oceanichotel.models.RoomType" %>
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
    Room room = (Room) request.getAttribute("room");
    List<RoomType> roomTypes = (List<RoomType>) request.getAttribute("roomTypes");
    String error = (String) request.getAttribute("error");
%>
<!DOCTYPE html>
<html lang="<%= language%>">
<head>
    <meta charset="UTF-8">
    <title><%= language.equals("vi") ? "Sửa phòng - Khách sạn Oceanic" : "Edit Room - Oceanic Hotel"%></title>
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
            <li><a href="<%= request.getContextPath()%>/admin/room-types"><%= language.equals("vi") ? "Quản lý loại phòng" : "Room Type Management"%></a></li>
            <li class="active"><a href="<%= request.getContextPath()%>/admin/rooms"><%= language.equals("vi") ? "Quản lý phòng" : "Room Management"%></a></li>
            <li><a href="<%= request.getContextPath()%>/admin/bookings"><%= language.equals("vi") ? "Quản lý đặt phòng" : "Booking Management"%></a></li>
            <li><a href="<%= request.getContextPath()%>/admin/transactions"><%= language.equals("vi") ? "Quản lý giao dịch" : "Transaction Management"%></a></li>
            <li><a href="<%= request.getContextPath()%>/admin/settings"><%= language.equals("vi") ? "Cấu hình hệ thống" : "System Settings"%></a></li>
            <li><a href="<%= request.getContextPath()%>/admin/reports"><%= language.equals("vi") ? "Báo cáo" : "Reports"%></a></li>
            <li><a href="<%= request.getContextPath()%>/logout"><%= language.equals("vi") ? "Đăng xuất" : "Logout"%></a></li>
        </ul>
    </nav>
    <div class="main-content">
        <% if (room == null) { %>
            <p><%= language.equals("vi") ? "Không tìm thấy phòng để chỉnh sửa." : "No room found to edit." %></p>
            <a href="<%= request.getContextPath()%>/admin/rooms" class="action-btn cancel-btn"><%= language.equals("vi") ? "Quay lại" : "Back"%></a>
        <% } else { %>
            <form action="<%= request.getContextPath()%>/admin/rooms/update" method="POST">
                <input type="hidden" name="roomId" value="<%= room.getRoomId() %>">
                <div class="form-group">
                    <label for="roomNumber"><%= language.equals("vi") ? "Số phòng" : "Room Number"%></label>
                    <input type="text" id="roomNumber" name="roomNumber" value="<%= room.getRoomNumber() %>" required>
                </div>
                <div class="form-group">
                    <label for="typeId"><%= language.equals("vi") ? "Loại phòng" : "Room Type"%></label>
                    <select id="typeId" name="typeId" required onchange="updatePrice()">
                        <% for (RoomType roomType : roomTypes) { %>
                            <option value="<%= roomType.getTypeId() %>" <%= room.getRoomType() != null && room.getRoomType().getTypeId() == roomType.getTypeId() ? "selected" : "" %>>
                                <%= roomType.getTypeName() %>
                            </option>
                        <% } %>
                    </select>
                </div>
                <div class="form-group">
                    <label for="pricePerNight"><%= language.equals("vi") ? "Giá mỗi đêm" : "Price per Night"%></label>
                    <input type="number" id="pricePerNight" name="pricePerNight" step="0.01" value="<%= room.getPricePerNight() %>" required>
                </div>
                <div class="form-group">
                    <label for="maxAdults"><%= language.equals("vi") ? "Số người lớn tối đa" : "Max Adults"%></label>
                    <input type="number" id="maxAdults" name="maxAdults" min="1" value="<%= room.getMaxAdults() %>" required>
                </div>
                <div class="form-group">
                    <label for="maxChildren"><%= language.equals("vi") ? "Số trẻ em tối đa" : "Max Children"%></label>
                    <input type="number" id="maxChildren" name="maxChildren" min="0" value="<%= room.getMaxChildren() %>" required>
                </div>
                <div class="form-group">
                    <label for="isAvailable"><%= language.equals("vi") ? "Trạng thái" : "Available"%></label>
                    <input type="checkbox" id="isAvailable" name="isAvailable" value="true" <%= room.isAvailable() ? "checked" : "" %>>
                </div>
                <div class="form-group">
                    <label for="description"><%= language.equals("vi") ? "Mô tả" : "Description"%></label>
                    <textarea id="description" name="description"><%= room.getDescription() != null ? room.getDescription() : "" %></textarea>
                </div>
                <div class="form-buttons">
                    <button type="submit" class="action-btn add-btn"><%= language.equals("vi") ? "Cập nhật" : "Update"%></button>
                    <a href="<%= request.getContextPath()%>/admin/rooms" class="action-btn cancel-btn"><%= language.equals("vi") ? "Hủy" : "Cancel"%></a>
                </div>
            </form>
        <% } %>
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
<script>
    function updatePrice() {
        const typeId = document.getElementById('typeId')?.value;
        const priceInput = document.getElementById('pricePerNight');
        const maxAdultsInput = document.getElementById('maxAdults');
        const maxChildrenInput = document.getElementById('maxChildren');

        const roomTypes = {
            <% for (RoomType roomType : roomTypes) { %>
                '<%= roomType.getTypeId() %>': { price: <%= roomType.getDefaultPrice() %>, maxAdults: <%= roomType.getMaxAdults() %>, maxChildren: <%= roomType.getMaxChildren() %> },
            <% } %>
        };

        const selectedType = roomTypes[typeId];
        if (selectedType) {
            priceInput.value = selectedType.price;
            maxAdultsInput.value = selectedType.maxAdults;
            maxChildrenInput.value = selectedType.maxChildren;
        }
    }

    window.onload = function () {
        if (document.getElementById('typeId')) {
            updatePrice();
        }
    };
</script>
</body>
</html>