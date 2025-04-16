<%--
    Copyright (c) 2025 annc19324
    All rights reserved.

    This code is the property of annc19324.
    Unauthorized copying or distribution is prohibited.
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ page import="java.util.List" %>
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
        <title><%= language.equals("vi") ? "Oceanic Hotel - Danh sách phòng" : "Oceanic Hotel - Room List" %></title>
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
            .room-card {
                background: #fff;
                border-radius: 8px;
                box-shadow: 0 2px 4px rgba(0, 51, 102, 0.2);
                transition: transform 0.2s;
            }
            .dark-mode .room-card {
                background: #2c5282;
            }
            .room-card:hover {
                transform: scale(1.03);
            }
            .room-image {
                width: 100%;
                height: 180px;
                object-fit: cover;
            }
            .fallback-image {
                width: 100%;
                height: 180px;
                background: #d1e3f0;
                color: #1e3a5f;
                display: flex;
                align-items: center;
                justify-content: center;
            }
            .dark-mode .fallback-image {
                background: #4a6f9c;
            }
            .btn {
                background: #2b6cb0;
                color: #fff;
                padding: 6px 12px;
                border-radius: 4px;
                text-decoration: none;
                transition: all 0.3s ease;
            }
            .btn:hover {
                background: #1e4976;
                transform: translateY(-2px);
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
        </style>
    </head>
    <body class="<%= theme.equals("dark") ? "dark-mode" : "" %>">
        <div class="relative ">
            <!-- Header -->
            <header class="header-bg">
                <div class="flex items-center space-x-4">
                    <img src="<%= request.getContextPath() %>/assets/images/width_800.jpg" alt="Logo" class="h-10">
                    <a class="font-bold text-lg" href="<%= request.getContextPath() %>/user/dashboard">Oceanic Hotel</a>

                </div>
                <div class="flex items-center space-x-6">
                    <nav class="flex items-center space-x-6">
                        <a href="<%= request.getContextPath() %>/user/profile" class="text-white hover:text-blue-300 transition"><%= language.equals("vi") ? "Hồ sơ" : "Profile" %></a>
                        <a href="<%= request.getContextPath() %>/user/bookings" class="text-white hover:text-blue-300 transition"><%= language.equals("vi") ? "Đặt phòng" : "Bookings" %></a>
                        <a href="<%= request.getContextPath() %>/user/change-password"><%= language.equals("vi") ? "Đổi mật khẩu" : "Change Password" %></a>
                        <a href="<%= request.getContextPath() %>/logout" class="text-white hover:text-blue-300 transition"><%= language.equals("vi") ? "Đăng xuất" : "Logout" %></a>
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
            <main class="container mx-auto px-4 mt-20">
                <div class="relative z-10 flex flex-col items-center justify-center h-full text-center text-black dark:text-white px-4">
                    <h1 class="text-4xl md:text-6xl font-bold mb-4 animate-fade-in-down"><%= language.equals("vi") ? "Danh sách phòng trống" : "Available Rooms" %></h1>
                    <p class="text-lg md:text-xl max-w-2xl"><%= language.equals("vi") ? "Xem các phòng còn trống phù hợp với lựa chọn của bạn." : "View available rooms matching your selection." %></p>
                </div>

                <section class="room-list mt-6">
                    <c:if test="${not empty error}">
                        <div class="text-center mt-8 text-red-600 dark:text-red-400">
                            ${error}
                        </div>
                    </c:if>

                    <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-8">
                        <c:forEach var="room" items="${rooms}">
                            <a href="<%= request.getContextPath() %>/user/room-details/${room.roomId}" class="room-card bg-white dark:bg-gray-800 rounded-xl shadow-lg overflow-hidden transform hover:shadow-2xl transition-all duration-300">
                                <c:choose>
                                    <c:when test="${not empty room.primaryImage && not empty room.primaryImage.imageUrl}">
                                        <img src="${pageContext.request.contextPath}/assets/images/${room.primaryImage.imageUrl}" alt="${room.roomType.typeName} Room" class="room-image">
                                    </c:when>
                                    <c:otherwise>
                                        <div class="fallback-image"><%= language.equals("vi") ? "Không có ảnh" : "No Image" %></div>
                                    </c:otherwise>
                                </c:choose>
                                <div class="p-6">
                                    <h3 class="text-xl font-semibold text-gray-900 dark:text-white mb-2"><%= language.equals("vi") ? "Phòng" : "Room" %> ${room.roomNumber} - ${room.roomType.typeName}</h3>
                                    <p class="text-gray-600 dark:text-gray-300 text-sm"><%= language.equals("vi") ? "Tối đa" : "Max" %>: ${room.maxAdults} <%= language.equals("vi") ? "người lớn" : "adults" %>, ${room.maxChildren} <%= language.equals("vi") ? "trẻ em" : "children" %></p>
                                    <p class="text-gray-600 dark:text-gray-300 mt-1"><%= language.equals("vi") ? "Từ " : "From " %><span class="font-medium">${room.pricePerNight} VND</span>/<%= language.equals("vi") ? "đêm" : "night" %></p>
                                </div>
                            </a>
                        </c:forEach>
                    </div>

                    <c:if test="${empty rooms}">
                        <div class="text-center mt-8">
                            <c:choose>
                                <c:when test="${not empty param.typeId}">
                                    <c:set var="typeName" value="" />
                                    <c:forEach var="roomType" items="${roomTypes}">
                                        <c:if test="${roomType.typeId == param.typeId}">
                                            <c:set var="typeName" value="${roomType.typeName}" />
                                        </c:if>
                                    </c:forEach>
                                    <p class="text-gray-600 dark:text-gray-300 text-lg">
                                        <%= language.equals("vi") ? "Loại phòng " : "Room type " %>
                                    <c:out value="${typeName}" default="${param.typeId}" />
                                    <%= language.equals("vi") ? " đã được sử dụng hết." : " is fully booked." %>
                                    </p>
                                </c:when>
                                <c:otherwise>
                                    <p class="text-gray-600 dark:text-gray-300 text-lg"><%= language.equals("vi") ? "Không có phòng trống cho loại phòng này." : "No available rooms for this room type." %></p>
                                </c:otherwise>
                            </c:choose>
                            <a href="${pageContext.request.contextPath}/user/dashboard" 
                               class="mt-4 inline-block px-6 py-2 bg-blue-500 text-white rounded-lg btn-back">
                                <%= language.equals("vi") ? "Quay lại chọn loại phòng khác" : "Back to select another room type" %>
                            </a>
                        </div>
                    </c:if>
                </section>
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
        </script>
    </body>
</html>