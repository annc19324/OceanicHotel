<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Oceanic Hotel - ${room.typeName} Room</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/reset.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/variables.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/base.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/button.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/container.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/modal.css">
</head>
<body>
    <header class="header">
        <!-- Same header as dashboard -->
    </header>

    <main class="main">
        <section class="room-details">
            <div class="container">
                <div class="room-gallery">
                    <div class="main-image">
                        <img src="${pageContext.request.contextPath}/assets/images/${room.mainImage}" alt="${room.typeName} Room">
                    </div>
                    <div class="thumbnail-images">
                        <c:forEach var="image" items="${room.images}">
                            <img src="${pageContext.request.contextPath}/assets/images/${image}" alt="${room.typeName} Room" onclick="changeMainImage(this.src)">
                        </c:forEach>
                    </div>
                </div>
                
                <div class="room-info">
                    <h1>Phòng ${room.number} - ${room.typeName}</h1>
                    <p class="price">${room.pricePerNight} VND/đêm</p>
                    
                    <div class="room-description">
                        <p>${room.description}</p>
                    </div>
                    
                    <div class="room-features">
                        <h3>Tiện nghi</h3>
                        <ul>
                            <li>Diện tích: ${room.area} m²</li>
                            <li>Giường: ${room.bedType}</li>
                            <li>Tối đa: ${room.maxAdults} người lớn, ${room.maxChildren} trẻ em</li>
                            <li>WiFi miễn phí</li>
                            <li>Điều hòa nhiệt độ</li>
                            <li>TV màn hình phẳng</li>
                            <li>Mini bar</li>
                            <li>Bồn tắm/Vòi sen</li>
                        </ul>
                    </div>
                    
                    <div class="booking-form">
                        <h3>Đặt phòng ngay</h3>
                        <form action="${pageContext.request.contextPath}/booking" method="post">
                            <input type="hidden" name="roomId" value="${room.id}">
                            
                            <div class="form-group">
                                <label for="check-in">Ngày nhận phòng</label>
                                <input type="date" id="check-in" name="checkIn" value="${param.checkIn}" required>
                            </div>
                            
                            <div class="form-group">
                                <label for="check-out">Ngày trả phòng</label>
                                <input type="date" id="check-out" name="checkOut" value="${param.checkOut}" required>
                            </div>
                            
                            <div class="form-group">
                                <label for="adults">Người lớn</label>
                                <select id="adults" name="adults">
                                    <c:forEach begin="1" end="${room.maxAdults}" var="i">
                                        <option value="${i}" ${param.adults == i ? 'selected' : ''}>${i}</option>
                                    </c:forEach>
                                </select>
                            </div>
                            
                            <div class="form-group">
                                <label for="children">Trẻ em</label>
                                <select id="children" name="children">
                                    <c:forEach begin="0" end="${room.maxChildren}" var="i">
                                        <option value="${i}" ${param.children == i ? 'selected' : ''}>${i}</option>
                                    </c:forEach>
                                </select>
                            </div>
                            
                            <div class="price-summary">
                                <p>Tổng cộng cho ${nights} đêm: <span class="total-price">${totalPrice} VND</span></p>
                            </div>
                            
                            <button type="submit" class="btn btn-primary btn-block">Đặt ngay</button>
                        </form>
                    </div>
                </div>
            </div>
        </section>
        
        <section class="similar-rooms">
            <div class="container">
                <h2>Phòng tương tự</h2>
                <div class="rooms-grid">
                    <!-- Similar room cards -->
                </div>
            </div>
        </section>
    </main>

    <footer class="footer">
        <!-- Same footer as dashboard -->
    </footer>

    <script>
        function changeMainImage(src) {
            document.querySelector('.main-image img').src = src;
        }
    </script>
</body>
</html>