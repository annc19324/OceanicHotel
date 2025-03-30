<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ page import="java.util.List" %>
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
    <title><%= language.equals("vi") ? "Oceanic Hotel - Danh sách phòng" : "Oceanic Hotel - Room List" %></title>
    <link rel="icon" href="<%= request.getContextPath() %>/assets/images/logo.png" type="image/x-icon">
    <link href="https://cdn.jsdelivr.net/npm/tailwindcss@2.2.19/dist/tailwind.min.css" rel="stylesheet">
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0-beta3/css/all.min.css">
    <link rel="stylesheet" href="<%= request.getContextPath() %>/assets/css/rooms.css">
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
                <h1 class="text-4xl md:text-6xl font-bold mb-4 animate-fade-in-down"><%= language.equals("vi") ? "Danh sách phòng trống" : "Available Rooms" %></h1>
                <p class="text-lg md:text-xl max-w-2xl"><%= language.equals("vi") ? "Xem các phòng còn trống phù hợp với lựa chọn của bạn." : "View available rooms matching your selection." %></p>
            </div>
        </header>

        <!-- Main Content -->
        <main class="container mx-auto px-4 mt-12">
            <section class="room-list">
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