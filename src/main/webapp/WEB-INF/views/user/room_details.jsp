<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ page import="com.mycompany.oceanichotel.models.User" %>
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
    User currentUser = (User) session.getAttribute("user");
%>
<!DOCTYPE html>
<html lang="<%= language %>">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><%= language.equals("vi") ? "Oceanic Hotel - Chi tiết phòng" : "Oceanic Hotel - Room Details" %></title>
    <link rel="icon" href="<%= request.getContextPath() %>/assets/images/logo.png" type="image/x-icon">
    <link href="https://cdn.jsdelivr.net/npm/tailwindcss@2.2.19/dist/tailwind.min.css" rel="stylesheet">
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0-beta3/css/all.min.css">
    <style>
        body {
            font-family: 'Poppins', sans-serif;
            transition: background 0.3s ease, color 0.3s ease;
        }
        .dark-mode {
            background: #1a202c;
            color: #e2e8f0;
        }
        .header-bg {
            background: linear-gradient(to bottom, rgba(0, 0, 0, 0.5), rgba(0, 0, 0, 0.7)), url('<%= request.getContextPath() %>/assets/images/hotel-bg.jpg') no-repeat center;
            background-size: cover;
        }
        .room-image {
            width: 100%;
            height: 400px;
            object-fit: cover;
        }
        .thumbnail-image {
            width: 100%;
            height: 100px;
            object-fit: cover;
            cursor: pointer;
            transition: opacity 0.3s ease;
        }
        .thumbnail-image:hover {
            opacity: 0.8;
        }
        .fallback-image {
            background: #e2e8f0;
            color: #4a5568;
            display: flex;
            align-items: center;
            justify-content: center;
            height: 400px;
            font-size: 18px;
        }
        .fallback-thumbnail {
            background: #e2e8f0;
            color: #4a5568;
            display: flex;
            align-items: center;
            justify-content: center;
            height: 100px;
            font-size: 14px;
        }
        .dark-mode .fallback-image, .dark-mode .fallback-thumbnail {
            background: #2d3748;
            color: #e2e8f0;
        }
        .btn {
            transition: all 0.3s ease;
        }
        .btn:hover {
            transform: translateY(-2px);
        }
    </style>
</head>
<body class="<%= theme.equals("dark") ? "dark-mode" : "" %>">
    <div class="relative min-h-screen">
        <!-- Header -->
        <header class="header-bg h-96 md:h-[70vh] relative rounded-b-3xl shadow-2xl">
            <div class="absolute inset-0 bg-black bg-opacity-40 rounded-b-3xl"></div>
            <nav class="absolute top-0 w-full flex justify-between items-center px-6 py-4 z-20">
                <div class="flex items-center space-x-4">
                    <img src="<%= request.getContextPath() %>/assets/images/width_800.jpg" alt="Logo" class="h-10">
                    <span class="text-white font-bold text-xl hidden md:block">Oceanic Hotel</span>
                </div>
                <div class="flex items-center space-x-6">
                    <c:choose>
                        <c:when test="${not empty sessionScope.user}">
                            <a href="<%= request.getContextPath() %>/user/profile" class="text-white hover:text-blue-300 transition"><%= language.equals("vi") ? "Hồ sơ" : "Profile" %></a>
                            <a href="<%= request.getContextPath() %>/user/bookings" class="text-white hover:text-blue-300 transition"><%= language.equals("vi") ? "Đặt phòng" : "Bookings" %></a>
                            <a href="<%= request.getContextPath() %>/logout" class="text-white hover:text-blue-300 transition"><%= language.equals("vi") ? "Đăng xuất" : "Logout" %></a>
                        </c:when>
                        <c:otherwise>
                            <a href="<%= request.getContextPath() %>/login" class="text-white hover:text-blue-300 transition"><%= language.equals("vi") ? "Đăng nhập" : "Login" %></a>
                            <a href="<%= request.getContextPath() %>/register" class="text-white hover:text-blue-300 transition"><%= language.equals("vi") ? "Đăng ký" : "Register" %></a>
                        </c:otherwise>
                    </c:choose>
                    <span class="language-toggle text-white" onclick="changeLanguage('<%= language.equals("vi") ? "en" : "vi" %>')">
                        <i class="fas fa-globe mr-1"></i><%= language.equals("vi") ? "EN" : "VI" %>
                    </span>
                    <span class="theme-toggle text-white" onclick="changeTheme('<%= theme.equals("dark") ? "light" : "dark" %>')">
                        <i class="fas <%= theme.equals("dark") ? "fa-sun" : "fa-moon" %>"></i>
                    </span>
                </div>
            </nav>
            <div class="relative z-10 flex flex-col items-center justify-center h-full text-center text-white px-4">
                <h1 class="text-4xl md:text-6xl font-bold mb-4 animate-fade-in-down"><%= language.equals("vi") ? "Chi tiết phòng" : "Room Details" %></h1>
                <p class="text-lg md:text-xl max-w-2xl"><%= language.equals("vi") ? "Xem thông tin chi tiết và đặt phòng của bạn." : "View detailed information and book your room." %></p>
            </div>
        </header>

        <!-- Main Content -->
        <main class="container mx-auto px-4 mt-12">
            <c:choose>
                <c:when test="${not empty room}">
                    <section class="bg-white dark:bg-gray-800 rounded-xl shadow-lg p-6">
                        <div class="grid grid-cols-1 lg:grid-cols-2 gap-6">
                            <!-- Room Images -->
                            <div>
                                <!-- Main Image -->
                                <c:choose>
                                    <c:when test="${not empty room.primaryImage && not empty room.primaryImage.imageUrl}">
                                        <img src="${pageContext.request.contextPath}/assets/images/${room.primaryImage.imageUrl}" 
                                             alt="${room.roomType.typeName}" class="room-image rounded-lg" id="mainImage">
                                    </c:when>
                                    <c:otherwise>
                                        <div class="fallback-image rounded-lg"><%= language.equals("vi") ? "Không có ảnh" : "No Image" %></div>
                                    </c:otherwise>
                                </c:choose>
                                <!-- Thumbnail Images -->
                                <div class="mt-4 grid grid-cols-4 gap-2">
                                    <c:if test="${not empty room.roomType.images}">
                                        <c:forEach var="image" items="${room.roomType.images}">
                                            <c:choose>
                                                <c:when test="${not empty image.imageUrl}">
                                                    <img src="${pageContext.request.contextPath}/assets/images/${image.imageUrl}" 
                                                         alt="${room.roomType.typeName} Thumbnail" 
                                                         class="thumbnail-image rounded-md" 
                                                         onclick="changeMainImage(this.src)">
                                                </c:when>
                                                <c:otherwise>
                                                    <div class="fallback-thumbnail rounded-md"><%= language.equals("vi") ? "Không có ảnh" : "No Image" %></div>
                                                </c:otherwise>
                                            </c:choose>
                                        </c:forEach>
                                    </c:if>
                                </div>
                            </div>
                            <!-- Room Details -->
                            <div>
                                <h2 class="text-2xl font-semibold text-gray-900 dark:text-white mb-4">
                                    <%= language.equals("vi") ? "Phòng" : "Room" %> ${room.roomNumber} - ${room.roomType.typeName}
                                </h2>
                                <p class="text-gray-600 dark:text-gray-300 mb-2">
                                    <%= language.equals("vi") ? "Giá mỗi đêm:" : "Price per night:" %> 
                                    <span class="font-medium">${room.pricePerNight} VND</span>
                                </p>
                                <p class="text-gray-600 dark:text-gray-300 mb-2">
                                    <%= language.equals("vi") ? "Sức chứa tối đa:" : "Max capacity:" %> 
                                    ${room.maxAdults} <%= language.equals("vi") ? "người lớn" : "adults" %>, 
                                    ${room.maxChildren} <%= language.equals("vi") ? "trẻ em" : "children" %>
                                </p>
                                <p class="text-gray-600 dark:text-gray-300 mb-4">
                                    <%= language.equals("vi") ? "Trạng thái:" : "Status:" %> 
                                    <span class="${room.available ? 'text-green-500' : 'text-red-500'}">
                                        <%= language.equals("vi") ? ((com.mycompany.oceanichotel.models.Room)request.getAttribute("room")).isAvailable() ? "Còn trống" : "Đã đặt" : ((com.mycompany.oceanichotel.models.Room)request.getAttribute("room")).isAvailable() ? "Available" : "Booked" %>
                                    </span>
                                </p>
                                <h3 class="text-lg font-medium text-gray-900 dark:text-white mb-2">
                                    <%= language.equals("vi") ? "Mô tả" : "Description" %>
                                </h3>
                                <p class="text-gray-600 dark:text-gray-300">${room.description != null ? room.description : room.roomType.description}</p>
                                <div class="mt-6 flex space-x-4">
                                    <a href="${pageContext.request.contextPath}/user/book-room?roomId=${room.roomId}" 
                                       class="px-6 py-2 bg-blue-500 text-white rounded-lg btn hover:bg-blue-600 <%= ((com.mycompany.oceanichotel.models.Room)request.getAttribute("room")).isAvailable() ? "" : "opacity-50 pointer-events-none" %>">
                                        <%= language.equals("vi") ? "Đặt phòng ngay" : "Book Now" %>
                                    </a>
                                    <a href="${pageContext.request.contextPath}/user/rooms?typeId=${room.roomType.typeId}" 
                                       class="px-6 py-2 bg-gray-500 text-white rounded-lg btn hover:bg-gray-600">
                                        <%= language.equals("vi") ? "Quay lại" : "Back" %>
                                    </a>
                                </div>
                            </div>
                        </div>
                    </section>
                </c:when>
                <c:otherwise>
                    <div class="text-center mt-8">
                        <p class="text-red-600 dark:text-red-400 text-lg">${error}</p>
                        <a href="${pageContext.request.contextPath}/user/dashboard" 
                           class="mt-4 inline-block px-6 py-2 bg-blue-500 text-white rounded-lg btn hover:bg-blue-600">
                            <%= language.equals("vi") ? "Quay lại trang chủ" : "Back to Dashboard" %>
                        </a>
                    </div>
                </c:otherwise>
            </c:choose>
        </main>

        <!-- Footer -->
        <footer class="bg-gray-900 dark:bg-gray-800 text-white py-6 mt-12">
            <div class="container mx-auto px-4 text-center">
                <p>© 2025 Oceanic Hotel. <%= language.equals("vi") ? "Mọi quyền được bảo lưu." : "All rights reserved." %></p>
                <div class="mt-2">
                    <a href="#" class="text-gray-400 hover:text-white mx-2"><i class="fab fa-facebook-f"></i></a>
                    <a href="#" class="text-gray-400 hover:text-white mx-2"><i class="fab fa-instagram"></i></a>
                    <a href="#" class="text-gray-400 hover:text-white mx-2"><i class="fab fa-twitter"></i></a>
                </div>
            </div>
        </footer>
    </div>

    <script>
        function changeLanguage(lang) {
            fetch('<%= request.getContextPath() %>/language', {
                method: 'POST',
                headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
                body: 'language=' + encodeURIComponent(lang)
            }).then(() => location.reload());
        }

        function changeTheme(theme) {
            fetch('<%= request.getContextPath() %>/theme', {
                method: 'POST',
                headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
                body: 'theme=' + encodeURIComponent(theme)
            }).then(() => {
                document.body.classList.toggle('dark-mode', theme === 'dark');
            });
        }

        function changeMainImage(src) {
            document.getElementById('mainImage').src = src;
        }

        document.addEventListener('DOMContentLoaded', () => {
            const elements = document.querySelectorAll('.animate-fade-in-down');
            elements.forEach(el => {
                el.style.opacity = 0;
                el.style.transform = 'translateY(-20px)';
                setTimeout(() => {
                    el.style.transition = 'opacity 0.5s ease, transform 0.5s ease';
                    el.style.opacity = 1;
                    el.style.transform = 'translateY(0)';
                }, 100);
            });
        });
    </script>
</body>
</html>