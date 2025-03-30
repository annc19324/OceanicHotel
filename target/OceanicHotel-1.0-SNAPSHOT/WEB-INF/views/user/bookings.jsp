<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html lang="${sessionScope.language}">
<head>
    <meta charset="UTF-8">
    <title>${sessionScope.language == 'vi' ? 'Oceanic Hotel - Lịch sử đặt phòng' : 'Oceanic Hotel - Booking History'}</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/reset.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/variables.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/base.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/button.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/container.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/table.css">
</head>
<body>
    <jsp:include page="/WEB-INF/views/partials/header.jsp" />

    <main class="main">
        <section class="bookings">
            <div class="container">
                <div class="section-header">
                    <h1>${sessionScope.language == 'vi' ? 'Lịch sử đặt phòng' : 'Booking History'}</h1>
                </div>
                
                <div class="bookings-table">
                    <table>
                        <thead>
                            <tr>
                                <th>${sessionScope.language == 'vi' ? 'Mã đặt phòng' : 'Booking ID'}</th>
                                <th>${sessionScope.language == 'vi' ? 'Phòng' : 'Room'}</th>
                                <th>${sessionScope.language == 'vi' ? 'Ngày nhận phòng' : 'Check-in'}</th>
                                <th>${sessionScope.language == 'vi' ? 'Ngày trả phòng' : 'Check-out'}</th>
                                <th>${sessionScope.language == 'vi' ? 'Số đêm' : 'Nights'}</th>
                                <th>${sessionScope.language == 'vi' ? 'Tổng tiền' : 'Total'}</th>
                                <th>${sessionScope.language == 'vi' ? 'Trạng thái' : 'Status'}</th>
                                <th>${sessionScope.language == 'vi' ? 'Hành động' : 'Actions'}</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:forEach var="booking" items="${bookings}">
                                <tr>
                                    <td>#${booking.bookingId}</td>
                                    <td>${booking.room.roomNumber} - ${booking.room.roomType.typeName}</td>
                                    <td>${booking.checkInDate}</td>
                                    <td>${booking.checkOutDate}</td>
                                    <td>${booking.nights}</td>
                                    <td>${booking.totalPrice} VND</td>
                                    <td>
                                        <span class="status ${booking.status.toLowerCase()}">${booking.status}</span>
                                    </td>
                                    <td>
                                        <c:if test="${booking.status == 'CONFIRMED' && booking.canCancel}">
                                            <form action="${pageContext.request.contextPath}/user/bookings/cancel" method="post" class="inline-form">
                                                <input type="hidden" name="bookingId" value="${booking.bookingId}">
                                                <button type="submit" class="btn btn-outline btn-small">${sessionScope.language == 'vi' ? 'Hủy' : 'Cancel'}</button>
                                            </form>
                                        </c:if>
                                        <a href="${pageContext.request.contextPath}/user/bookings/${booking.bookingId}" class="btn btn-outline btn-small">${sessionScope.language == 'vi' ? 'Chi tiết' : 'Details'}</a>
                                    </td>
                                </tr>
                            </c:forEach>
                            
                            <c:if test="${empty bookings}">
                                <tr>
                                    <td colspan="8" class="no-results">${sessionScope.language == 'vi' ? 'Bạn chưa có đặt phòng nào.' : 'You have no bookings yet.'}</td>
                                </tr>
                            </c:if>
                        </tbody>
                    </table>
                </div>
            </div>
        </section>
    </main>

    <jsp:include page="/WEB-INF/views/partials/footer.jsp" />
</body>
</html>