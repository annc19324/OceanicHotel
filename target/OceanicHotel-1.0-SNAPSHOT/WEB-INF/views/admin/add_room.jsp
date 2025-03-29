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
        <title><%= language.equals("vi") ? "Thêm phòng - Khách sạn Oceanic" : "Add Room - Oceanic Hotel"%></title>
        <link rel="icon" href="<%= request.getContextPath()%>/assets/images/logo.png" type="image/x-icon">
        <link rel="stylesheet" href="<%= request.getContextPath()%>/assets/css/main.css">
        <link rel="stylesheet" href="<%= request.getContextPath()%>/assets/css/form.css">
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
                    <li class="active"><a href="<%= request.getContextPath()%>/admin/rooms"><%= language.equals("vi") ? "Quản lý phòng" : "Room Management"%></a></li>
                    <li><a href="<%= request.getContextPath()%>/admin/bookings"><%= language.equals("vi") ? "Quản lý đặt phòng" : "Booking Management"%></a></li>
                    <li><a href="<%= request.getContextPath()%>/admin/transactions"><%= language.equals("vi") ? "Quản lý giao dịch" : "Transaction Management"%></a></li>
                    <li><a href="<%= request.getContextPath()%>/admin/settings"><%= language.equals("vi") ? "Cấu hình hệ thống" : "System Settings"%></a></li>
                    <li><a href="<%= request.getContextPath()%>/admin/reports"><%= language.equals("vi") ? "Báo cáo" : "Reports"%></a></li>
                    <li><a href="<%= request.getContextPath()%>/logout"><%= language.equals("vi") ? "Đăng xuất" : "Logout"%></a></li>
                </ul>
            </nav>
            <div class="main-content">

                <form action="<%= request.getContextPath()%>/admin/rooms/add" method="POST" enctype="multipart/form-data">
                    <div class="form-group">
                        <label for="roomNumber"><%= language.equals("vi") ? "Số phòng" : "Room Number"%></label>
                        <input type="text" id="roomNumber" name="roomNumber" required>
                    </div>
                    <div class="form-group">
                        <label for="roomType"><%= language.equals("vi") ? "Loại phòng" : "Room Type"%></label>
                        <select id="roomType" name="roomType" required>
                            <option value="Single"><%= language.equals("vi") ? "Phòng đơn" : "Single"%></option>
                            <option value="Double"><%= language.equals("vi") ? "Phòng đôi" : "Double"%></option>
                            <option value="Suite"><%= language.equals("vi") ? "Suite" : "Suite"%></option>
                            <option value="Deluxe"><%= language.equals("vi") ? "Deluxe" : "Deluxe"%></option>
                        </select>
                    </div>
                    <div class="form-group">
                        <label for="pricePerNight"><%= language.equals("vi") ? "Giá mỗi đêm" : "Price per Night"%></label>
                        <input type="number" id="pricePerNight" name="pricePerNight" step="0.01" required>
                    </div>
                    <div class="form-group">
                        <label for="image"><%= language.equals("vi") ? "Hình ảnh" : "Image"%></label>
                        <input type="file" id="image" name="image" accept="image/*">
                    </div>
                    <div class="form-group">
                        <label for="maxAdults"><%= language.equals("vi") ? "Số người lớn tối đa" : "Max Adults"%></label>
                        <input type="number" id="maxAdults" name="maxAdults" min="1" value="2" required>
                    </div>
                    <div class="form-group">
                        <label for="maxChildren"><%= language.equals("vi") ? "Số trẻ em tối đa" : "Max Children"%></label>
                        <input type="number" id="maxChildren" name="maxChildren" min="0" value="0" required>
                    </div>
                    <div class="form-group">
                        <label for="isAvailable"><%= language.equals("vi") ? "Trạng thái" : "Available"%></label>
                        <input type="checkbox" id="isAvailable" name="isAvailable" value="true" checked>
                    </div>
                    <div class="form-group">
                        <label for="description"><%= language.equals("vi") ? "Mô tả" : "Description"%></label>
                        <textarea id="description" name="description"></textarea>
                    </div>
                    <div class="form-buttons">
                        <button type="submit" class="action-btn add-btn"><%= language.equals("vi") ? "Thêm" : "Add"%></button>
                        <a href="<%= request.getContextPath()%>/admin/rooms" class="action-btn cancel-btn"><%= language.equals("vi") ? "Hủy" : "Cancel"%></a>
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
        <script>
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