<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
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
    <link rel="stylesheet" href="<%= request.getContextPath() %>/assets/css/room-details.css">
    <script>
        window.contextPath = '<%= request.getContextPath() %>';
    </script>
    <script type="module" src="<%= request.getContextPath() %>/assets/js/language.js" defer></script>
    <script type="module" src="<%= request.getContextPath() %>/assets/js/theme.js" defer></script>
</head>
<body class="<%= theme.equals("dark") ? "dark-mode" : "" %>" data-theme="<%= theme %>">
    <!-- Settings -->
    <div class="settings">
        <select id="languageSelect">
            <option value="en" <%= language.equals("en") ? "selected" : "" %>><%= language.equals("vi") ? "Tiếng Anh" : "English" %></option>
            <option value="vi" <%= language.equals("vi") ? "selected" : "" %>><%= language.equals("vi") ? "Tiếng Việt" : "Vietnamese" %></option>
        </select>
        <select id="themeSelect">
            <option value="light" <%= theme.equals("light") ? "selected" : "" %>><%= language.equals("vi") ? "Chế độ sáng" : "Light Mode" %></option>
            <option value="dark" <%= theme.equals("dark") ? "selected" : "" %>><%= language.equals("vi") ? "Chế độ tối" : "Dark Mode" %></option>
        </select>
    </div>

    <jsp:include page="/WEB-INF/views/partials/header.jsp" />

    <main class="container mx-auto px-4 py-12 animate-fade-in">
        <section class="room-details">
            <div class="grid grid-cols-1 lg:grid-cols-2 gap-8">
                <!-- Room Gallery -->
                <div class="room-gallery">
                    <div class="main-image rounded-xl overflow-hidden shadow-lg">
                        <img src="${pageContext.request.contextPath}/assets/images/${room.primaryImage.imageUrl}" alt="${room.roomType.typeName} Room" id="mainImage" class="w-full">
                    </div>
                    <div class="thumbnail-images flex space-x-2 mt-4">
                        <c:forEach var="image" items="${room.roomType.images}">
                            <img src="${pageContext.request.contextPath}/assets/images/${image.imageUrl}" alt="${room.roomType.typeName} Room" class="thumbnail" onclick="changeMainImage(this.src)">
                        </c:forEach>
                    </div>
                </div>

                <!-- Room Info -->
                <div class="room-info">
                    <h1 class="text-3xl font-bold text-gray-900 dark:text-white"><%= language.equals("vi") ? "Phòng" : "Room" %> ${room.roomNumber} - ${room.roomType.typeName}</h1>
                    <p class="text-blue-600 dark:text-blue-400 font-semibold text-2xl mt-2">${room.pricePerNight} VND/<%= language.equals("vi") ? "đêm" : "night" %></p>
                    <p class="text-gray-600 dark:text-gray-300 mt-4">${room.description}</p>

                    <div class="room-features mt-6">
                        <h3 class="text-xl font-semibold text-gray-900 dark:text-white"><%= language.equals("vi") ? "Tiện nghi" : "Amenities" %></h3>
                        <ul class="list-disc pl-5 text-gray-600 dark:text-gray-300 mt-2">
                            <li><%= language.equals("vi") ? "Tối đa" : "Max" %>: ${room.maxAdults} <%= language.equals("vi") ? "người lớn" : "adults" %>, ${room.maxChildren} <%= language.equals("vi") ? "trẻ em" : "children" %></li>
                            <li>WiFi <%= language.equals("vi") ? "miễn phí" : "free" %></li>
                            <li><%= language.equals("vi") ? "Điều hòa nhiệt độ" : "Air conditioning" %></li>
                            <li>TV <%= language.equals("vi") ? "màn hình phẳng" : "flat-screen" %></li>
                            <li>Mini bar</li>
                            <li><%= language.equals("vi") ? "Bồn tắm/Vòi sen" : "Bathtub/Shower" %></li>
                        </ul>
                    </div>

                    <!-- Booking Form -->
                    <div class="booking-form mt-8 bg-gray-100 dark:bg-gray-800 p-6 rounded-xl shadow-md">
                        <h3 class="text-xl font-semibold text-gray-900 dark:text-white"><%= language.equals("vi") ? "Đặt phòng ngay" : "Book Now" %></h3>
                        <form action="${pageContext.request.contextPath}/user/booking" method="post" oninput="calculateTotal()">
                            <input type="hidden" name="roomId" value="${room.roomId}">
                            <div class="grid grid-cols-1 sm:grid-cols-2 gap-4 mt-4">
                                <div>
                                    <label for="check-in" class="block text-gray-700 dark:text-gray-300"><%= language.equals("vi") ? "Ngày nhận phòng" : "Check-in" %></label>
                                    <input type="date" id="check-in" name="checkIn" value="${param.checkIn}" required class="input-field">
                                </div>
                                <div>
                                    <label for="check-out" class="block text-gray-700 dark:text-gray-300"><%= language.equals("vi") ? "Ngày trả phòng" : "Check-out" %></label>
                                    <input type="date" id="check-out" name="checkOut" value="${param.checkOut}" required class="input-field">
                                </div>
                                <div>
                                    <label for="adults" class="block text-gray-700 dark:text-gray-300"><%= language.equals("vi") ? "Người lớn" : "Adults" %></label>
                                    <select id="adults" name="adults" class="input-field">
                                        <c:forEach begin="1" end="${room.maxAdults}" var="i">
                                            <option value="${i}" ${param.adults == i ? 'selected' : ''}>${i}</option>
                                        </c:forEach>
                                    </select>
                                </div>
                                <div>
                                    <label for="children" class="block text-gray-700 dark:text-gray-300"><%= language.equals("vi") ? "Trẻ em" : "Children" %></label>
                                    <select id="children" name="children" class="input-field">
                                        <c:forEach begin="0" end="${room.maxChildren}" var="i">
                                            <option value="${i}" ${param.children == i ? 'selected' : ''}>${i}</option>
                                        </c:forEach>
                                    </select>
                                </div>
                            </div>
                            <div class="price-summary mt-4">
                                <p><%= language.equals("vi") ? "Tổng cộng" : "Total" %>: <span id="totalPrice" class="text-blue-600 dark:text-blue-400 font-semibold">0 VND</span></p>
                            </div>
                            <button type="submit" class="submit-btn"><%= language.equals("vi") ? "Đặt ngay" : "Book Now" %></button>
                        </form>
                    </div>
                </div>
            </div>
        </section>
    </main>

    <jsp:include page="/WEB-INF/views/partials/footer.jsp" />

    <script>
        function changeMainImage(src) {
            document.getElementById('mainImage').src = src;
        }

        function calculateTotal() {
            const checkIn = new Date(document.getElementById('check-in').value);
            const checkOut = new Date(document.getElementById('check-out').value);
            const pricePerNight = ${room.pricePerNight};
            if (checkIn && checkOut && checkOut > checkIn) {
                const nights = (checkOut - checkIn) / (1000 * 60 * 60 * 24);
                const total = nights * pricePerNight;
                document.getElementById('totalPrice').textContent = total.toLocaleString('vi-VN') + ' VND';
            } else {
                document.getElementById('totalPrice').textContent = '0 VND';
            }
        }

        document.addEventListener('DOMContentLoaded', calculateTotal);
    </script>
</body>
</html>