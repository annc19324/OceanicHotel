<%--
    Copyright (c) 2025 annc19324
    All rights reserved.

    This code is the property of annc19324.
    Unauthorized copying or distribution is prohibited.
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ page import="com.mycompany.oceanichotel.models.User" %>
<%
    User currentUser = (User) session.getAttribute("user");
    String language = currentUser != null && currentUser.getLanguage() != null ? currentUser.getLanguage() : "en";
    String theme = currentUser != null && currentUser.getTheme() != null ? currentUser.getTheme() : "light";
    session.setAttribute("language", language);
    session.setAttribute("theme", theme);
%>
<!DOCTYPE html>
<html lang="<%= language %>">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title><%= language.equals("vi") ? "Oceanic Hotel - Đặt phòng" : "Oceanic Hotel - Book Room" %></title>
        <link rel="icon" href="<%= request.getContextPath() %>/assets/images/logo.png" type="image/x-icon">
        <link href="https://cdn.jsdelivr.net/npm/tailwindcss@2.2.19/dist/tailwind.min.css" rel="stylesheet">
        <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;600;700&display=swap" rel="stylesheet">
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0-beta3/css/all.min.css">
        <style>
            body {
                font-family: 'Poppins', sans-serif;
                transition: background 0.3s ease, color 0.3s ease;
                background: #f0f7fa;
                color: #1e3a5f;
            }
            .dark-mode {
                background: #1e3a5f;
                color: #e6f0fa;
            }
            .header-bg {
                background: #1e3a5f;
                position: fixed;
                width: 100%;
                top: 0;
                z-index: 10;
                padding: 1rem 1.5rem;
                display: flex;
                justify-content: space-between;
                align-items: center;
                box-shadow: 0 2px 4px rgba(0, 51, 102, 0.2);
            }
            .header-bg a, .header-bg span {
                color: #fff;
                text-decoration: none;
                cursor: pointer;
            }
            .header-bg a:hover, .header-bg span:hover {
                color: #a3bffa;
            }
            .content {
                margin-top: 100px;
            }
            .form-section {
                background: #fff;
                border-radius: 8px;
                box-shadow: 0 2px 4px rgba(0, 51, 102, 0.2);
                padding: 15px;
                max-width: 400px;
                margin: 0 auto;
            }
            .dark-mode .form-section {
                background: #2c5282;
            }
            h1, h2 {
                font-weight: bold;
                margin-bottom: 10px;
            }
            .dark-mode h1, .dark-mode h2 {
                color: #e6f0fa;
            }
            .form-group {
                margin-bottom: 10px;
            }
            label {
                display: block;
                font-weight: bold;
                margin-bottom: 3px;
                font-size: 0.9rem;
            }
            input[type="date"], input[type="number"] {
                width: 100%;
                padding: 6px;
                border: 1px solid #ccc;
                border-radius: 4px;
                font-size: 0.9rem;
            }
            .dark-mode input[type="date"], .dark-mode input[type="number"] {
                background: #4a6f9c;
                border-color: #a3bffa;
                color: #e6f0fa;
            }
            .btn {
                background: #2b6cb0;
                color: #fff;
                padding: 6px 12px;
                border: none;
                border-radius: 4px;
                text-decoration: none;
                cursor: pointer;
                transition: background 0.2s;
                font-size: 0.9rem;
            }
            .btn:hover {
                background: #1e4976;
            }
            .avatar {
                width: 48px;
                height: 48px;
                border-radius: 50%;
                object-fit: cover;
                cursor: pointer;
            }
            .avatar-container {
                display: flex;
                align-items: center;
            }
            .modal {
                display: none;
                position: fixed;
                top: 0;
                left: 0;
                width: 100%;
                height: 100%;
                background-color: rgba(0,0,0,0.8);
                z-index: 1000;
            }
            .modal-content {
                position: absolute;
                top: 50%;
                left: 50%;
                transform: translate(-50%, -50%);
                max-width: 90%;
                max-height: 90%;
            }
            .modal-image {
                width: 300px;
                height: auto;
                border-radius: 10px;
            }
            .error-message {
                color: #ef4444;
                font-size: 0.85rem;
                margin-top: 5px;
                display: none;
            }
            .dark-mode .error-message {
                color: #f87171;
            }
        </style>
    </head>
    <body class="<%= theme.equals("dark") ? "dark-mode" : "" %>">
        <div class="relative">
            <!-- Header -->
            <header class="header-bg">
                <div class="flex items-center space-x-4">
                    <img src="<%= request.getContextPath() %>/assets/images/width_800.jpg" alt="Logo" class="h-10">
                    <a class="font-bold text-lg" href="<%= request.getContextPath() %>/user/dashboard">Oceanic Hotel</a>
                </div>
                <div class="flex items-center space-x-6">
                    <nav class="flex items-center space-x-6">
                        <c:choose>
                            <c:when test="${not empty sessionScope.user}">
                                <a href="<%= request.getContextPath() %>/user/profile" class="text-white hover:text-blue-300 transition"><%= language.equals("vi") ? "Hồ sơ" : "Profile" %></a>
                                <a href="<%= request.getContextPath() %>/user/bookings" class="text-white hover:text-blue-300 transition"><%= "vi".equals(language) ? "Chi Tiết Đặt phòng" : "Detail Bookings" %></a>

                                <a href="<%= request.getContextPath() %>/user/change-password"><%= language.equals("vi") ? "Đổi mật khẩu" : "Change Password" %></a>
                                <a href="<%= request.getContextPath() %>/logout" class="text-white hover:text-blue-300 transition"><%= language.equals("vi") ? "Đăng xuất" : "Logout" %></a>
                            </c:when>
                            <c:otherwise>
                                <a href="<%= request.getContextPath() %>/login" class="text-white hover:text-blue-300 transition"><%= language.equals("vi") ? "Đăng nhập" : "Login" %></a>
                                <a href="<%= request.getContextPath() %>/register" class="text-white hover:text-blue-300 transition"><%= language.equals("vi") ? "Đăng ký" : "Register" %></a>
                            </c:otherwise>
                        </c:choose>
                        <span id="languageToggle" class="language-toggle text-white" onclick="changeLanguage('<%= language.equals("vi") ? "en" : "vi" %>')">
                            <i class="fas fa-globe mr-1"></i><%= language.equals("vi") ? "EN" : "VI" %>
                        </span>
                        <span id="themeToggle" class="theme-toggle text-white" onclick="changeTheme('<%= theme.equals("dark") ? "light" : "dark" %>')">
                            <i class="fas <%= theme.equals("dark") ? "fa-sun" : "fa-moon" %>"></i>
                        </span>
                    </nav>
                    <% if (currentUser != null) { %>
                    <div class="avatar-container">
                        <img src="<%= currentUser.getAvatar() != null && !currentUser.getAvatar().isEmpty() ? request.getContextPath() + "/assets/images/" + currentUser.getAvatar() : request.getContextPath() + "/assets/images/avatar-default.jpg" %>" 
                             alt="Avatar" class="avatar" 
                             onclick="showModal()"
                             onerror="this.src='<%= request.getContextPath() %>/assets/images/avatar-default.jpg'; this.onerror=null;">
                    </div>
                    <% } %>
                </div>
            </header>

            <!-- Modal để hiển thị ảnh lớn -->
            <% if (currentUser != null) { %>
            <div id="avatarModal" class="modal">
                <div class="modal-content">
                    <img src="<%= currentUser.getAvatar() != null && !currentUser.getAvatar().isEmpty() ? request.getContextPath() + "/assets/images/" + currentUser.getAvatar() : request.getContextPath() + "/assets/images/avatar-default.jpg" %>" 
                         alt="Large Avatar" class="modal-image"
                         onerror="this.src='<%= request.getContextPath() %>/assets/images/avatar-default.jpg'; this.onerror=null;">
                </div>
            </div>
            <% } %>

            <!-- Main Content -->
            <main class="container mx-auto px-4 content">
                <div class="text-center">
                    <h1 class="text-4xl font-bold mb-4"><%= language.equals("vi") ? "Đặt phòng" : "Book Room" %></h1>
                    <p class="text-lg mb-8"><%= language.equals("vi") ? "Hoàn tất thông tin để đặt phòng của bạn." : "Complete the details to book your room." %></p>
                </div>

                <c:choose>
                    <c:when test="${not empty success}">
                        <div class="text-center mt-8">
                            <p class="text-green-600 dark:text-green-400 text-lg">${success}</p>
                            <a href="${pageContext.request.contextPath}/user/bookings" 
                               class="mt-4 inline-block btn">
                                <%= language.equals("vi") ? "Xem lịch sử đặt phòng" : "View Booking History" %>
                            </a>
                        </div>
                    </c:when>
                    <c:otherwise>
                        <section class="form-section">
                            <h2 class="text-xl text-center">
                                <%= language.equals("vi") ? "Phòng" : "Room" %> ${room.roomNumber} - ${room.roomType.typeName}
                            </h2>
                            <p class="text-center mb-4">
                                <%= language.equals("vi") ? "Giá mỗi đêm:" : "Price per night:" %> 
                                <span class="font-medium">${room.pricePerNight} VND</span>
                            </p>
                            <c:if test="${not empty error}">
                                <p class="text-red-600 dark:text-red-400 mb-4 text-center">${error}</p>
                            </c:if>
                            <form id="bookingForm" action="${pageContext.request.contextPath}/user/book-room" method="POST" onsubmit="return validateForm()">
                                <input type="hidden" name="roomId" value="${room.roomId}">
                                <div class="form-group">
                                    <label for="checkInDate"><%= language.equals("vi") ? "Ngày nhận phòng" : "Check-in Date" %></label>
                                    <input type="date" id="checkInDate" name="checkInDate" required>
                                    <p id="checkInError" class="error-message"><%= language.equals("vi") ? "Ngày nhận phòng phải từ 2 đến 7 ngày sau ngày hiện tại." : "Check-in date must be between 2 and 7 days from today." %></p>
                                </div>
                                <div class="form-group">
                                    <label for="checkOutDate"><%= language.equals("vi") ? "Ngày trả phòng" : "Check-out Date" %></label>
                                    <input type="date" id="checkOutDate" name="checkOutDate" required>
                                    <p id="checkOutError" class="error-message"><%= language.equals("vi") ? "Ngày trả phòng phải sau ngày nhận phòng." : "Check-out date must be after check-in date." %></p>
                                </div>
                                <div class="form-group">
                                    <label for="adults"><%= language.equals("vi") ? "Số người lớn" : "Number of Adults" %></label>
                                    <input type="number" id="adults" name="adults" min="1" max="${room.maxAdults}" value="1" required>
                                    <p id="adultsError" class="error-message"><%= language.equals("vi") ? "Số người lớn tối đa là " : "Maximum number of adults is " %>${room.maxAdults}</p>
                                </div>
                                <div class="form-group">
                                    <label for="children"><%= language.equals("vi") ? "Số trẻ em" : "Number of Children" %></label>
                                    <input type="number" id="children" name="children" min="0" max="${room.maxChildren}" value="0" required>
                                    <p id="childrenError" class="error-message"><%= language.equals("vi") ? "Số trẻ em tối đa là " : "Maximum number of children is " %>${room.maxChildren}</p>
                                </div>
                                <button type="submit" class="w-full btn"><%= language.equals("vi") ? "Xác nhận đặt phòng" : "Confirm Booking" %></button>
                            </form>
                            <a href="${pageContext.request.contextPath}/user/room-details/${room.roomId}" 
                               class="mt-4 block text-center text-blue-500 hover:text-blue-700">
                                <%= language.equals("vi") ? "Quay lại chi tiết phòng" : "Back to Room Details" %>
                            </a>
                        </section>
                    </c:otherwise>
                </c:choose>
            </main>
        </div>

        <script>
            function showModal() {
                const modal = document.getElementById('avatarModal');
                modal.style.display = 'block';
                modal.onclick = function () {
                    modal.style.display = 'none';
                }
            }

            function changeLanguage(lang) {
                fetch('<%= request.getContextPath() %>/user/change-language', {
                    method: 'POST',
                    headers: {'Content-Type': 'application/x-www-form-urlencoded'},
                    body: 'language=' + encodeURIComponent(lang)
                }).then(response => {
                    if (response.ok) {
                        location.reload();
                    } else {
                        console.error('Lỗi khi thay đổi ngôn ngữ: ' + response.status);
                    }
                }).catch(error => console.error('Lỗi mạng: ', error));
            }

            function changeTheme(newTheme) {
                fetch('<%= request.getContextPath() %>/user/change-theme', {
                    method: 'POST',
                    headers: {'Content-Type': 'application/x-www-form-urlencoded'},
                    body: 'theme=' + encodeURIComponent(newTheme)
                }).then(response => {
                    if (response.ok) {
                        document.body.classList.toggle('dark-mode', newTheme === 'dark');
                        const themeIcon = document.querySelector('#themeToggle i');
                        themeIcon.className = 'fas ' + (newTheme === 'dark' ? 'fa-sun' : 'fa-moon');
                        document.getElementById('themeToggle').setAttribute('onclick', "changeTheme('" + (newTheme === 'dark' ? 'light' : 'dark') + "')");
                    } else {
                        console.error('Lỗi khi thay đổi chủ đề: ' + response.status);
                    }
                }).catch(error => console.error('Lỗi mạng: ', error));
            }

            function validateForm() {
                let isValid = true;
                const today = new Date();
                today.setHours(0, 0, 0, 0); // Đặt giờ về 00:00 để so sánh ngày chính xác
                const minCheckIn = new Date(today);
                minCheckIn.setDate(today.getDate() + 2); // Tối thiểu 2 ngày sau
                const maxCheckIn = new Date(today);
                maxCheckIn.setDate(today.getDate() + 7); // Tối đa 7 ngày sau
                const minCheckInDate = minCheckIn.toISOString().split('T')[0];
                const maxCheckInDate = maxCheckIn.toISOString().split('T')[0];
                const checkInDate = document.getElementById('checkInDate').value;
                const checkOutDate = document.getElementById('checkOutDate').value;
                const adults = parseInt(document.getElementById('adults').value);
                const children = parseInt(document.getElementById('children').value);
                const maxAdults = parseInt(document.getElementById('adults').max);
                const maxChildren = parseInt(document.getElementById('children').max);

                // Reset error messages
                document.getElementById('checkInError').style.display = 'none';
                document.getElementById('checkOutError').style.display = 'none';
                document.getElementById('adultsError').style.display = 'none';
                document.getElementById('childrenError').style.display = 'none';

                // Validate check-in date (từ 2-7 ngày sau hôm nay)
                if (checkInDate < minCheckInDate || checkInDate > maxCheckInDate) {
                    document.getElementById('checkInError').style.display = 'block';
                    document.getElementById('checkInError').textContent =
                            '<%= language.equals("vi") ? "Ngày nhận phòng phải từ 2 đến 7 ngày sau ngày hiện tại." : "Check-in date must be between 2 and 7 days from today." %>';
                    isValid = false;
                }

                // Validate check-out date
                if (checkOutDate <= checkInDate) {
                    document.getElementById('checkOutError').style.display = 'block';
                    isValid = false;
                }

                // Validate number of adults
                if (adults < 1 || adults > maxAdults) {
                    document.getElementById('adultsError').style.display = 'block';
                    isValid = false;
                }

                // Validate number of children
                if (children < 0 || children > maxChildren) {
                    document.getElementById('childrenError').style.display = 'block';
                    isValid = false;
                }

                return isValid;
            }
        </script>
    </body>
</html>