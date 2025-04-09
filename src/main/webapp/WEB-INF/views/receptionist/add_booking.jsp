<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List" %>
<%@ page import="com.mycompany.oceanichotel.models.Room" %>
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
    List<Room> availableRooms = (List<Room>) request.getAttribute("availableRooms");
%>
<!DOCTYPE html>
<html lang="<%= language %>">
<head>
    <meta charset="UTF-8">
    <title><%= language.equals("vi") ? "Thêm đặt phòng tại chỗ - Lễ tân" : "Add Onsite Booking - Receptionist" %></title>
    <link rel="icon" href="<%= request.getContextPath() %>/assets/images/logo.png" type="image/x-icon">
    <link rel="stylesheet" href="<%= request.getContextPath() %>/assets/css/main.css">
    <link rel="stylesheet" href="<%= request.getContextPath() %>/assets/css/sidebar.css">
    <link rel="stylesheet" href="<%= request.getContextPath() %>/assets/css/modal.css">
    <style>
        /* Form styles */
        .booking-form {
            max-width: 500px; /* Giữ kích thước nhỏ */
            margin: 20px 0 20px 20px; /* Dịch sang trái */
            display: flex;
            flex-wrap: wrap;
            gap: 10px; /* Giảm khoảng cách giữa các cột */
        }
        .form-group {
            flex: 1 1 48%; /* Chia 2 cột */
            margin-bottom: 10px; /* Giảm khoảng cách giữa các input */
        }
        .form-group label {
            display: block;
            margin-bottom: 5px;
            font-weight: 500;
            color: var(--text-color);
        }
        .form-group input[type="text"],
        .form-group input[type="email"],
        .form-group input[type="password"],
        .form-group input[type="number"],
        .form-group input[type="file"],
        .form-group input[type="date"],
        .form-group select {
            width: 100%;
            padding: 8px;
            border: 1px solid var(--border-color);
            border-radius: 5px;
            font-size: 14px;
            background-color: var(--container-bg);
            color: var(--text-color);
            transition: border-color 0.3s ease, box-shadow 0.3s ease;
        }
        .form-group input[type="text"]:focus,
        .form-group input[type="email"]:focus,
        .form-group input[type="password"]:focus,
        .form-group input[type="number"]:focus,
        .form-group select:focus {
            border-color: var(--button-bg);
            box-shadow: 0 0 5px rgba(52, 152, 219, 0.3);
            outline: none;
        }
        .form-group input[type="checkbox"] {
            width: 18px; /* Tăng kích thước nút Paid */
            height: 18px;
            margin: 10px 0px;
            vertical-align: middle;
        }
        .form-buttons {
            flex: 1 1 100%; /* Nút chiếm toàn bộ chiều rộng */
            display: flex;
            gap: 10px;
            justify-content: flex-start;
            margin-left: 0px;
        }
        .action-btn {
            padding: 8px 16px;
            margin-left: 0px;
        }
    </style>
</head>
<body class="<%= theme.equals("dark") ? "dark-mode" : "" %>" data-theme="<%= theme %>">
<div class="admin-container">
    <nav class="sidebar">
        <div class="sidebar-header">
            <a style="color: white; margin-bottom: 20px; font-size: 24px; font-weight: 600; letter-spacing: 0.5px;" 
               href="<%= request.getContextPath() %>/receptionist/dashboard">Oceanic Hotel</a>
        </div>
        <ul>
            <li><a href="<%= request.getContextPath() %>/receptionist/dashboard"><%= language.equals("vi") ? "Tổng quan" : "Dashboard" %></a></li>
            <li class="active"><a href="<%= request.getContextPath() %>/receptionist/bookings"><%= language.equals("vi") ? "Quản lý đặt phòng" : "Booking Management" %></a></li>
            <li><a href="<%= request.getContextPath() %>/receptionist/rooms"><%= language.equals("vi") ? "Kiểm tra phòng" : "Room Check" %></a></li>
            <li><a href="<%= request.getContextPath() %>/receptionist/transactions"><%= language.equals("vi") ? "Thanh toán" : "Payments" %></a></li>
            <li><a href="<%= request.getContextPath() %>/logout"><%= language.equals("vi") ? "Đăng xuất" : "Logout" %></a></li>
        </ul>
    </nav>
    <div class="main-content">
        <h2><%= language.equals("vi") ? "Thêm đặt phòng tại chỗ" : "Add Onsite Booking" %></h2>
        <form action="<%= request.getContextPath() %>/receptionist/bookings/add" method="POST" class="booking-form" onsubmit="return validateForm()">
            <div class="form-group">
                <label><%= language.equals("vi") ? "Tên khách hàng" : "Customer Name" %>:</label>
                <input type="text" name="full_name" required>
            </div>
            <div class="form-group">
                <label><%= language.equals("vi") ? "Email" : "Email" %>:</label>
                <input type="email" name="email" required>
            </div>
            <div class="form-group">
                <label><%= language.equals("vi") ? "Số CCCD" : "ID Card" %>:</label>
                <input type="text" name="cccd" pattern="[0-9]{12}" title="<%= language.equals("vi") ? "CCCD phải có 12 chữ số" : "ID Card must be 12 digits" %>" required>
            </div>
            <div class="form-group">
                <label><%= language.equals("vi") ? "Số điện thoại" : "Phone Number" %>:</label>
                <input type="text" name="phone_number" pattern="[0-9]{10}" title="<%= language.equals("vi") ? "Số điện thoại phải có 10 chữ số" : "Phone number must be 10 digits" %>" required>
            </div>
            <div class="form-group">
                <label><%= language.equals("vi") ? "Phòng" : "Room" %>:</label>
                <select name="room_id" id="room_id" onchange="calculateTotalPrice()" required>
                    <option value=""><%= language.equals("vi") ? "Chọn phòng" : "Select Room" %></option>
                    <%
                        if (availableRooms != null) {
                            for (Room room : availableRooms) {
                    %>
                    <option value="<%= room.getRoomId() %>" data-price="<%= room.getPricePerNight() %>">
                        <%= room.getRoomNumber() %> - <%= room.getRoomType().getTypeName() %> (<fmt:formatNumber value="<%= room.getPricePerNight() %>" type="number" minFractionDigits="0" maxFractionDigits="2"/> VND)
                    </option>
                    <%
                            }
                        }
                    %>
                </select>
            </div>
            <div class="form-group">
                <label><%= language.equals("vi") ? "Ngày nhận phòng" : "Check-in Date" %>:</label>
                <input type="date" name="check_in_date" id="check_in_date" onchange="calculateTotalPrice()" required>
            </div>
            <div class="form-group">
                <label><%= language.equals("vi") ? "Ngày trả phòng" : "Check-out Date" %>:</label>
                <input type="date" name="check_out_date" id="check_out_date" onchange="calculateTotalPrice()" required>
            </div>
            <div class="form-group">
                <label><%= language.equals("vi") ? "Số người lớn" : "Number of Adults" %>:</label>
                <input type="number" name="num_adults" min="1" value="1" required>
            </div>
            <div class="form-group">
                <label><%= language.equals("vi") ? "Số trẻ em" : "Number of Children" %>:</label>
                <input type="number" name="num_children" min="0" value="0" required>
            </div>
            <div class="form-group">
                <label><%= language.equals("vi") ? "Tổng tiền cần thanh toán" : "Total Price" %>:</label>
                <input type="text" id="total_price" readonly value="0 VND">
            </div>
            <div class="form-group">
                <label><%= language.equals("vi") ? "Thanh toán" : "Payment" %>:</label>
                <select name="payment_method">
                    <option value="Cash"><%= language.equals("vi") ? "Tiền mặt" : "Cash" %></option>
                    <option value="Card"><%= language.equals("vi") ? "Thẻ" : "Card" %></option>
                </select>
                <input type="checkbox" name="paid" value="true"> <%= language.equals("vi") ? "Đã thanh toán" : "Paid" %>
            </div>
            <div class="form-buttons">
                <button type="submit" class="action-btn add-btn"><%= language.equals("vi") ? "Thêm đặt phòng" : "Add Booking" %></button>
                <button type="button" class="action-btn cancel-btn" onclick="window.location.href='<%= request.getContextPath() %>/receptionist/bookings'">
                    <%= language.equals("vi") ? "Hủy" : "Cancel" %>
                </button>
            </div>
        </form>
    </div>
</div>
<script>
    // Đặt ngày tối thiểu là hôm nay
    const today = new Date().toISOString().split('T')[0];
    document.getElementById('check_in_date').setAttribute('min', today);
    document.getElementById('check_out_date').setAttribute('min', today);

    function calculateTotalPrice() {
        const checkInDate = new Date(document.getElementById('check_in_date').value);
        const checkOutDate = new Date(document.getElementById('check_out_date').value);
        const roomSelect = document.getElementById('room_id');
        const selectedOption = roomSelect.options[roomSelect.selectedIndex];
        const pricePerNight = selectedOption ? parseFloat(selectedOption.getAttribute('data-price')) : 0;

        if (checkInDate && checkOutDate && pricePerNight > 0) {
            const timeDiff = checkOutDate - checkInDate;
            const days = Math.ceil(timeDiff / (1000 * 60 * 60 * 24));
            if (days > 0) {
                const totalPrice = pricePerNight * days;
                document.getElementById('total_price').value = totalPrice.toLocaleString('vi-VN') + ' VND';
            } else {
                document.getElementById('total_price').value = '0 VND';
            }
        } else {
            document.getElementById('total_price').value = '0 VND';
        }
    }

    function validateForm() {
        const checkInDate = new Date(document.getElementById('check_in_date').value);
        const checkOutDate = new Date(document.getElementById('check_out_date').value);
        const today = new Date();
        today.setHours(0, 0, 0, 0);

        if (checkInDate < today) {
            alert('<%= language.equals("vi") ? "Ngày nhận phòng phải từ hôm nay trở đi!" : "Check-in date must be from today onwards!" %>');
            return false;
        }
        if (checkOutDate <= checkInDate) {
            alert('<%= language.equals("vi") ? "Ngày trả phòng phải sau ngày nhận phòng!" : "Check-out date must be after check-in date!" %>');
            return false;
        }
        return true;
    }
</script>
</body>
</html> 