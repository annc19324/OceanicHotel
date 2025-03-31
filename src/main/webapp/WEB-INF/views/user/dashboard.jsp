<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ page import="java.util.List" %>
<%@ page import="com.mycompany.oceanichotel.models.User" %>
<%@ page import="com.mycompany.oceanichotel.models.RoomType" %>
<%@ page import="com.mycompany.oceanichotel.models.RoomTypeImage" %>
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
    List<RoomType> roomTypes = (List<RoomType>) request.getAttribute("roomTypes");
    String searchQuery = request.getParameter("search");
%>
<!DOCTYPE html>
<html lang="<%= language %>">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><%= language.equals("vi") ? "Trang chủ - Khách sạn Oceanic" : "Home - Oceanic Hotel" %></title>
    <link rel="icon" href="<%= request.getContextPath() %>/assets/images/logo.png" type="image/x-icon">
    <link href="https://cdn.jsdelivr.net/npm/tailwindcss@2.2.19/dist/tailwind.min.css" rel="stylesheet">
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0-beta3/css/all.min.css">
    <style>
        body {
            font-family: 'Poppins', sans-serif;
            transition: background 0.3s ease, color 0.3s ease;
            overflow-x: hidden;
        }
        .dark-mode {
            background: #1a202c;
            color: #e2e8f0;
        }
        .header-bg {
            background: linear-gradient(to bottom, rgba(0, 0, 0, 0.5), rgba(0, 0, 0, 0.7)), url('<%= request.getContextPath() %>/assets/images/hotel-bg.jpg') no-repeat center;
            background-size: cover;
        }
        .room-type-card img {
            height: 220px;
            object-fit: cover;
            transition: transform 0.3s ease;
        }
        .room-type-card:hover img {
            transform: scale(1.05);
        }
        .fallback-image {
            background: #e2e8f0;
            color: #4a5568;
            display: flex;
            align-items: center;
            justify-content: center;
            height: 220px;
            font-size: 16px;
        }
        .dark-mode .fallback-image {
            background: #2d3748;
            color: #e2e8f0;
        }
        .btn {
            transition: all 0.3s ease;
        }
        .btn:hover {
            transform: translateY(-2px);
        }
        .language-toggle, .theme-toggle {
            cursor: pointer;
            transition: color 0.3s ease;
        }
        .language-toggle:hover, .theme-toggle:hover {
            color: #60a5fa;
        }
        .offers-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(280px, 1fr));
            gap: 20px;
        }
        @media (max-width: 768px) {
            .header-bg {
                height: 70vh;
            }
            .room-type-card img, .fallback-image {
                height: 180px;
            }
        }
    </style>
</head>
<body class="<%= theme.equals("dark") ? "dark-mode" : "" %>">
    <div class="relative min-h-screen">
        <!-- Header -->
        <!--h96-->
        <header class="header-bg h-80 md:h-[70vh] relative rounded-b-3xl shadow-2xl">
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
                <h1 class="text-4xl md:text-6xl font-bold mb-4 animate-fade-in-down"><%= language.equals("vi") ? "Chào mừng đến với Khách sạn Oceanic" : "Welcome to Oceanic Hotel" %></h1>
                <p class="text-lg md:text-xl max-w-2xl"><%= language.equals("vi") ? "Trải nghiệm nghỉ dưỡng đẳng cấp bên bờ biển với dịch vụ hoàn hảo và không gian sang trọng." : "Experience luxury by the sea with impeccable service and elegant surroundings." %></p>
            </div>
        </header>

        <!-- Search Bar -->
        <div class="container mx-auto px-4 mt-10">
            <form action="<%= request.getContextPath() %>/user/dashboard" method="GET" class="w-full max-w-lg mx-auto">
                <div class="relative">
                    <input type="text" name="search" value="<%= searchQuery != null ? searchQuery : "" %>" 
                           placeholder="<%= language.equals("vi") ? "Tìm kiếm loại phòng..." : "Search room types..." %>" 
                           class="w-full p-4 pl-12 rounded-full border border-gray-300 focus:outline-none focus:ring-2 focus:ring-blue-500 shadow-md dark:bg-gray-700 dark:border-gray-600 dark:text-white">
                    <i class="fas fa-search absolute left-4 top-1/2 transform -translate-y-1/2 text-gray-400"></i>
                </div>
            </form>
        </div>

        <!-- Room Types -->
        <section class="container mx-auto px-4 mt-12">
            <h2 class="text-3xl font-semibold text-gray-900 dark:text-white text-center mb-8"><%= language.equals("vi") ? "Khám phá các loại phòng" : "Explore Room Types" %></h2>
            <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-8">
                <c:choose>
                    <c:when test="${not empty roomTypes}">
                        <c:forEach var="roomType" items="${roomTypes}">
                            <div class="room-type-card bg-white dark:bg-gray-800 rounded-xl shadow-lg overflow-hidden transform hover:shadow-2xl transition-all duration-300">
                                <c:choose>
                                    <c:when test="${not empty roomType.primaryImage && not empty roomType.primaryImage.imageUrl}">
                                        <img src="${pageContext.request.contextPath}/assets/images/${roomType.primaryImage.imageUrl}" alt="${roomType.typeName}" class="w-full">
                                    </c:when>
                                    <c:otherwise>
                                        <div class="fallback-image w-full"><%= language.equals("vi") ? "Ảnh không khả dụng" : "Image unavailable" %></div>
                                    </c:otherwise>
                                </c:choose>
                                <div class="p-6">
                                    <h3 class="text-xl font-semibold text-gray-900 dark:text-white mb-2">${roomType.typeName}</h3>
                                    <p class="text-gray-600 dark:text-gray-300 text-sm"><%= language.equals("vi") ? "Tối đa " + ((RoomType)pageContext.getAttribute("roomType")).getMaxAdults() + " người lớn, " + ((RoomType)pageContext.getAttribute("roomType")).getMaxChildren() + " trẻ em" 
                                        : "Max " + ((RoomType)pageContext.getAttribute("roomType")).getMaxAdults() + " adults, " + ((RoomType)pageContext.getAttribute("roomType")).getMaxChildren() + " children" %></p>
                                    <p class="text-gray-600 dark:text-gray-300 mt-1"><%= language.equals("vi") ? "Từ " : "From " %> <span class="font-medium">${roomType.defaultPrice} VND</span>/<%= language.equals("vi") ? "đêm" : "night" %></p>
                                    <a href="${pageContext.request.contextPath}/user/rooms?typeId=${roomType.typeId}" 
                                       class="mt-4 inline-block px-4 py-2 bg-blue-500 text-white rounded-lg btn hover:bg-blue-600"><%= language.equals("vi") ? "Đặt phòng" : "Booking" %></a>
                                </div>
                            </div>
                        </c:forEach>
                    </c:when>
                    <c:otherwise>
                        <p class="text-center col-span-full text-gray-600 dark:text-gray-300 text-lg"><%= language.equals("vi") ? "Không có loại phòng nào để hiển thị." : "No room types available." %></p>
                    </c:otherwise>
                </c:choose>
            </div>
        </section>

        <!-- Special Offers -->
        <section class="container mx-auto px-4 mt-16 mb-12">
            <h2 class="text-3xl font-semibold text-gray-900 dark:text-white text-center mb-8"><%= language.equals("vi") ? "Ưu đãi đặc biệt" : "Special Offers" %></h2>
            <div class="offers-grid">
                <div class="p-6 bg-gray-100 dark:bg-gray-700 rounded-xl shadow-md hover:shadow-lg transition">
                    <h4 class="text-lg font-medium text-blue-600 dark:text-blue-400 mb-2"><%= language.equals("vi") ? "Giảm 20% cho phòng Suite" : "20% Off Suite Rooms" %></h4>
                    <p class="text-gray-600 dark:text-gray-300 text-sm"><%= language.equals("vi") ? "Áp dụng từ 01/04 - 10/04/2025" : "Valid from 01/04 - 10/04/2025" %></p>
                    <a href="#" class="mt-3 inline-block text-blue-500 hover:text-blue-700 text-sm"><%= language.equals("vi") ? "Tìm hiểu thêm" : "Learn More" %></a>
                </div>
                <div class="p-6 bg-gray-100 dark:bg-gray-700 rounded-xl shadow-md hover:shadow-lg transition">
                    <h4 class="text-lg font-medium text-blue-600 dark:text-blue-400 mb-2"><%= language.equals("vi") ? "Ở 3 đêm, tặng 1 đêm miễn phí" : "Stay 3 Nights, Get 1 Free" %></h4>
                    <p class="text-gray-600 dark:text-gray-300 text-sm"><%= language.equals("vi") ? "Dành cho tất cả các loại phòng" : "Applicable to all room types" %></p>
                    <a href="#" class="mt-3 inline-block text-blue-500 hover:text-blue-700 text-sm"><%= language.equals("vi") ? "Tìm hiểu thêm" : "Learn More" %></a>
                </div>
            </div>
        </section>

        <!-- Footer -->
        <footer class="bg-gray-900 dark:bg-gray-800 text-white py-6">
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