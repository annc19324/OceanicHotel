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
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><%= language.equals("vi") ? "Đăng nhập - Khách sạn Oceanic" : "Login - Oceanic Hotel" %></title>
    <link rel="icon" href="<%= request.getContextPath() %>/assets/images/logo.png" type="image/x-icon">
    <link href="https://cdn.jsdelivr.net/npm/tailwindcss@2.2.19/dist/tailwind.min.css" rel="stylesheet">
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0-beta3/css/all.min.css">
    <link rel="stylesheet" href="<%= request.getContextPath() %>/assets/css/auth.css">
    <script>
        window.contextPath = '<%= request.getContextPath() %>';
    </script>
    <script type="module" src="<%= request.getContextPath() %>/assets/js/language.js" defer></script>
    <script type="module" src="<%= request.getContextPath() %>/assets/js/theme.js" defer></script>
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
    <div class="container animate-fade-in">
        <img src="<%= request.getContextPath() %>/assets/images/width_800.jpg" alt="Oceanic Hotel Logo" class="logo">
        <h2><%= language.equals("vi") ? "Đăng nhập" : "Login" %></h2>
        <form action="<%= request.getContextPath() %>/login" method="post">
            <label for="username"><%= language.equals("vi") ? "Tên người dùng:" : "Username:" %></label>
            <input type="text" id="username" name="username" required class="input-field">
            <label for="password"><%= language.equals("vi") ? "Mật khẩu:" : "Password:" %></label>
            <input type="password" id="password" name="password" required autocomplete="current-password" class="input-field">
            <button type="submit" class="submit-btn"><%= language.equals("vi") ? "Đăng nhập" : "Login" %></button>
        </form>
        <% if (request.getAttribute("error") != null) { %>
            <p class="error-message"><%= language.equals("vi") ? "Tên người dùng hoặc mật khẩu không đúng" : request.getAttribute("error") %></p>
        <% } %>
        <p class="link-text"><%= language.equals("vi") ? "Chưa có tài khoản?" : "Don't have an account?" %> <a href="<%= request.getContextPath() %>/register"><%= language.equals("vi") ? "Đăng ký tại đây" : "Register here" %></a></p>
    </div>
</body>
</html>