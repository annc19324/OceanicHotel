<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ page import="com.mycompany.oceanichotel.models.User" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ page import="java.util.concurrent.TimeUnit" %>
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
        <title><%= "vi".equals(language) ? "Oceanic Hotel - Lịch sử đặt phòng" : "Oceanic Hotel - Booking History" %></title>
        <link rel="icon" href="<%= request.getContextPath() %>/assets/images/logo.png" type="image/x-icon">
        <link href="https://cdn.jsdelivr.net/npm/tailwindcss@2.2.19/dist/tailwind.min.css" rel="stylesheet">
        <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;600;700&display=swap" rel="stylesheet">
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0-beta3/css/all.min.css">
        <style>
            body { font-family: 'Poppins', sans-serif; transition: background 0.3s ease, color 0.3s ease; background: #f0f7fa; color: #1e3a5f; }
            .dark-mode { background: #1e3a5f; color: #e6f0fa; }
            .header-bg { background: #1e3a5f; position: fixed; width: 100%; top: 0; z-index: 10; padding: 1rem 1.5rem; display: flex; justify-content: space-between; align-items: center; box-shadow: 0 2px 4px rgba(0, 51, 102, 0.2); }
            .header-bg a, .header-bg span { color: #fff; text-decoration: none; cursor: pointer; }
            .header-bg a:hover, .header-bg span:hover { color: #a3bffa; }
            .content-section { margin-top: 100px; padding: 15px; background: #fff; border-radius: 8px; box-shadow: 0 2px 4px rgba(0, 51, 102, 0.2); }
            .dark-mode .content-section { background: #2c5282; }
            h1, h2 { font-size: 1.5rem; text-align: center; margin-bottom: 15px; }
            .dark-mode h1, .dark-mode h2 { color: #e6f0fa; }
            table { width: 100%; border-collapse: collapse; }
            th, td { padding: 8px; text-align: left; border-bottom: 1px solid #ccc; }
            .dark-mode th, .dark-mode td { border-bottom: 1px solid #a3bffa; color: #e6f0fa; }
            th { background: #f0f7fa; }
            .dark-mode th { background: #4a6f9c; }
            .btn { background: #2b6cb0; color: #fff; padding: 6px 12px; border: none; border-radius: 4px; cursor: pointer; transition: background 0.2s; }
            .btn:hover { background: #1e4976; }
            .dark-mode .btn { background: #2b6cb0; }
            .dark-mode .btn:hover { background: #1e4976; }
            select, input[type="date"] { width: 100%; padding: 6px; border: 1px solid #ccc; border-radius: 4px; background: #fff; color: #1e3a5f; }
            .dark-mode select, .dark-mode input[type="date"] { background: #4a6f9c; border-color: #a3bffa; color: #e6f0fa; }
            .avatar { width: 48px; height: 48px; border-radius: 50%; object-fit: cover; cursor: pointer; }
            .avatar-container { display: flex; align-items: center; }
            .modal { display: none; position: fixed; top: 0; left: 0; width: 100%; height: 100%; background-color: rgba(0,0,0,0.8); z-index: 1000; }
            .modal-content { position: absolute; top: 50%; left: 50%; transform: translate(-50%, -50%); max-width: 90%; max-height: 90%; }
            .modal-image { width: 300px; height: auto; border-radius: 10px; }
            .payment-modal { position: fixed; top: 0; left: 0; width: 100%; height: 100%; background: rgba(0,0,0,0.8); display: none; justify-content: center; align-items: center; z-index: 50; }
            .modal-box { background: #fff; padding: 20px; border-radius: 8px; max-width: 400px; width: 100%; text-align: center; }
            .dark-mode .modal-box { background: #2c5282; color: #e6f0fa; }
            footer { background: #1e3a5f; color: #fff; padding: 1.5rem; text-align: center; margin-top: 20px; }
        </style>
    </head>
    <body class="<%= "dark".equals(theme) ? "dark-mode" : "" %>">
        <div class="relative min-h-screen">
            <!-- Header -->
            <header class="header-bg">
                <div class="flex items-center space-x-4">
                    <img src="<%= request.getContextPath() %>/assets/images/width_800.jpg" alt="Logo" class="h-10">
                    <a class="font-bold text-lg" href="<%= request.getContextPath() %>/user/dashboard">Oceanic Hotel</a>
                </div>
                <div class="flex items-center space-x-6">
                    <nav class="flex items-center space-x-6">
                        <a href="<%= request.getContextPath() %>/user/profile" class="text-white hover:text-blue-300 transition"><%= "vi".equals(language) ? "Hồ sơ" : "Profile" %></a>
                        <a href="<%= request.getContextPath() %>/user/bookings" class="text-white hover:text-blue-300 transition"><%= "vi".equals(language) ? "Đặt phòng" : "Bookings" %></a>
                        <a href="<%= request.getContextPath() %>/user/change-password"><%= language.equals("vi") ? "Đổi mật khẩu" : "Change Password" %></a>
                        <a href="<%= request.getContextPath() %>/logout" class="text-white hover:text-blue-300 transition"><%= "vi".equals(language) ? "Đăng xuất" : "Logout" %></a>
                        <span id="languageToggle" class="language-toggle text-white" onclick="changeLanguage('<%= "vi".equals(language) ? "en" : "vi" %>')">
                            <i class="fas fa-globe mr-1"></i><%= "vi".equals(language) ? "EN" : "VI" %>
                        </span>
                        <span id="themeToggle" class="theme-toggle text-white" onclick="changeTheme('<%= "dark".equals(theme) ? "light" : "dark" %>')">
                            <i class="fas <%= "dark".equals(theme) ? "fa-sun" : "fa-moon" %>"></i>
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
                <div class="content-section">
                    <h1><%= "vi".equals(language) ? "Lịch sử đặt phòng" : "Booking History" %></h1>
                    <p class="text-center text-lg"><%= "vi".equals(language) ? "Xem lại các đặt phòng của bạn." : "Review your bookings." %></p>

                    <c:if test="${not empty error}">
                        <p class="text-red-600 dark:text-red-400 text-lg text-center mb-4">${error}</p>
                    </c:if>

                    <!-- Filter Section -->
                    <section class="mt-6">
                        <h2><%= "vi".equals(language) ? "Lọc và sắp xếp" : "Filter and Sort" %></h2>
                        <form method="get" action="<%= request.getContextPath() %>/user/bookings" class="grid grid-cols-1 md:grid-cols-5 gap-4">
                            <div>
                                <label class="block"><%= "vi".equals(language) ? "Trạng thái" : "Status" %></label>
                                <select name="statusFilter" class="w-full">
                                    <option value=""><%= "vi".equals(language) ? "Tất cả" : "All" %></option>
                                    <option value="Pending" ${statusFilter == 'Pending' ? 'selected' : ''}><%= "vi".equals(language) ? "Đang chờ" : "Pending" %></option>
                                    <option value="Confirmed" ${statusFilter == 'Confirmed' ? 'selected' : ''}><%= "vi".equals(language) ? "Đã xác nhận" : "Confirmed" %></option>
                                    <option value="Cancelled" ${statusFilter == 'Cancelled' ? 'selected' : ''}><%= "vi".equals(language) ? "Đã hủy" : "Cancelled" %></option>
                                </select>
                            </div>
                            <div>
                                <label class="block"><%= "vi".equals(language) ? "Từ ngày nhận" : "Check-in From" %></label>
                                <input type="date" name="checkInFrom" value="${checkInFrom}">
                            </div>
                            <div>
                                <label class="block"><%= "vi".equals(language) ? "Đến ngày nhận" : "Check-in To" %></label>
                                <input type="date" name="checkInTo" value="${checkInTo}">
                            </div>
                            <div>
                                <label class="block"><%= "vi".equals(language) ? "Sắp xếp" : "Sort" %></label>
                                <select name="sortOption" class="w-full">
                                    <option value="newest" ${sortOption == 'newest' ? 'selected' : ''}><%= "vi".equals(language) ? "Mới nhất" : "Newest" %></option>
                                    <option value="oldest" ${sortOption == 'oldest' ? 'selected' : ''}><%= "vi".equals(language) ? "Cũ nhất" : "Oldest" %></option>
                                    <option value="price_asc" ${sortOption == 'price_asc' ? 'selected' : ''}><%= "vi".equals(language) ? "Giá tăng dần" : "Price Ascending" %></option>
                                    <option value="price_desc" ${sortOption == 'price_desc' ? 'selected' : ''}><%= "vi".equals(language) ? "Giá giảm dần" : "Price Descending" %></option>
                                    <option value="room_asc" ${sortOption == 'room_asc' ? 'selected' : ''}><%= "vi".equals(language) ? "Phòng tăng dần" : "Room Ascending" %></option>
                                    <option value="room_desc" ${sortOption == 'room_desc' ? 'selected' : ''}><%= "vi".equals(language) ? "Phòng giảm dần" : "Room Descending" %></option>
                                </select>
                            </div>
                            <div class="flex items-end">
                                <button type="submit" class="btn w-full"><%= "vi".equals(language) ? "Áp dụng" : "Apply" %></button>
                            </div>
                        </form>
                    </section>

                    <!-- Booking List -->
                    <section class="mt-6">
                        <h2><%= "vi".equals(language) ? "Danh sách đặt phòng" : "Booking List" %></h2>
                        <c:choose>
                            <c:when test="${empty bookings}">
                                <p><%= "vi".equals(language) ? "Bạn chưa có đặt phòng nào." : "You have no bookings yet." %></p>
                            </c:when>
                            <c:otherwise>
                                <table>
                                    <thead>
                                        <tr>
                                            <th><%= "vi".equals(language) ? "Phòng" : "Room" %></th>
                                            <th><%= "vi".equals(language) ? "Ngày nhận phòng" : "Check-in" %></th>
                                            <th><%= "vi".equals(language) ? "Ngày trả phòng" : "Check-out" %></th>
                                            <th><%= "vi".equals(language) ? "Tổng giá" : "Total Price" %></th>
                                            <th><%= "vi".equals(language) ? "Trạng thái" : "Status" %></th>
                                            <th><%= "vi".equals(language) ? "Hành động" : "Action" %></th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                    <c:forEach var="booking" items="${bookings}">
                                        <tr>
                                            <td>${booking.room.roomNumber} - ${booking.room.roomType.typeName}</td>
                                            <td><fmt:formatDate value="${booking.checkInDate}" pattern="dd/MM/yyyy" /></td>
                                            <td><fmt:formatDate value="${booking.checkOutDate}" pattern="dd/MM/yyyy" /></td>
                                            <td><fmt:formatNumber value="${booking.totalPrice}" type="number" pattern="#,###" /> VND</td>
                                            <td>
                                                <span class="${booking.status == 'Pending' ? 'text-yellow-500' : booking.status == 'Confirmed' ? 'text-green-500' : 'text-red-500'}">
                                                    <%= "vi".equals(language) ? 
                                                        ("Pending".equals(((com.mycompany.oceanichotel.models.Booking)pageContext.getAttribute("booking")).getStatus()) ? "Đang chờ" :
                                                         "Confirmed".equals(((com.mycompany.oceanichotel.models.Booking)pageContext.getAttribute("booking")).getStatus()) ? "Đã xác nhận" : "Đã hủy") :
                                                        ((com.mycompany.oceanichotel.models.Booking)pageContext.getAttribute("booking")).getStatus() %>
                                                </span>
                                            </td>
                                            <td>
                                            <c:choose>
                                                <c:when test="${booking.status == 'Pending' && booking.canCancel}">
                                                    <p class="mb-2">
                                                        <%= "vi".equals(language) ? "Thời gian thanh toán còn lại: " : "Remaining payment time: " %>
                                                        <%
                                                            java.util.Date createdAt = ((com.mycompany.oceanichotel.models.Booking)pageContext.getAttribute("booking")).getCreatedAt();
                                                            if (createdAt != null) {
                                                                long diffInMillies = new java.util.Date().getTime() - createdAt.getTime();
                                                                long minutesRemaining = 5 - TimeUnit.MINUTES.convert(diffInMillies, TimeUnit.MILLISECONDS);
                                                                out.print(minutesRemaining > 0 ? minutesRemaining + " minutes" : "Đã hết hạn");
                                                            } else {
                                                                out.print("N/A");
                                                            }
                                                        %>
                                                    </p>
                                                    <form action="<%= request.getContextPath() %>/user/bookings" method="post" onsubmit="return confirm('<%= "vi".equals(language) ? "Bạn có chắc muốn hủy đặt phòng này không?" : "Are you sure you want to cancel this booking?" %>');" style="display:inline;">
                                                        <input type="hidden" name="action" value="cancel">
                                                        <input type="hidden" name="bookingId" value="${booking.bookingId}">
                                                        <button type="submit" class="btn bg-red-500 hover:bg-red-600"><%= "vi".equals(language) ? "Hủy" : "Cancel" %></button>
                                                    </form>
                                                    <button onclick="showPaymentOptions('${booking.bookingId}', '${booking.totalPrice}')" class="btn bg-green-500 hover:bg-green-600">
                                                        <%= "vi".equals(language) ? "Thanh toán" : "Pay Now" %>
                                                    </button>
                                                </c:when>
                                                <c:otherwise>
                                                    <span><%= "vi".equals(language) ? "Không có hành động" : "No actions available" %></span>
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

                    <!-- Status Change History -->
                    <section class="mt-6">
                        <h2><%= "vi".equals(language) ? "Lịch sử thay đổi trạng thái" : "Status Change History" %></h2>
                        <c:choose>
                            <c:when test="${empty history}">
                                <p><%= "vi".equals(language) ? "Chưa có lịch sử thay đổi trạng thái." : "No status change history yet." %></p>
                            </c:when>
                            <c:otherwise>
                                <table>
                                    <thead>
                                        <tr>
                                            <th><%= "vi".equals(language) ? "ID Đặt phòng" : "Booking ID" %></th>
                                            <th><%= "vi".equals(language) ? "Thay đổi bởi" : "Changed By" %></th>
                                            <th><%= "vi".equals(language) ? "Trạng thái cũ" : "Old Status" %></th>
                                            <th><%= "vi".equals(language) ? "Trạng thái mới" : "New Status" %></th>
                                            <th><%= "vi".equals(language) ? "Thời gian thay đổi" : "Changed At" %></th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                    <c:forEach var="history" items="${history}">
                                        <tr>
                                            <td>${history.bookingId}</td>
                                            <td>${history.changedBy}</td>
                                            <td>${history.oldStatus == null ? ("vi".equals(language) ? "Không có" : "N/A") : history.oldStatus}</td>
                                            <td>${history.newStatus}</td>
                                            <td><fmt:formatDate value="${history.changedAt}" pattern="dd/MM/yyyy HH:mm:ss" /></td>
                                        </tr>
                                    </c:forEach>
                                    </tbody>
                                </table>
                            </c:otherwise>
                        </c:choose>
                    </section>
                </div>
            </main>

            <!-- Modal chọn phương thức thanh toán -->
            <div id="paymentModal" class="payment-modal">
                <div class="modal-box">
                    <h3 class="text-xl font-semibold"><%= "vi".equals(language) ? "Chọn phương thức thanh toán" : "Select Payment Method" %></h3>
                    <input type="hidden" id="modalBookingId" value="">
                    <input type="hidden" id="modalTotalPrice" value="">
                    <div class="space-y-4 mt-4">
                        <button onclick="payWithTest()" class="btn bg-yellow-500 hover:bg-yellow-600 w-full">
                            <%= "vi".equals(language) ? "Thanh toán Test (Xác nhận ngay)" : "Pay Test (Confirm Immediately)" %>
                        </button>
                        <button onclick="payWithMoMo()" class="btn bg-pink-500 hover:bg-pink-600 w-full">
                            <%= "vi".equals(language) ? "Thanh toán qua MoMo" : "Pay with MoMo" %>
                        </button>
                    </div>
                    <button onclick="closePaymentModal()" class="mt-4 text-gray-600 dark:text-gray-300 underline">
                        <%= "vi".equals(language) ? "Đóng" : "Close" %>
                    </button>
                </div>
            </div>

            <!-- Footer -->
            <footer>
                <p>© 2025 Oceanic Hotel. <%= "vi".equals(language) ? "Mọi quyền được bảo lưu." : "All rights reserved." %></p>
                <div class="mt-2">
                    <a href="#" class="text-gray-400 hover:text-white mx-2"><i class="fab fa-facebook-f"></i></a>
                    <a href="#" class="text-gray-400 hover:text-white mx-2"><i class="fab fa-instagram"></i></a>
                    <a href="#" class="text-gray-400 hover:text-white mx-2"><i class="fab fa-twitter"></i></a>
                </div>
            </footer>
        </div>

        <script>
            function showModal() {
                const modal = document.getElementById('avatarModal');
                modal.style.display = 'block';
                modal.onclick = function () { modal.style.display = 'none'; }
            }

            function changeLanguage(lang) {
                fetch('<%= request.getContextPath() %>/user/change-language', {
                    method: 'POST',
                    headers: {'Content-Type': 'application/x-www-form-urlencoded'},
                    body: 'language=' + encodeURIComponent(lang)
                }).then(response => {
                    if (response.ok) { location.reload(); }
                    else { console.error('Lỗi khi thay đổi ngôn ngữ: ' + response.status); }
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
                    } else { console.error('Lỗi khi thay đổi chủ đề: ' + response.status); }
                }).catch(error => console.error('Lỗi mạng: ', error));
            }

            function showPaymentOptions(bookingId, totalPrice) {
                document.getElementById('modalBookingId').value = bookingId;
                document.getElementById('modalTotalPrice').value = totalPrice;
                document.getElementById('paymentModal').style.display = 'flex';
            }

            function closePaymentModal() {
                document.getElementById('paymentModal').style.display = 'none';
            }

            function payWithTest() {
                let bookingId = document.getElementById('modalBookingId').value;
                fetch('<%= request.getContextPath() %>/user/bookings', {
                    method: 'POST',
                    headers: {'Content-Type': 'application/x-www-form-urlencoded'},
                    body: 'action=payTest&bookingId=' + encodeURIComponent(bookingId)
                }).then(() => {
                    alert('<%= "vi".equals(language) ? "Thanh toán Test thành công! Giao dịch đã được xác nhận." : "Test payment successful! Transaction has been confirmed." %>');
                    closePaymentModal();
                    location.reload();
                });
            }

            function payWithMoMo() {
                let bookingId = document.getElementById('modalBookingId').value;
                let totalPrice = document.getElementById('modalTotalPrice').value;
                let momoLink = "https://me.momo.vn/0337090061?amount=" + totalPrice + "&note=Thanh%20toan%20booking%20ID%20" + bookingId;
                window.open(momoLink, '_blank');
                fetch('<%= request.getContextPath() %>/user/bookings', {
                    method: 'POST',
                    headers: {'Content-Type': 'application/x-www-form-urlencoded'},
                    body: 'action=confirmMoMo&bookingId=' + encodeURIComponent(bookingId)
                }).then(() => {
                    closePaymentModal();
                    location.reload();
                });
            }
        </script>
    </body>
</html>