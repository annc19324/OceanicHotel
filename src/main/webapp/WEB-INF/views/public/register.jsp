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
<html lang="<%= language %>">
<head>
    <meta charset="UTF-8">
    <title><%= language.equals("vi") ? "Đăng ký - Khách sạn Oceanic" : "Register - Oceanic Hotel" %></title>
    <link rel="icon" href="<%= request.getContextPath() %>/assets/images/logo.png" type="image/x-icon">
    <link rel="stylesheet" href="<%= request.getContextPath() %>/assets/css/main.css">
    <script>
        window.contextPath = '<%= request.getContextPath() %>';
    </script>
    <script type="module" src="<%= request.getContextPath() %>/assets/js/main.js" defer></script>
    
    
</head>
<body class="<%= theme.equals("dark") ? "dark-mode" : "" %>" data-theme="<%= theme %>">
    <div class="settings">
        <select id="languageSelect">
            <option value="en" <%= language.equals("en") ? "selected" : "" %>><%= language.equals("vi") ? "Tiếng Anh" : "English" %></option>
            <option value="vi" <%= language.equals("vi") ? "selected" : "" %>><%= language.equals("vi") ? "Tiếng Việt" : "Vietnamese" %></option>
        </select>
        <select id="themeSelect">
            <option value="light" <%= theme.equals("light") ? "selected" : "" %>><%= language.equals("vi") ? "Chế độ sáng" : "Light Mode" %></option>
            <option value="dark" <%= theme.equals("dark") ? "selected" : "" %>><%= language.equals("vi") ? "Chế độ tối" : "Dark Mode" %></option>
        </select>
    </div>
    <div class="container">
        <h2><%= language.equals("vi") ? "Đăng ký" : "Register" %></h2>
        <form action="<%= request.getContextPath() %>/register" method="post">
            <label for="username"><%= language.equals("vi") ? "Tên người dùng:" : "Username:" %></label>
            <input type="text" id="username" name="username" required>
            <label for="email"><%= language.equals("vi") ? "Email:" : "Email:" %></label>
            <input type="email" id="email" name="email" required>
            <label for="password"><%= language.equals("vi") ? "Mật khẩu:" : "Password:" %></label>
            <input type="password" id="password" name="password" required>
            <button type="submit"><%= language.equals("vi") ? "Đăng ký" : "Register" %></button>
        </form>
        <div id="error-message" style="display: none; color: red;"></div>
        <% if (request.getAttribute("error") != null) { %>
            <p style="color: red;"><%= request.getAttribute("error") %></p>
        <% } %>
        <p><%= language.equals("vi") ? "Đã có tài khoản?" : "Already have an account?" %> <a href="<%= request.getContextPath() %>/login"><%= language.equals("vi") ? "Đăng nhập tại đây" : "Login here" %></a></p>
    </div>
</body>
</html>