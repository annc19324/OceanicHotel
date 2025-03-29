<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Oceanic Hotel - Hồ sơ cá nhân</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/reset.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/variables.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/base.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/button.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/container.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/form.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/settings.css">
</head>
<body>
    <header class="header">
        <!-- Same header as dashboard -->
    </header>

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
                            <li class="active"><a href="${pageContext.request.contextPath}/profile">Thông tin cá nhân</a></li>
                            <li><a href="${pageContext.request.contextPath}/bookings">Lịch sử đặt phòng</a></li>
                            <li><a href="${pageContext.request.contextPath}/profile/password">Đổi mật khẩu</a></li>
                        </ul>
                    </nav>
                </div>
                
                <div class="profile-content">
                    <h1>Thông tin cá nhân</h1>
                    
                    <form action="${pageContext.request.contextPath}/profile/update" method="post" class="profile-form">
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
                            <input type="tel" id="phone" name="phone" value="${user.phone}">
                        </div>
                        
                        <div class="form-group">
                            <label for="address">Địa chỉ</label>
                            <input type="text" id="address" name="address" value="${user.address}">
                        </div>
                        
                        <div class="form-group">
                            <label for="birthday">Ngày sinh</label>
                            <input type="date" id="birthday" name="birthday" value="${user.birthday}">
                        </div>
                        
                        <div class="form-actions">
                            <button type="submit" class="btn btn-primary">Lưu thay đổi</button>
                        </div>
                    </form>
                    
                    <c:if test="${not empty successMessage}">
                        <div class="notification success">
                            ${successMessage}
                        </div>
                    </c:if>
                    
                    <c:if test="${not empty errorMessage}">
                        <div class="notification error">
                            ${errorMessage}
                        </div>
                    </c:if>
                </div>
            </div>
        </section>
    </main>

    <footer class="footer">
        <!-- Same footer as dashboard -->
    </footer>
</body>
</html>