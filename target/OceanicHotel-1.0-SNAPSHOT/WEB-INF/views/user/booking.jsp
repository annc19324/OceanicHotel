<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Oceanic Hotel - Đặt phòng</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/reset.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/variables.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/base.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/button.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/container.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/form.css">
</head>
<body>
    <header class="header">
        <!-- Same header as dashboard -->
    </header>

    <main class="main">
        <section class="booking-process">
            <div class="container">
                <div class="process-steps">
                    <div class="step active">1. Thông tin đặt phòng</div>
                    <div class="step">2. Thanh toán</div>
                    <div class="step">3. Xác nhận</div>
                </div>
                
                <div class="booking-content">
                    <div class="booking-summary">
                        <h2>Thông tin phòng</h2>
                        <div class="room-card">
                            <img src="${pageContext.request.contextPath}/assets/images/${room.mainImage}" alt="${room.typeName} Room">
                            <div class="room-info">
                                <h3>Phòng ${room.number} - ${room.typeName}</h3>
                                <p>Ngày nhận phòng: ${booking.checkInDate}</p>
                                <p>Ngày trả phòng: ${booking.checkOutDate}</p>
                                <p>Số đêm: ${nights}</p>
                                <p>Số người: ${booking.adults} người lớn, ${booking.children} trẻ em</p>
                                <p class="price">Tổng cộng: ${booking.totalPrice} VND</p>
                            </div>
                        </div>
                    </div>
                    
                    <div class="booking-form">
                        <h2>Thông tin khách hàng</h2>
                        <form action="${pageContext.request.contextPath}/payment" method="post">
                            <input type="hidden" name="roomId" value="${room.id}">
                            <input type="hidden" name="checkIn" value="${booking.checkInDate}">
                            <input type="hidden" name="checkOut" value="${booking.checkOutDate}">
                            <input type="hidden" name="adults" value="${booking.adults}">
                            <input type="hidden" name="children" value="${booking.children}">
                            <input type="hidden" name="totalPrice" value="${booking.totalPrice}">
                            
                            <div class="form-group">
                                <label for="fullName">Họ và tên</label>
                                <input type="text" id="fullName" name="fullName" value="${user.fullName}" required>
                            </div>
                            
                            <div class="form-group">
                                <label for="email">Email</label>
                                <input type="email" id="email" name="email" value="${user.email}" required>
                            </div>
                            
                            <div class="form-group">
                                <label for="phone">Số điện thoại</label>
                                <input type="tel" id="phone" name="phone" value="${user.phone}" required>
                            </div>
                            
                            <div class="form-group">
                                <label for="specialRequests">Yêu cầu đặc biệt</label>
                                <textarea id="specialRequests" name="specialRequests" rows="3"></textarea>
                            </div>
                            
                            <div class="form-actions">
                                <a href="${pageContext.request.contextPath}/rooms/${room.id}" class="btn btn-outline">Quay lại</a>
                                <button type="submit" class="btn btn-primary">Tiếp tục thanh toán</button>
                            </div>
                        </form>
                    </div>
                </div>
            </div>
        </section>
    </main>

    <footer class="footer">
        <!-- Same footer as dashboard -->
    </footer>
</body>
</html>