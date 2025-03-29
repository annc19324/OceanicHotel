<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Oceanic Hotel - Danh sách phòng</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/reset.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/variables.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/base.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/button.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/container.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/table.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/form.css">
</head>
<body>
    <header class="header">
        <!-- Same header as dashboard -->
    </header>

    <main class="main">
        <section class="room-list">
            <div class="container">
                <div class="section-header">
                    <h1>Danh sách phòng trống</h1>
                    <div class="filters">
                        <form method="get" action="${pageContext.request.contextPath}/rooms">
                            <input type="hidden" name="checkIn" value="${param.checkIn}">
                            <input type="hidden" name="checkOut" value="${param.checkOut}">
                            <input type="hidden" name="adults" value="${param.adults}">
                            <input type="hidden" name="children" value="${param.children}">
                            
                            <div class="form-group">
                                <label for="type">Loại phòng</label>
                                <select id="type" name="type" onchange="this.form.submit()">
                                    <option value="">Tất cả</option>
                                    <option value="single" ${param.type == 'single' ? 'selected' : ''}>Phòng Đơn</option>
                                    <option value="double" ${param.type == 'double' ? 'selected' : ''}>Phòng Đôi</option>
                                    <option value="deluxe" ${param.type == 'deluxe' ? 'selected' : ''}>Phòng Deluxe</option>
                                    <option value="suite" ${param.type == 'suite' ? 'selected' : ''}>Phòng Suite</option>
                                </select>
                            </div>
                            
                            <div class="form-group">
                                <label for="price">Mức giá</label>
                                <select id="price" name="price" onchange="this.form.submit()">
                                    <option value="">Tất cả</option>
                                    <option value="0-500" ${param.price == '0-500' ? 'selected' : ''}>Dưới 500,000 VND</option>
                                    <option value="500-1000" ${param.price == '500-1000' ? 'selected' : ''}>500,000 - 1,000,000 VND</option>
                                    <option value="1000-1500" ${param.price == '1000-1500' ? 'selected' : ''}>1,000,000 - 1,500,000 VND</option>
                                    <option value="1500" ${param.price == '1500' ? 'selected' : ''}>Trên 1,500,000 VND</option>
                                </select>
                            </div>
                        </form>
                    </div>
                </div>
                
                <div class="rooms-grid">
                    <c:forEach var="room" items="${rooms}">
                        <div class="room-card">
                            <div class="room-image">
                                <img src="${pageContext.request.contextPath}/assets/images/${room.mainImage}" alt="${room.type} Room">
                            </div>
                            <div class="room-info">
                                <h3>Phòng ${room.number} - ${room.typeName}</h3>
                                <p class="price">${room.pricePerNight} VND/đêm</p>
                                <p class="capacity">Tối đa: ${room.maxAdults} người lớn, ${room.maxChildren} trẻ em</p>
                                <p class="amenities">
                                    <span>WiFi miễn phí</span>
                                    <span>Điều hòa</span>
                                    <span>TV</span>
                                </p>
                                <a href="${pageContext.request.contextPath}/rooms/${room.id}" class="btn btn-primary">Xem chi tiết</a>
                            </div>
                        </div>
                    </c:forEach>
                </div>
                
                <c:if test="${empty rooms}">
                    <div class="no-results">
                        <p>Không tìm thấy phòng phù hợp với tiêu chí của bạn.</p>
                        <a href="${pageContext.request.contextPath}/rooms" class="btn btn-outline">Xóa bộ lọc</a>
                    </div>
                </c:if>
            </div>
        </section>
    </main>

    <footer class="footer">
        <!-- Same footer as dashboard -->
    </footer>
</body>
</html>