<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html lang="${sessionScope.language}">
<head>
    <meta charset="UTF-8">
    <title>${sessionScope.language == 'vi' ? 'Oceanic Hotel - Đặt phòng' : 'Oceanic Hotel - Booking'}</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/reset.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/variables.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/base.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/button.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/container.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/form.css">
</head>
<body>
    <jsp:include page="/WEB-INF/views/partials/header.jsp" />

    <main class="main">
        <section class="booking-process">
            <div class="container">
                <div class="process-steps">
                    <div class="step active">1. ${sessionScope.language == 'vi' ? 'Thông tin đặt phòng' : 'Booking Info'}</div>
                    <div class="step">2. ${sessionScope.language == 'vi' ? 'Thanh toán' : 'Payment'}</div>
                    <div class="step">3. ${sessionScope.language == 'vi' ? 'Xác nhận' : 'Confirmation'}</div>
                </div>
                
                <div class="booking-content">
                    <div class="booking-summary">
                        <h2>${sessionScope.language == 'vi' ? 'Thông tin phòng' : 'Room Information'}</h2>
                        <div class="room-card">
                            <img src="${pageContext.request.contextPath}/assets/images/${booking.room.primaryImage.imageUrl}" alt="${booking.room.roomType.typeName} Room">
                            <div class="room-info">
                                <h3>${sessionScope.language == 'vi' ? 'Phòng' : 'Room'} ${booking.room.roomNumber} - ${booking.room.roomType.typeName}</h3>
                                <p>${sessionScope.language == 'vi' ? 'Ngày nhận phòng' : 'Check-in'}: ${booking.checkInDate}</p>
                                <p>${sessionScope.language == 'vi' ? 'Ngày trả phòng' : 'Check-out'}: ${booking.checkOutDate}</p>
                                <p>${sessionScope.language == 'vi' ? 'Số đêm' : 'Nights'}: ${nights}</p>
                                <p>${sessionScope.language == 'vi' ? 'Số người' : 'Guests'}: ${booking.adults} ${sessionScope.language == 'vi' ? 'người lớn' : 'adults'}, ${booking.children} ${sessionScope.language == 'vi' ? 'trẻ em' : 'children'}</p>
                                <p class="price">${sessionScope.language == 'vi' ? 'Tổng cộng' : 'Total'}: ${booking.totalPrice} VND</p>
                            </div>
                        </div>
                    </div>
                    
                    <div class="booking-form">
                        <h2>${sessionScope.language == 'vi' ? 'Thông tin khách hàng' : 'Customer Information'}</h2>
                        <form action="${pageContext.request.contextPath}/user/payment" method="post">
                            <input type="hidden" name="roomId" value="${booking.roomId}">
                            <input type="hidden" name="checkIn" value="${booking.checkInDate}">
                            <input type="hidden" name="checkOut" value="${booking.checkOutDate}">
                            <input type="hidden" name="adults" value="${booking.adults}">
                            <input type="hidden" name="children" value="${booking.children}">
                            <input type="hidden" name="totalPrice" value="${booking.totalPrice}">
                            
                            <div class="form-group">
                                <label for="fullName">${sessionScope.language == 'vi' ? 'Họ và tên' : 'Full Name'}</label>
                                <input type="text" id="fullName" name="fullName" value="${user.fullName}" required>
                            </div>
                            
                            <div class="form-group">
                                <label for="email">Email</label>
                                <input type="email" id="email" name="email" value="${user.email}" required>
                            </div>
                            
                            <div class="form-group">
                                <label for="phone">${sessionScope.language == 'vi' ? 'Số điện thoại' : 'Phone'}</label>
                                <input type="tel" id="phone" name="phone" value="${user.phone}" required>
                            </div>
                            
                            <div class="form-group">
                                <label for="specialRequests">${sessionScope.language == 'vi' ? 'Yêu cầu đặc biệt' : 'Special Requests'}</label>
                                <textarea id="specialRequests" name="specialRequests" rows="3"></textarea>
                            </div>
                            
                            <div class="form-actions">
                                <a href="${pageContext.request.contextPath}/user/room-details/${booking.roomId}" class="btn btn-outline">${sessionScope.language == 'vi' ? 'Quay lại' : 'Back'}</a>
                                <button type="submit" class="btn btn-primary">${sessionScope.language == 'vi' ? 'Tiếp tục thanh toán' : 'Proceed to Payment'}</button>
                            </div>
                        </form>
                    </div>
                </div>
            </div>
        </section>
    </main>

    <jsp:include page="/WEB-INF/views/partials/footer.jsp" />
</body>
</html>