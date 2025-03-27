<%@ page contentType="text/html;charset=UTF-8" language="java" %>
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
%>
<!DOCTYPE html>
<html lang="<%= language%>">
    <head>
        <meta charset="UTF-8">
        <title><%= language.equals("vi") ? "Bảng điều khiển Người dùng - Khách sạn Oceanic" : "User Dashboard - Oceanic Hotel"%></title>
        <link rel="icon" href="<%= request.getContextPath()%>/assets/images/logo.png" type="image/x-icon">
        <link rel="stylesheet" href="<%= request.getContextPath()%>/assets/css/main.css">

        <script>
        window.contextPath = '<%= request.getContextPath()%>';
        </script>
        <script type="module" src="<%= request.getContextPath()%>/assets/js/main.js" defer></script>

    </head>
    <body class="<%= theme.equals("dark") ? "dark-mode" : ""%>" data-theme="<%= theme%>">
        <div class="settings">
            <select id="languageSelect">
                <option value="en" <%= language.equals("en") ? "selected" : ""%>><%= language.equals("vi") ? "Tiếng Anh" : "English"%></option>
                <option value="vi" <%= language.equals("vi") ? "selected" : ""%>><%= language.equals("vi") ? "Tiếng Việt" : "Vietnamese"%></option>
            </select>
            <select id="themeSelect">
                <option value="light" <%= theme.equals("light") ? "selected" : ""%>><%= language.equals("vi") ? "Chế độ sáng" : "Light Mode"%></option>
                <option value="dark" <%= theme.equals("dark") ? "selected" : ""%>><%= language.equals("vi") ? "Chế độ tối" : "Dark Mode"%></option>
            </select>
        </div>
        <div class="dashboard">
            <h2><%= language.equals("vi") ? "Bảng điều khiển Người dùng" : "User Dashboard"%></h2>
            <p><%= language.equals("vi") ? "Xin chào" : "Hello"%>, <%= ((com.mycompany.oceanichotel.models.User) session.getAttribute("user")).getUsername()%>!</p>
            <p><%= language.equals("vi") ? "Chào mừng đến với bảng điều khiển của bạn." : "Welcome to your dashboard."%></p>
            <a href="<%= request.getContextPath()%>/logout"><%= language.equals("vi") ? "Đăng xuất" : "Logout"%></a>
        </div>
    </body>
</html>