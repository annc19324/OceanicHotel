<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.mycompany.oceanichotel.models.User" %>
<%@ page import="com.mycompany.oceanichotel.models.Booking" %>
<%@ page import="com.mycompany.oceanichotel.service.UserDashboardService" %>
<%@ page import="java.util.List" %>
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
    User user = (User) session.getAttribute("user");
    if (user == null) {
        response.sendRedirect(request.getContextPath() + "/views/public/login.jsp");
        return;
    }
    UserDashboardService service = new UserDashboardService();
    List<Booking> bookings = service.getUserBookings(user.getUserId());
%>
<!DOCTYPE html>
<html lang="<%= language %>">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><%= language.equals("vi") ? "Bảng điều khiển Người dùng - Khách sạn Oceanic" : "User Dashboard - Oceanic Hotel" %></title>
    <link rel="icon" href="<%= request.getContextPath() %>/assets/images/logo.png" type="image/x-icon">
    <link rel="stylesheet" href="<%= request.getContextPath() %>/assets/css/main.css">
    <link rel="stylesheet" href="<%= request.getContextPath() %>/assets/css/table.css">
    <link rel="stylesheet" href="<%= request.getContextPath() %>/assets/css/button.css">
    <link rel="stylesheet" href="<%= request.getContextPath() %>/assets/css/settings.css">
    <script>
        window.contextPath = '<%= request.getContextPath() %>';
    </script>
    <script type="module" src="<%= request.getContextPath() %>/assets/js/main.js" defer></script>
    <script type="module" src="<%= request.getContextPath() %>/assets/js/language.js" defer></script>
    <script type="module" src="<%= request.getContextPath() %>/assets/js/theme.js" defer></script>
</head>
<body class="<%= theme.equals("dark") ? "dark-mode" : "" %>" data-theme="<%= theme %>">
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
    <div class="dashboard">
        <h2><%= language.equals("vi") ? "Bảng điều khiển Người dùng" : "User Dashboard" %></h2>
        <div class="user-info">
            <p><%= language.equals("vi") ? "Xin chào" : "Hello" %>, <%= user.getUsername() %>!</p>
            <p><strong><%= language.equals("vi") ? "Email:" : "Email:" %></strong> <%= user.getEmail() %></p>
            <p><%= language.equals("vi") ? "Chào mừng đến với bảng điều khiển của bạn." : "Welcome to your dashboard." %></p>
            <a href="<%= request.getContextPath() %>/views/public/update_profile.jsp" class="btn btn-secondary">
                <%= language.equals("vi") ? "Cập nhật thông tin" : "Update Profile" %>
            </a>
            <a href="<%= request.getContextPath() %>/logout" class="btn btn-danger">
                <%= language.equals("vi") ? "Đăng xuất" : "Logout" %>
            </a>
        </div>

        <h3><%= language.equals("vi") ? "Danh sách đặt phòng của bạn" : "Your Bookings" %></h3>
        <table class="table">
            <thead>
                <tr>
                    <th><%= language.equals("vi") ? "Mã đặt phòng" : "Booking ID" %></th>
                    <th><%= language.equals("vi") ? "Phòng" : "Room" %></th>
                    <th><%= language.equals("vi") ? "Ngày nhận" : "Check-in" %></th>
                    <th><%= language.equals("vi") ? "Ngày trả" : "Check-out" %></th>
                    <th><%= language.equals("vi") ? "Tổng giá" : "Total Price" %></th>
                    <th><%= language.equals("vi") ? "Trạng thái" : "Status" %></th>
                </tr>
            </thead>
            <tbody>
                <% if (bookings != null && !bookings.isEmpty()) { %>
                    <% for (Booking booking : bookings) { %>
                        <tr>
                            <td><%= booking.getBookingId() %></td>
                            <td><%= booking.getRoomId() %></td>
                            <td><%= booking.getCheckInDate() %></td>
                            <td><%= booking.getCheckOutDate() %></td>
                            <td><%= String.format("%.2f", booking.getTotalPrice()) %> VND</td>
                            <td><%= booking.getStatus() %></td>
                        </tr>
                    <% } %>
                <% } else { %>
                    <tr>
                        <td colspan="6" style="text-align: center;">
                            <%= language.equals("vi") ? "Bạn chưa có đặt phòng nào." : "You have no bookings yet." %>
                        </td>
                    </tr>
                <% } %>
            </tbody>
        </table>

        <a href="<%= request.getContextPath() %>/views/public/book_room.jsp" class="btn btn-primary">
            <%= language.equals("vi") ? "Đặt phòng mới" : "Book a Room" %>
        </a>
    </div>
</body>
</html>