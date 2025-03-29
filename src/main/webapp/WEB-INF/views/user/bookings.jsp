<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Oceanic Hotel - Lịch sử đặt phòng</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/reset.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/variables.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/base.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/button.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/container.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/table.css">
</head>
<body>
    <header class="header">
        <!-- Same header as dashboard -->
    </header>

    <main class="main">
        <section class="bookings">
            <div class="container">
                <div class="section-header">
                    <h1>Lịch sử đặt phòng</h1>
                </div>
                
                <div class="bookings-table">
                    <table>
                        <thead>
                            <tr>
                                <th>Mã đặt phòng</th>
                                <th>Phòng</th>
                                <th>Ngày nhận phòng</th>
                                <th>Ngày trả phòng</th>
                                <th>Số đêm</th>
                                <th>Tổng tiền</th>
                                <th>Trạng thái</th>
                                <th>Hành động</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:forEach var="booking" items="${bookings}">
                                <tr>
                                    <td>#${booking.id}</td>
                                    <td>${booking.roomNumber} - ${booking.roomType}</td>
                                    <td>${booking.checkInDate}</td>
                                    <td>${booking.checkOutDate}</td>
                                    <td>${booking.nights}</td>
                                    <td>${booking.totalPrice} VND</td>
                                    <td>
                                        <span class="status ${booking.status.toLowerCase()}">${booking.status}</span>
                                    </td>
                                    <td>
                                        <c:if test="${booking.status == 'CONFIRMED' && booking.canCancel}">
                                            <form action="${pageContext.request.contextPath}/bookings/cancel" method="post" class="inline-form">
                                                <input type="hidden" name="bookingId" value="${booking.id}">
                                                <button type="submit" class="btn btn-outline btn-small">Hủy</button>
                                            </form>
                                        </c:if>
                                        <a href="${pageContext.request.contextPath}/bookings/${booking.id}" class="btn btn-outline btn-small">Chi tiết</a>
                                    </td>
                                </tr>
                            </c:forEach>
                            
                            <c:if test="${empty bookings}">
                                <tr>
                                    <td colspan="8" class="no-results">Bạn chưa có đặt phòng nào.</td>
                                </tr>
                            </c:if>
                        </tbody>
                    </table>
                </div>
            </div>
        </section>
    </main>

    <footer class="footer">
        <!-- Same footer as dashboard -->
    </footer>
</body>
</html>