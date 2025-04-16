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
<html lang="<%= language%>">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title><%= language.equals("vi") ? "Oceanic Hotel - Chi tiết phòng" : "Oceanic Hotel - Room Details"%></title>
        <link rel="icon" href="<%= request.getContextPath()%>/assets/images/logo.png" type="image/x-icon">
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
            .content-section {
                margin-top: 100px;
                padding: 15px;
                background: #fff;
                border-radius: 8px;
                box-shadow: 0 2px 4px rgba(0, 51, 102, 0.2);
            }
            .dark-mode .content-section {
                background: #2c5282;
            }
            h1, h2, h3 {
                font-weight: bold;
                margin-bottom: 15px;
            }
            .dark-mode h1, .dark-mode h2, .dark-mode h3 {
                color: #e6f0fa;
            }
            .room-image {
                width: 100%;
                height: 400px;
                object-fit: cover;
                border-radius: 8px;
            }
            .thumbnail-image {
                width: 100%;
                height: 100px;
                object-fit: cover;
                cursor: pointer;
                transition: opacity 0.3s ease;
                border-radius: 4px;
            }
            .thumbnail-image:hover {
                opacity: 0.8;
            }
            .fallback-image {
                background: #d1e3f0;
                color: #1e3a5f;
                display: flex;
                align-items: center;
                justify-content: center;
                height: 400px;
                font-size: 18px;
                border-radius: 8px;
            }
            .fallback-thumbnail {
                background: #d1e3f0;
                color: #1e3a5f;
                display: flex;
                align-items: center;
                justify-content: center;
                height: 100px;
                font-size: 14px;
                border-radius: 4px;
            }
            .dark-mode .fallback-image, .dark-mode .fallback-thumbnail {
                background: #4a6f9c;
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
            }
            .btn:hover {
                background: #1e4976;
            }
            .btn.disabled {
                opacity: 0.5;
                pointer-events: none;
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
            .text-description {
                color: #1e3a5f;
            }
            .dark-mode .text-description {
                color: #e6f0fa;
            }
        </style>
    </head>
    <body class="<%= theme.equals("dark") ? "dark-mode" : ""%>">
        <div class="relative">
            <!-- Header -->
            <header class="header-bg">
                <div class="flex items-center space-x-4">
                    <img src="<%= request.getContextPath()%>/assets/images/width_800.jpg" alt="Logo" class="h-10">
                    <a class="font-bold text-lg" href="<%= request.getContextPath()%>/user/dashboard">Oceanic Hotel</a>
                </div>
                <div class="flex items-center space-x-6">
                    <nav class="flex items-center space-x-6">
                        <c:choose>
                            <c:when test="${not empty sessionScope.user}">
                                <a href="<%= request.getContextPath()%>/user/profile" class="text-white hover:text-blue-300 transition"><%= language.equals("vi") ? "Hồ sơ" : "Profile"%></a>
                                <a href="<%= request.getContextPath()%>/user/bookings" class="text-white hover:text-blue-300 transition"><%= language.equals("vi") ? "Đặt phòng" : "Bookings"%></a>
                                <a href="<%= request.getContextPath()%>/user/change-password"><%= language.equals("vi") ? "Đổi mật khẩu" : "Change Password"%></a>
                                <a href="<%= request.getContextPath()%>/logout" class="text-white hover:text-blue-300 transition"><%= language.equals("vi") ? "Đăng xuất" : "Logout"%></a>
                            </c:when>
                            <c:otherwise>
                                <a href="<%= request.getContextPath()%>/login" class="text-white hover:text-blue-300 transition"><%= language.equals("vi") ? "Đăng nhập" : "Login"%></a>
                                <a href="<%= request.getContextPath()%>/register" class="text-white hover:text-blue-300 transition"><%= language.equals("vi") ? "Đăng ký" : "Register"%></a>
                            </c:otherwise>
                        </c:choose>
                        <span id="languageToggle" class="language-toggle text-white" onclick="changeLanguage('<%= language.equals("vi") ? "en" : "vi"%>')">
                            <i class="fas fa-globe mr-1"></i><%= language.equals("vi") ? "EN" : "VI"%>
                        </span>
                        <span id="themeToggle" class="theme-toggle text-white" onclick="changeTheme('<%= theme.equals("dark") ? "light" : "dark"%>')">
                            <i class="fas <%= theme.equals("dark") ? "fa-sun" : "fa-moon"%>"></i>
                        </span>
                    </nav>
                    <% if (currentUser != null) {%>
                    <div class="avatar-container">
                        <img src="<%= currentUser.getAvatar() != null && !currentUser.getAvatar().isEmpty() ? request.getContextPath() + "/assets/images/" + currentUser.getAvatar() : request.getContextPath() + "/assets/images/avatar-default.jpg"%>" 
                             alt="Avatar" class="avatar" 
                             onclick="showModal()"
                             onerror="this.src='<%= request.getContextPath()%>/assets/images/avatar-default.jpg'; this.onerror=null;">
                    </div>
                    <% } %>
                </div>
            </header>

            <!-- Modal để hiển thị ảnh lớn -->
            <% if (currentUser != null) {%>
            <div id="avatarModal" class="modal">
                <div class="modal-content">
                    <img src="<%= currentUser.getAvatar() != null && !currentUser.getAvatar().isEmpty() ? request.getContextPath() + "/assets/images/" + currentUser.getAvatar() : request.getContextPath() + "/assets/images/avatar-default.jpg"%>" 
                         alt="Large Avatar" class="modal-image"
                         onerror="this.src='<%= request.getContextPath()%>/assets/images/avatar-default.jpg'; this.onerror=null;">
                </div>
            </div>
            <% }%>

            <!-- Main Content -->
            <main class="container mx-auto px-4 mt-20">
                <div class="content-section">
                    <h1 class="text-4xl text-center"><%= language.equals("vi") ? "Chi tiết phòng" : "Room Details"%></h1>
                    <p class="text-center text-lg"><%= language.equals("vi") ? "Xem thông tin chi tiết và đặt phòng của bạn." : "View detailed information and book your room."%></p>

                    <c:choose>
                        <c:when test="${not empty room}">
                            <div class="grid grid-cols-1 lg:grid-cols-2 gap-6 mt-6">
                                <!-- Room Images -->
                                <div>
                                    <c:choose>
                                        <c:when test="${not empty room.primaryImage && not empty room.primaryImage.imageUrl}">
                                            <img src="${pageContext.request.contextPath}/assets/images/${room.primaryImage.imageUrl}" 
                                                 alt="${room.roomType.typeName}" class="room-image" id="mainImage">
                                        </c:when>
                                        <c:otherwise>
                                            <div class="fallback-image"><%= language.equals("vi") ? "Không có ảnh" : "No Image"%></div>
                                        </c:otherwise>
                                    </c:choose>
                                    <div class="mt-4 grid grid-cols-4 gap-2">
                                        <c:if test="${not empty room.roomType.images}">
                                            <c:forEach var="image" items="${room.roomType.images}">
                                                <c:choose>
                                                    <c:when test="${not empty image.imageUrl}">
                                                        <img src="${pageContext.request.contextPath}/assets/images/${image.imageUrl}" 
                                                             alt="${room.roomType.typeName} Thumbnail" 
                                                             class="thumbnail-image" 
                                                             onclick="changeMainImage(this.src)">
                                                    </c:when>
                                                    <c:otherwise>
                                                        <div class="fallback-thumbnail"><%= language.equals("vi") ? "Không có ảnh" : "No Image"%></div>
                                                    </c:otherwise>
                                                </c:choose>
                                            </c:forEach>
                                        </c:if>
                                    </div>
                                </div>
                                <!-- Room Details -->
                                <div>
                                    <h2 class="text-2xl">
                                        <%= language.equals("vi") ? "Phòng" : "Room"%> ${room.roomNumber} - ${room.roomType.typeName}
                                    </h2>
                                    <p class="text-description mb-2">
                                        <%= language.equals("vi") ? "Giá mỗi đêm:" : "Price per night:"%> 
                                        <span class="font-medium">${room.pricePerNight} VND</span>
                                    </p>
                                    <p class="text-description mb-2">
                                        <%= language.equals("vi") ? "Sức chứa tối đa:" : "Max capacity:"%> 
                                        ${room.maxAdults} <%= language.equals("vi") ? "người lớn" : "adults"%>, 
                                        ${room.maxChildren} <%= language.equals("vi") ? "trẻ em" : "children"%>
                                    </p>
                                    <p class="text-description mb-4">
                                        <%= language.equals("vi") ? "Trạng thái:" : "Status:"%> 
                                        <span class="${room.available ? 'text-green-500' : 'text-red-500'}">
                                            <%= language.equals("vi") ? ((com.mycompany.oceanichotel.models.Room) request.getAttribute("room")).isAvailable() ? "Còn trống" : "Đã đặt" : ((com.mycompany.oceanichotel.models.Room) request.getAttribute("room")).isAvailable() ? "Available" : "Booked"%>
                                        </span>
                                    </p>
                                    <h3 class="text-lg">
                                        <%= language.equals("vi") ? "Mô tả" : "Description"%>
                                    </h3>
                                    <p class="text-description">${room.description != null ? room.description : room.roomType.description}</p>
                                    <div class="mt-6 flex space-x-4">
                                        <a href="${pageContext.request.contextPath}/user/book-room?roomId=${room.roomId}" 
                                           class="btn <%= ((com.mycompany.oceanichotel.models.Room) request.getAttribute("room")).isAvailable() ? "" : "disabled"%>">
                                            <%= language.equals("vi") ? "Đặt phòng ngay" : "Book Now"%>
                                        </a>
                                        <a href="${pageContext.request.contextPath}/user/rooms?typeId=${room.roomType.typeId}" 
                                           class="btn bg-gray-500 hover:bg-gray-600">
                                            <%= language.equals("vi") ? "Quay lại" : "Back"%>
                                        </a>
                                    </div>
                                </div>
                            </div>
                        </c:when>
                        <c:otherwise>
                            <div class="text-center mt-8">
                                <p class="text-red-600 dark:text-red-400 text-lg">${error}</p>
                                <a href="${pageContext.request.contextPath}/user/dashboard" 
                                   class="mt-4 inline-block btn">
                                    <%= language.equals("vi") ? "Quay lại trang chủ" : "Back to Dashboard"%>
                                </a>
                            </div>
                        </c:otherwise>
                    </c:choose>
                </div>
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
                fetch('<%= request.getContextPath()%>/user/change-language', {
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
                fetch('<%= request.getContextPath()%>/user/change-theme', {
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

            function changeMainImage(src) {
                document.getElementById('mainImage').src = src;
            }
        </script>
    </body>
</html>