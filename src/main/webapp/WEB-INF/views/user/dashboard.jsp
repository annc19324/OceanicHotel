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
<%@ page import="com.mycompany.oceanichotel.models.RoomType" %>
<%@ page import="com.mycompany.oceanichotel.models.RoomTypeImage" %>
<%
    User currentUser = (User) session.getAttribute("user");
    String language = currentUser != null && currentUser.getLanguage() != null ? currentUser.getLanguage() : "en";
    String theme = currentUser != null && currentUser.getTheme() != null ? currentUser.getTheme() : "light";
    session.setAttribute("language", language);
    session.setAttribute("theme", theme);

    List<RoomType> roomTypes = (List<RoomType>) request.getAttribute("roomTypes");
    String searchQuery = request.getParameter("search");

    if (currentUser != null) {
        System.out.println("Avatar từ session: " + currentUser.getAvatar());
    } else {
        System.out.println("Không có currentUser trong session");
    }
%>
<!DOCTYPE html>
<html lang="<%= language %>">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title><%= language.equals("vi") ? "Trang chủ - Khách sạn Oceanic" : "Home - Oceanic Hotel" %></title>
        <link rel="icon" href="<%= request.getContextPath() %>/assets/images/logo.png" type="image/x-icon">
        <link href="https://cdn.jsdelivr.net/npm/tailwindcss@2.2.19/dist/tailwind.min.css" rel="stylesheet">
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0-beta3/css/all.min.css">
        <style>
            body {
                font-family: Arial, sans-serif;
                margin: 0;
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
            .room-card img {
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
            }
            .btn:hover {
                background: #1e4976;
            }
            .content {
                margin-top: 100px;
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
        <div class="">
            <!-- Header -->
            <header class="header-bg">
                <div class="flex items-center space-x-3">
                    <img src="<%= request.getContextPath() %>/assets/images/width_800.jpg" alt="Logo" class="h-8">
                    <a class="font-bold text-lg" href="<%= request.getContextPath() %>/user/dashboard">Oceanic Hotel</a>

                </div>
                <div class="flex items-center space-x-6">
                    <nav class="flex items-center space-x-6">
                        <c:choose>
                            <c:when test="${not empty sessionScope.user}">
                                <a href="<%= request.getContextPath() %>/user/profile"><%= language.equals("vi") ? "Hồ sơ" : "Profile" %></a>
                                <a href="<%= request.getContextPath() %>/user/bookings"><%= language.equals("vi") ? "Đặt phòng" : "Bookings" %></a>
                                <a href="<%= request.getContextPath() %>/user/change-password"><%= language.equals("vi") ? "Đổi mật khẩu" : "Change Password" %></a>
                                <a href="<%= request.getContextPath() %>/logout"><%= language.equals("vi") ? "Đăng xuất" : "Logout" %></a>
                            </c:when>
                            <c:otherwise>
                                <a href="<%= request.getContextPath() %>/login"><%= language.equals("vi") ? "Đăng nhập" : "Login" %></a>
                                <a href="<%= request.getContextPath() %>/register"><%= language.equals("vi") ? "Đăng ký" : "Register" %></a>
                            </c:otherwise>
                        </c:choose>
                        <span id="languageToggle" onclick="changeLanguage('<%= language.equals("vi") ? "en" : "vi" %>')">
                            <i class="fas fa-globe mr-1"></i><%= language.equals("vi") ? "EN" : "VI" %>
                        </span>
                        <span id="themeToggle" onclick="changeTheme('<%= theme.equals("dark") ? "light" : "dark" %>')">
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
            <div class="content">
                <!-- Search Bar -->
                <div class="container mx-auto px-4 mt-8">
                    <form action="<%= request.getContextPath() %>/user/dashboard" method="GET" class="max-w-lg mx-auto">
                        <div class="relative">
                            <input type="text" name="search" value="<%= searchQuery != null ? searchQuery : "" %>" 
                                   placeholder="<%= language.equals("vi") ? "Tìm kiếm loại phòng..." : "Search room types..." %>" 
                                   class="w-full p-3 pl-10 rounded-lg border border-gray-300 focus:outline-none focus:border-blue-500 dark:bg-gray-800 dark:border-gray-600 dark:text-white">
                            <i class="fas fa-search absolute left-3 top-1/2 transform -translate-y-1/2 text-gray-400"></i>
                        </div>
                    </form>
                </div>

                <!-- Room Types -->
                <section class="container mx-auto px-4 mt-10">
                    <h2 class="text-2xl font-bold text-center mb-6 dark:text-white"><%= language.equals("vi") ? "Khám phá các loại phòng" : "Explore Room Types" %></h2>
                    <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-6">
                        <c:choose>
                            <c:when test="${not empty roomTypes}">
                                <c:forEach var="roomType" items="${roomTypes}">
                                    <div class="room-card">
                                        <c:choose>
                                            <c:when test="${not empty roomType.primaryImage && not empty roomType.primaryImage.imageUrl}">
                                                <img src="${pageContext.request.contextPath}/assets/images/${roomType.primaryImage.imageUrl}" alt="${roomType.typeName}">
                                            </c:when>
                                            <c:otherwise>
                                                <div class="fallback-image"><%= language.equals("vi") ? "Ảnh không khả dụng" : "Image unavailable" %></div>
                                            </c:otherwise>
                                        </c:choose>
                                        <div class="p-4">
                                            <h3 class="text-lg font-semibold dark:text-white">${roomType.typeName}</h3>
                                            <p class="text-sm dark:text-gray-200"><%= language.equals("vi") ? "Tối đa " : "Max " %>${roomType.maxAdults} <%= language.equals("vi") ? "người lớn, " : "adults, " %>${roomType.maxChildren} <%= language.equals("vi") ? "trẻ em" : "children" %></p>
                                            <p class="text-sm dark:text-gray-200 mt-1"><%= language.equals("vi") ? "Từ " : "From " %>${roomType.defaultPrice} VND/<%= language.equals("vi") ? "đêm" : "night" %></p>
                                            <a href="${pageContext.request.contextPath}/user/rooms?typeId=${roomType.typeId}" class="btn mt-3 inline-block"><%= language.equals("vi") ? "Đặt phòng" : "Book Now" %></a>
                                        </div>
                                    </div>
                                </c:forEach>
                            </c:when>
                            <c:otherwise>
                                <p class="text-center col-span-full dark:text-gray-200"><%= language.equals("vi") ? "Không có loại phòng nào để hiển thị." : "No room types available." %></p>
                            </c:otherwise>
                        </c:choose>
                    </div>
                </section>
            </div>


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
                        location.reload(); // Reload để áp dụng ngôn ngữ mới
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
                        // Thay đổi giao diện ngay lập tức
                        document.body.classList.toggle('dark-mode', newTheme === 'dark');
                        // Cập nhật icon trên nút theme
                        const themeIcon = document.querySelector('#themeToggle i');
                        themeIcon.className = 'fas ' + (newTheme === 'dark' ? 'fa-sun' : 'fa-moon');
                        // Cập nhật sự kiện onclick cho lần nhấn tiếp theo
                        document.getElementById('themeToggle').setAttribute('onclick', "changeTheme('" + (newTheme === 'dark' ? 'light' : 'dark') + "')");
                    } else {
                        console.error('Lỗi khi thay đổi chủ đề: ' + response.status);
                    }
                }).catch(error => console.error('Lỗi mạng: ', error));
            }
        </script>
    </body>
</html>