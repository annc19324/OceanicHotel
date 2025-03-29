<%@page import="com.mycompany.oceanichotel.models.RoomTypeImage"%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List" %>
<%@ page import="com.mycompany.oceanichotel.models.User" %>
<%@ page import="com.mycompany.oceanichotel.models.RoomType" %>
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
    User currentUser = (User) session.getAttribute("user");
    List<RoomType> roomTypes = (List<RoomType>) request.getAttribute("roomTypes");
%>
<!DOCTYPE html>
<html lang="<%= language %>">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><%= language.equals("vi") ? "Trang chủ - Khách sạn Oceanic" : "Home - Oceanic Hotel" %></title>
    <link rel="icon" href="<%= request.getContextPath() %>/assets/images/logo.png" type="image/x-icon">
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;600&display=swap" rel="stylesheet">
    <style>
        body {
            font-family: 'Poppins', sans-serif;
            margin: 0;
            padding: 0;
            background: #f4f7f9;
            color: #333;
            transition: background 0.3s ease, color 0.3s ease;
        }
        .container {
            max-width: 1300px;
            margin: 0 auto;
            padding: 20px;
        }
        .header {
            background: url('<%= request.getContextPath() %>/assets/images/hotel-bg.jpg') no-repeat center;
            background-size: cover;
            height: 400px;
            color: white;
            text-align: center;
            padding: 100px 20px;
            position: relative;
            border-radius: 15px;
            box-shadow: 0 4px 20px rgba(0, 0, 0, 0.1);
            margin-bottom: 40px;
        }
        .header::before {
            content: '';
            position: absolute;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background: rgba(0, 0, 0, 0.4);
            border-radius: 15px;
        }
        .header-content {
            position: relative;
            z-index: 1;
        }
        .header h1 {
            font-size: 48px;
            margin: 0;
            text-shadow: 0 2px 10px rgba(0, 0, 0, 0.3);
        }
        .header p {
            font-size: 18px;
            margin: 10px 0 0;
        }
        .nav-bar {
            display: flex;
            justify-content: flex-end;
            padding: 10px 0;
            background: rgba(255, 255, 255, 0.9);
            position: absolute;
            top: 0;
            width: 100%;
        }
        .nav-bar a {
            color: #3498db;
            text-decoration: none;
            margin: 0 20px;
            font-weight: 400;
            transition: color 0.3s ease;
        }
        .nav-bar a:hover {
            color: #2980b9;
        }
        .room-types {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
            gap: 20px;
            margin-bottom: 40px;
        }
        .room-type-card {
            background: white;
            border-radius: 15px;
            overflow: hidden;
            box-shadow: 0 4px 15px rgba(0, 0, 0, 0.1);
            transition: transform 0.3s ease, box-shadow 0.3s ease;
            cursor: pointer;
        }
        .room-type-card:hover {
            transform: translateY(-5px);
            box-shadow: 0 6px 20px rgba(0, 0, 0, 0.15);
        }
        .room-type-card img {
            width: 100%;
            height: 200px;
            object-fit: cover;
        }
        .room-type-card-content {
            padding: 15px;
        }
        .room-type-card h3 {
            margin: 0 0 10px;
            font-size: 20px;
            color: #2c3e50;
        }
        .room-type-card p {
            margin: 0;
            color: #7f8c8d;
            font-size: 14px;
        }
        .offers {
            background: #fff;
            padding: 20px;
            border-radius: 15px;
            box-shadow: 0 4px 15px rgba(0, 0, 0, 0.1);
        }
        .offers h2 {
            font-size: 24px;
            margin: 0 0 20px;
            color: #2c3e50;
        }
        .offer-item {
            margin-bottom: 15px;
            padding: 15px;
            background: #f9f9f9;
            border-radius: 10px;
        }
        .offer-item h4 {
            margin: 0 0 5px;
            color: #3498db;
        }
        .dark-mode {
            background: #2c3e50;
            color: #ecf0f1;
        }
        .dark-mode .header {
            background: url('<%= request.getContextPath() %>/assets/images/hotel-bg-dark.jpg') no-repeat center;
            background-size: cover;
        }
        .dark-mode .room-type-card, .dark-mode .offers {
            background: #34495e;
        }
        .dark-mode .room-type-card h3, .dark-mode .offers h2 {
            color: #ecf0f1;
        }
        .dark-mode .room-type-card p, .dark-mode .offer-item {
            color: #bdc3c7;
        }
        @media (max-width: 600px) {
            .room-types {
                grid-template-columns: 1fr;
            }
            .header h1 {
                font-size: 32px;
            }
        }
    </style>
</head>
<body class="<%= theme.equals("dark") ? "dark-mode" : "" %>">
    <div class="container">
        <div class="header">
            <div class="nav-bar">
                <% if (currentUser != null) { %>
                <a href="<%= request.getContextPath() %>/user/profile"><%= language.equals("vi") ? "Hồ sơ" : "Profile" %></a>
                <a href="<%= request.getContextPath() %>/user/bookings"><%= language.equals("vi") ? "Đặt phòng" : "Bookings" %></a>
                <a href="<%= request.getContextPath() %>/logout"><%= language.equals("vi") ? "Đăng xuất" : "Logout" %></a>
                <% } else { %>
                <a href="<%= request.getContextPath() %>/login"><%= language.equals("vi") ? "Đăng nhập" : "Login" %></a>
                <a href="<%= request.getContextPath() %>/register"><%= language.equals("vi") ? "Đăng ký" : "Register" %></a>
                <% } %>
            </div>
            <div class="header-content">
                <h1><%= language.equals("vi") ? "Chào mừng đến với Khách sạn Oceanic" : "Welcome to Oceanic Hotel" %></h1>
                <p><%= language.equals("vi") ? "Trải nghiệm nghỉ dưỡng đẳng cấp bên bờ biển" : "Experience luxury by the sea" %></p>
            </div>
        </div>

        <section class="room-types">
            <% if (roomTypes != null && !roomTypes.isEmpty()) {
                for (RoomType roomType : roomTypes) {
                    RoomTypeImage primaryImage = roomType.getPrimaryImage();
                    String imageUrl = primaryImage != null ? request.getContextPath() + "/assets/images/room-types/" + primaryImage.getImageUrl() : request.getContextPath() + "/assets/images/default-room.jpg";
            %>
            <div class="room-type-card" onclick="window.location.href='<%= request.getContextPath() %>/rooms?typeId=<%= roomType.getTypeId() %>'">
                <img src="<%= imageUrl %>" alt="<%= roomType.getTypeName() %>">
                <div class="room-type-card-content">
                    <h3><%= roomType.getTypeName() %></h3>
                    <p><%= language.equals("vi") ? "Tối đa " + roomType.getMaxAdults() + " người lớn, " + roomType.getMaxChildren() + " trẻ em" 
                        : "Max " + roomType.getMaxAdults() + " adults, " + roomType.getMaxChildren() + " children" %></p>
                    <p><%= language.equals("vi") ? "Từ " : "From " %> <%= String.format("%.2f", roomType.getDefaultPrice()) %> VND/<%= language.equals("vi") ? "đêm" : "night" %></p>
                </div>
            </div>
            <% }
            } else { %>
            <p><%= language.equals("vi") ? "Không có loại phòng nào để hiển thị." : "No room types available." %></p>
            <% } %>
        </section>

        <section class="offers">
            <h2><%= language.equals("vi") ? "Ưu đãi đặc biệt" : "Special Offers" %></h2>
            <div class="offer-item">
                <h4><%= language.equals("vi") ? "Giảm 20% cho phòng Suite" : "20% Off Suite Rooms" %></h4>
                <p><%= language.equals("vi") ? "Áp dụng từ 01/04 - 10/04/2025" : "Valid from 01/04 - 10/04/2025" %></p>
            </div>
            <div class="offer-item">
                <h4><%= language.equals("vi") ? "Ở 3 đêm, tặng 1 đêm miễn phí" : "Stay 3 Nights, Get 1 Free" %></h4>
                <p><%= language.equals("vi") ? "Dành cho tất cả các loại phòng" : "Applicable to all room types" %></p>
            </div>
        </section>
    </div>

    <script>
        function changeLanguage() {
            const language = document.getElementById('languageSelect')?.value;
            if (language) {
                fetch('<%= request.getContextPath() %>/language', {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
                    body: 'language=' + encodeURIComponent(language)
                }).then(() => location.reload());
            }
        }

        function changeTheme() {
            const theme = document.getElementById('themeSelect')?.value;
            if (theme) {
                fetch('<%= request.getContextPath() %>/theme', {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
                    body: 'theme=' + encodeURIComponent(theme)
                }).then(() => {
                    document.body.className = theme === 'dark' ? 'dark-mode' : '';
                });
            }
        }
    </script>
</body>
</html>