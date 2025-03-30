<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html lang="${sessionScope.language}">
<head>
    <meta charset="UTF-8">
    <title>${sessionScope.language == 'vi' ? 'Oceanic Hotel - Hồ sơ cá nhân' : 'Oceanic Hotel - Profile'}</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/reset.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/variables.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/base.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/button.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/container.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/form.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/settings.css">
</head>
<body>
    <jsp:include page="/WEB-INF/views/partials/header.jsp" />

    <main class="main">
        <section class="profile">
            <div class="container">
                <div class="profile-sidebar">
                    <div class="user-info">
                        <div class="avatar">
                            <img src="${pageContext.request.contextPath}/assets/images/default-avatar.png" alt="User Avatar">
                        </div>
                        <h3>${user.fullName}</h3>
                        <p>${user.email}</p>
                    </div>
                    
                    <nav class="profile-nav">
                        <ul>
                            <li class="active"><a href="${pageContext.request.contextPath}/user/profile">${sessionScope.language == 'vi' ? 'Thông tin cá nhân' : 'Personal Info'}</a></li>
                            <li><a href="${pageContext.request.contextPath}/user/bookings">${sessionScope.language == 'vi' ? 'Lịch sử đặt phòng' : 'Booking History'}</a></li>
                            <li><a href="${pageContext.request.contextPath}/user/profile/password">${sessionScope.language == 'vi' ? 'Đổi mật khẩu' : 'Change Password'}</a></li>
                        </ul>
                    </nav>
                </div>
                
                <div class="profile-content">
                    <h1>${sessionScope.language == 'vi' ? 'Thông tin cá nhân' : 'Personal Information'}</h1>
                    
                    <form action="${pageContext.request.contextPath}/user/profile" method="post" class="profile-form">
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
                            <input type="tel" id="phone" name="phone" value="${user.phone}">
                        </div>
                        
                        <div class="form-group">
                            <label for="address">${sessionScope.language == 'vi' ? 'Địa chỉ' : 'Address'}</label>
                            <input type="text" id="address" name="address" value="${user.address}">
                        </div>
                        
                        <div class="form-group">
                            <label for="birthday">${sessionScope.language == 'vi' ? 'Ngày sinh' : 'Birthday'}</label>
                            <input type="date" id="birthday" name="birthday" value="${user.birthday}">
                        </div>
                        
                        <div class="form-actions">
                            <button type="submit" class="btn btn-primary">${sessionScope.language == 'vi' ? 'Lưu thay đổi' : 'Save Changes'}</button>
                        </div>
                    </form>
                    
                    <c:if test="${not empty successMessage}">
                        <div class="notification success">${successMessage}</div>
                    </c:if>
                    <c:if test="${not empty errorMessage}">
                        <div class="notification error">${errorMessage}</div>
                    </c:if>
                </div>
            </div>
        </section>
    </main>

    <jsp:include page="/WEB-INF/views/partials/footer.jsp" />
</body>
</html>