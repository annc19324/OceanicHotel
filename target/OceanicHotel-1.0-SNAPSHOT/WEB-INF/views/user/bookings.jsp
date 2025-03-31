<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ page import="com.mycompany.oceanichotel.models.User" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
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
    <title><%= "vi".equals(language) ? "Oceanic Hotel - Lịch sử đặt phòng" : "Oceanic Hotel - Booking History" %></title>
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
        .btn {
            transition: all 0.3s ease;
        }
        .btn:hover {
            transform: translateY(-2px);
        }
    </style>
</head>
<body class="<%= "dark".equals(theme) ? "dark-mode" : "" %>">
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
                        <a href="<%= request.getContextPath() %>/user/profile" class="text-white hover:text-blue-300 transition"><%= "vi".equals(language) ? "Hồ sơ" : "Profile" %></a>
                        <a href="<%= request.getContextPath() %>/user/bookings" class="text-white hover:text-blue-300 transition"><%= "vi".equals(language) ? "Đặt phòng" : "Bookings" %></a>
                        <a href="<%= request.getContextPath() %>/logout" class="text-white hover:text-blue-300 transition"><%= "vi".equals(language) ? "Đăng xuất" : "Logout" %></a>
                    </c:when>
                    <c:otherwise>
                        <a href="<%= request.getContextPath() %>/login" class="text-white hover:text-blue-300 transition"><%= "vi".equals(language) ? "Đăng nhập" : "Login" %></a>
                        <a href="<%= request.getContextPath() %>/register" class="text-white hover:text-blue-300 transition"><%= "vi".equals(language) ? "Đăng ký" : "Register" %></a>
                    </c:otherwise>
                </c:choose>
                <span class="language-toggle text-white" onclick="changeLanguage('<%= "vi".equals(language) ? "en" : "vi" %>')">
                    <i class="fas fa-globe mr-1"></i><%= "vi".equals(language) ? "EN" : "VI" %>
                </span>
                <span class="theme-toggle text-white" onclick="changeTheme('<%= "dark".equals(theme) ? "light" : "dark" %>')">
                    <i class="fas <%= "dark".equals(theme) ? "fa-sun" : "fa-moon" %>"></i>
                </span>
            </div>
        </nav>
        <div class="relative z-10 flex flex-col items-center justify-center h-full text-center text-white px-4">
            <h1 class="text-4xl md:text-6xl font-bold mb-4 animate-fade-in-down"><%= "vi".equals(language) ? "Lịch sử đặt phòng" : "Booking History" %></h1>
            <p class="text-lg md:text-xl max-w-2xl"><%= "vi".equals(language) ? "Xem lại các đặt phòng của bạn." : "Review your bookings." %></p>
        </div>
    </header>

    <!-- Main Content -->
    <main class="container mx-auto px-4 mt-12">
        <c:if test="${not empty error}">
            <p class="text-red-600 dark:text-red-400 text-lg text-center mb-4">${error}</p>
        </c:if>

        <!-- Filter Section -->
        <section class="bg-white dark:bg-gray-800 rounded-xl shadow-lg p-6 mb-6">
            <h2 class="text-2xl font-semibold text-gray-900 dark:text-white mb-4">
                <%= "vi".equals(language) ? "Lọc và sắp xếp" : "Filter and Sort" %>
            </h2>
            <form method="get" action="<%= request.getContextPath() %>/user/bookings" class="grid grid-cols-1 md:grid-cols-5 gap-4">
                <div>
                    <label class="block text-gray-700 dark:text-gray-300"><%= "vi".equals(language) ? "Trạng thái" : "Status" %></label>
                    <select name="statusFilter" class="w-full p-2 border rounded dark:bg-gray-800 dark:text-white">
                        <option value=""><%= "vi".equals(language) ? "Tất cả" : "All" %></option>
                        <option value="Pending" ${statusFilter == 'Pending' ? 'selected' : ''}>Pending</option>
                        <option value="Confirmed" ${statusFilter == 'Confirmed' ? 'selected' : ''}>Confirmed</option>
                        <option value="Cancelled" ${statusFilter == 'Cancelled' ? 'selected' : ''}>Cancelled</option>
                    </select>
                </div>
                <div>
                    <label class="block text-gray-700 dark:text-gray-300"><%= "vi".equals(language) ? "Từ ngày nhận" : "Check-in From" %></label>
                    <input type="date" name="checkInFrom" value="${checkInFrom}" class="w-full p-2 border rounded dark:bg-gray-800 dark:text-white">
                </div>
                <div>
                    <label class="block text-gray-700 dark:text-gray-300"><%= "vi".equals(language) ? "Đến ngày nhận" : "Check-in To" %></label>
                    <input type="date" name="checkInTo" value="${checkInTo}" class="w-full p-2 border rounded dark:bg-gray-800 dark:text-white">
                </div>
                <div>
                    <label class="block text-gray-700 dark:text-gray-300"><%= "vi".equals(language) ? "Sắp xếp" : "Sort" %></label>
                    <select name="sortOption" class="w-full p-2 border rounded dark:bg-gray-800 dark:text-white">
                        <option value="newest" ${sortOption == 'newest' ? 'selected' : ''}><%= "vi".equals(language) ? "Mới nhất" : "Newest" %></option>
                        <option value="oldest" ${sortOption == 'oldest' ? 'selected' : ''}><%= "vi".equals(language) ? "Cũ nhất" : "Oldest" %></option>
                        <option value="price_asc" ${sortOption == 'price_asc' ? 'selected' : ''}><%= "vi".equals(language) ? "Giá tăng dần" : "Price Ascending" %></option>
                        <option value="price_desc" ${sortOption == 'price_desc' ? 'selected' : ''}><%= "vi".equals(language) ? "Giá giảm dần" : "Price Descending" %></option>
                        <option value="room_asc" ${sortOption == 'room_asc' ? 'selected' : ''}><%= "vi".equals(language) ? "Phòng tăng dần" : "Room Ascending" %></option>
                        <option value="room_desc" ${sortOption == 'room_desc' ? 'selected' : ''}><%= "vi".equals(language) ? "Phòng giảm dần" : "Room Descending" %></option>
                    </select>
                </div>
                <div class="flex items-end">
                    <button type="submit" class="btn bg-blue-500 text-white px-4 py-2 rounded hover:bg-blue-600 w-full">
                        <%= "vi".equals(language) ? "Áp dụng" : "Apply" %>
                    </button>
                </div>
            </form>
        </section>

        <!-- Booking List -->
        <section class="bg-white dark:bg-gray-800 rounded-xl shadow-lg p-6">
            <h2 class="text-2xl font-semibold text-gray-900 dark:text-white mb-4">
                <%= "vi".equals(language) ? "Danh sách đặt phòng" : "Booking List" %>
            </h2>
            <c:choose>
                <c:when test="${empty bookings}">
                    <p class="text-gray-600 dark:text-gray-300"><%= "vi".equals(language) ? "Bạn chưa có đặt phòng nào." : "You have no bookings yet." %></p>
                </c:when>
                <c:otherwise>
                    <table class="w-full text-left">
                        <thead>
                            <tr class="border-b dark:border-gray-700">
                                <th class="py-2 text-gray-900 dark:text-white"><%= "vi".equals(language) ? "Phòng" : "Room" %></th>
                                <th class="py-2 text-gray-900 dark:text-white"><%= "vi".equals(language) ? "Ngày nhận phòng" : "Check-in" %></th>
                                <th class="py-2 text-gray-900 dark:text-white"><%= "vi".equals(language) ? "Ngày trả phòng" : "Check-out" %></th>
                                <th class="py-2 text-gray-900 dark:text-white"><%= "vi".equals(language) ? "Tổng giá" : "Total Price" %></th>
                                <th class="py-2 text-gray-900 dark:text-white"><%= "vi".equals(language) ? "Trạng thái" : "Status" %></th>
                                <th class="py-2 text-gray-900 dark:text-white"><%= "vi".equals(language) ? "Hành động" : "Action" %></th>
                            </tr>
                        </thead>
                        <tbody>
                        <c:forEach var="booking" items="${bookings}">
                            <tr class="border-b dark:border-gray-700">
                                <td class="py-2 text-gray-600 dark:text-gray-300">${booking.room.roomNumber} - ${booking.room.roomType.typeName}</td>
                                <td class="py-2 text-gray-600 dark:text-gray-300"><fmt:formatDate value="${booking.checkInDate}" pattern="dd/MM/yyyy" /></td>
                                <td class="py-2 text-gray-600 dark:text-gray-300"><fmt:formatDate value="${booking.checkOutDate}" pattern="dd/MM/yyyy" /></td>
                                <td class="py-2 text-gray-600 dark:text-gray-300"><fmt:formatNumber value="${booking.totalPrice}" type="number" pattern="#,###" /> VND</td>
                                <td class="py-2">
                                    <span class="${booking.status == 'Pending' ? 'text-yellow-500' : booking.status == 'Confirmed' ? 'text-green-500' : 'text-red-500'}">
                                        <%= "vi".equals(language) ?
                                            ("Pending".equals(((com.mycompany.oceanichotel.models.Booking)pageContext.getAttribute("booking")).getStatus()) ? "Đang chờ" :
                                             "Confirmed".equals(((com.mycompany.oceanichotel.models.Booking)pageContext.getAttribute("booking")).getStatus()) ? "Đã xác nhận" : "Đã hủy") :
                                            ((com.mycompany.oceanichotel.models.Booking)pageContext.getAttribute("booking")).getStatus() %>
                                    </span>
                                </td>
                                <td class="py-2">
                                    <c:choose>
                                        <c:when test="${booking.status == 'Pending' && booking.canCancel}">
                                            <form action="<%= request.getContextPath() %>/user/bookings" method="post" onsubmit="return confirm('<%= "vi".equals(language) ? "Bạn có chắc muốn hủy đặt phòng này không?" : "Are you sure you want to cancel this booking?" %>');" style="display:inline;">
                                                <input type="hidden" name="action" value="cancel">
                                                <input type="hidden" name="bookingId" value="${booking.bookingId}">
                                                <button type="submit" class="btn bg-red-500 text-white px-3 py-1 rounded hover:bg-red-600">
                                                    <%= "vi".equals(language) ? "Hủy" : "Cancel" %>
                                                </button>
                                            </form>
                                            <button onclick="showPaymentOptions('${booking.bookingId}', '${booking.totalPrice}')" class="btn bg-green-500 text-white px-3 py-1 rounded hover:bg-green-600">
                                                <%= "vi".equals(language) ? "Thanh toán" : "Pay Now" %>
                                            </button>
                                        </c:when>
                                        <c:otherwise>
                                            <span class="text-gray-500"><%= "vi".equals(language) ? "Không có hành động" : "No actions available" %></span>
                                        </c:otherwise>
                                    </c:choose>
                                </td>
                            </tr>
                        </c:forEach>
                        </tbody>
                    </table>
                </c:otherwise>
            </c:choose>
        </section>

        <!-- Modal chọn phương thức thanh toán -->
        <div id="paymentModal" class="fixed inset-0 bg-black bg-opacity-50 hidden flex items-center justify-center z-50">
            <div class="bg-white dark:bg-gray-800 rounded-lg p-6 w-full max-w-md">
                <h3 class="text-xl font-semibold text-gray-900 dark:text-white mb-4">
                    <%= "vi".equals(language) ? "Chọn phương thức thanh toán" : "Select Payment Method" %>
                </h3>
                <input type="hidden" id="modalBookingId" value="">
                <input type="hidden" id="modalTotalPrice" value="">
                <div class="space-y-4">
                    <!-- Thanh toán Test -->
                    <button onclick="payTest()" class="btn bg-yellow-500 text-white w-full py-2 rounded hover:bg-yellow-600">
                        <%= "vi".equals(language) ? "Thanh toán Test (Xác nhận ngay)" : "Pay Test (Confirm Immediately)" %>
                    </button>
                    <!-- Thanh toán tại khách sạn -->
                    <button onclick="payAtHotel()" class="btn bg-blue-500 text-white w-full py-2 rounded hover:bg-blue-600">
                        <%= "vi".equals(language) ? "Thanh toán tại khách sạn" : "Pay at Hotel" %>
                    </button>
                    <!-- Thanh toán bằng mã QR -->
                    <button onclick="payWithQR()" class="btn bg-gray-500 text-white w-full py-2 rounded hover:bg-gray-600">
                        <%= "vi".equals(language) ? "Thanh toán bằng mã QR" : "Pay with QR Code" %>
                    </button>
                    <!-- Thanh toán qua MoMo -->
                    <button onclick="payWithMoMo()" class="btn bg-pink-500 text-white w-full py-2 rounded hover:bg-pink-600">
                        <%= "vi".equals(language) ? "Thanh toán qua MoMo" : "Pay with MoMo" %>
                    </button>
                </div>
                <button onclick="closePaymentModal()" class="mt-4 text-gray-600 dark:text-gray-300 underline">
                    <%= "vi".equals(language) ? "Đóng" : "Close" %>
                </button>
            </div>
        </div>

        <!-- Modal hiển thị mã QR -->
        <div id="qrModal" class="fixed inset-0 bg-black bg-opacity-50 hidden flex items-center justify-center z-50">
            <div class="bg-white dark:bg-gray-800 rounded-lg p-6 w-full max-w-md text-center">
                <h3 class="text-xl font-semibold text-gray-900 dark:text-white mb-4">
                    <%= "vi".equals(language) ? "Thanh toán bằng mã QR" : "Pay with QR Code" %>
                </h3>
                <p class="text-gray-600 dark:text-gray-300 mb-4">
                    <%= "vi".equals(language) ? "Số tiền cần thanh toán: " : "Amount to pay: " %>
                    <span id="qrTotalPrice"></span> VND
                </p>
                <img src="<%= request.getContextPath() %>/assets/images/qr.jpg" alt="QR Code" class="mx-auto mb-4 w-48 h-48">
                <p class="text-gray-600 dark:text-gray-300">
                    <%= "vi".equals(language) ? "Thông tin thanh toán: " : "Payment details: " %><br>
                    Booking ID: <span id="qrBookingId"></span><br>
                    <%= "vi".equals(language) ? "Vui lòng quét mã QR và liên hệ Admin để xác nhận sau khi thanh toán." : "Please scan the QR code and contact Admin to confirm after payment." %>
                </p>
                <button onclick="closeQRModal()" class="mt-4 text-gray-600 dark:text-gray-300 underline">
                    <%= "vi".equals(language) ? "Đóng" : "Close" %>
                </button>
            </div>
        </div>

        <!-- Status Change History -->
        <section class="bg-white dark:bg-gray-800 rounded-xl shadow-lg p-6 mt-6">
            <h2 class="text-2xl font-semibold text-gray-900 dark:text-white mb-4">
                <%= "vi".equals(language) ? "Lịch sử thay đổi trạng thái" : "Status Change History" %>
            </h2>
            <c:choose>
                <c:when test="${empty history}">
                    <p class="text-gray-600 dark:text-gray-300"><%= "vi".equals(language) ? "Chưa có lịch sử thay đổi trạng thái." : "No status change history yet." %></p>
                </c:when>
                <c:otherwise>
                    <table class="w-full text-left">
                        <thead>
                            <tr class="border-b dark:border-gray-700">
                                <th class="py-2 text-gray-900 dark:text-white"><%= "vi".equals(language) ? "ID Đặt phòng" : "Booking ID" %></th>
                                <th class="py-2 text-gray-900 dark:text-white"><%= "vi".equals(language) ? "Thay đổi bởi" : "Changed By" %></th>
                                <th class="py-2 text-gray-900 dark:text-white"><%= "vi".equals(language) ? "Trạng thái cũ" : "Old Status" %></th>
                                <th class="py-2 text-gray-900 dark:text-white"><%= "vi".equals(language) ? "Trạng thái mới" : "New Status" %></th>
                                <th class="py-2 text-gray-900 dark:text-white"><%= "vi".equals(language) ? "Thời gian thay đổi" : "Changed At" %></th>
                            </tr>
                        </thead>
                        <tbody>
                        <c:forEach var="history" items="${history}">
                            <tr class="border-b dark:border-gray-700">
                                <td class="py-2 text-gray-600 dark:text-gray-300">${history.bookingId}</td>
                                <td class="py-2 text-gray-600 dark:text-gray-300">${history.changedBy}</td>
                                <td class="py-2 text-gray-600 dark:text-gray-300">${history.oldStatus == null ? ("vi".equals(language) ? "Không có" : "N/A") : history.oldStatus}</td>
                                <td class="py-2 text-gray-600 dark:text-gray-300">${history.newStatus}</td>
                                <td class="py-2 text-gray-600 dark:text-gray-300"><fmt:formatDate value="${history.changedAt}" pattern="dd/MM/yyyy HH:mm:ss" /></td>
                            </tr>
                        </c:forEach>
                        </tbody>
                    </table>
                </c:otherwise>
            </c:choose>
        </section>
    </main>

    <!-- Footer -->
    <footer class="bg-gray-900 dark:bg-gray-800 text-white py-6 mt-12">
        <div class="container mx-auto px-4 text-center">
            <p>© 2025 Oceanic Hotel. <%= "vi".equals(language) ? "Mọi quyền được bảo lưu." : "All rights reserved." %></p>
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
            headers: {'Content-Type': 'application/x-www-form-urlencoded'},
            body: 'language=' + encodeURIComponent(lang)
        }).then(() => location.reload());
    }

    function changeTheme(theme) {
        fetch('<%= request.getContextPath() %>/theme', {
            method: 'POST',
            headers: {'Content-Type': 'application/x-www-form-urlencoded'},
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

    function showPaymentOptions(bookingId, totalPrice) {
        document.getElementById('modalBookingId').value = bookingId;
        document.getElementById('modalTotalPrice').value = totalPrice;
        document.getElementById('paymentModal').classList.remove('hidden');
    }

    function closePaymentModal() {
        document.getElementById('paymentModal').classList.add('hidden');
    }

    function payTest() {
        let bookingId = document.getElementById('modalBookingId').value;
        fetch('<%= request.getContextPath() %>/user/bookings', {
            method: 'POST',
            headers: {'Content-Type': 'application/x-www-form-urlencoded'},
            body: 'action=pay&bookingId=' + encodeURIComponent(bookingId) + '&method=test'
        }).then(() => {
            alert('<%= "vi".equals(language) ? "Thanh toán Test thành công! Đặt phòng đã được xác nhận." : "Test payment successful! Booking has been confirmed." %>');
            closePaymentModal();
            location.reload();
        });
    }

    function payAtHotel() {
//        let bookingId = document.getElementById('modalBookingId').value;
//        fetch('<%= request.getContextPath() %>/user/bookings', {
//            method: 'POST',
//            headers: {'Content-Type': 'application/x-www-form-urlencoded'},
//            body: 'action=pay&bookingId=' + encodeURIComponent(bookingId) + '&method=hotel'
//        }).then(() => {
//            alert('<%= "vi".equals(language) ? "Bạn đã chọn thanh toán tại khách sạn. Vui lòng thanh toán khi nhận phòng và chờ Admin xác nhận." : "You have chosen to pay at the hotel. Please pay upon check-in and wait for Admin confirmation." %>');
            closePaymentModal();
            location.reload();
//        });
    }

    function payWithQR() {
        let bookingId = document.getElementById('modalBookingId').value;
        let totalPrice = document.getElementById('modalTotalPrice').value;
        document.getElementById('qrBookingId').textContent = bookingId;
        document.getElementById('qrTotalPrice').textContent = totalPrice.replace(/\B(?=(\d{3})+(?!\d))/g, ",");
        closePaymentModal();
        document.getElementById('qrModal').classList.remove('hidden');
    }

    function closeQRModal() {
        document.getElementById('qrModal').classList.add('hidden');
    }

    function payWithMoMo() {
        let bookingId = document.getElementById('modalBookingId').value;
        let totalPrice = document.getElementById('modalTotalPrice').value;
        let momoLink = "https://me.momo.vn/YOUR_MOMO_ID?amount=" + totalPrice + "¬e=Thanh%20toan%20booking%20" + bookingId;
        let message = '<%= "vi".equals(language) ? "Vui lòng nhấp vào link để thanh toán qua MoMo:\\n" : "Please click the link to pay via MoMo:\\n" %>'
                    + "Link: <a href='" + momoLink + "' target='_blank'>" + momoLink + "</a><br>"
                    + '<%= "vi".equals(language) ? "Sau khi thanh toán, liên hệ Admin để xác nhận." : "After payment, contact the admin to confirm." %>';
        alert(message);
        closePaymentModal();
    }
</script>
</body>
</html>