<%--
    Copyright (c) 2025 annc19324
    All rights reserved.

    This code is the property of annc19324.
    Unauthorized copying or distribution is prohibited.
--%>
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
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title><%= language.equals("vi") ? "Đăng nhập / Đăng ký - Khách sạn Oceanic" : "Login / Register - Oceanic Hotel"%></title>
        <link rel="icon" href="<%= request.getContextPath()%>/assets/images/logo.png" type="image/x-icon">
        <style>
            @import url('https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600;700;800;900&display=swap');

            :root {
                --bg: <%= theme.equals("dark") ? "#0b071d" : "#f0f0f0"%>;
                --color: #1e90ff; /* Màu xanh dương thay cho tím */
                --bg02: <%= theme.equals("dark") ? "#0d1a2a" : "#e0f0ff"%>; /* Tông xanh nhạt hơn */
                --text-color: <%= theme.equals("dark") ? "#fff" : "#333"%>;
            }

            * {
                margin: 0;
                padding: 0;
                box-sizing: border-box;
                font-family: 'Poppins', sans-serif;
            }

            body {
                display: flex;
                justify-content: center;
                align-items: center;
                min-height: 100vh;
                background: var(--bg);
            }

            .wrapper {
                position: relative;
                width: 800px;
                height: 500px;
                background: transparent;
                border: 4px solid var(--color);
                box-shadow: 0 0 25px var(--color);
                overflow: hidden;
                border-radius: 20px;
                opacity: 0.9;
                background-image: url('../images/darkbackground.png');

            }

            .wrapper .form-box {
                position: absolute;
                top: 0;
                width: 50%;
                height: 100%;
                display: flex;
                flex-direction: column;
                justify-content: center;
            }

            .wrapper .form-box.login {
                left: 0;
                padding: 0 60px 0 40px;
            }

            .wrapper .form-box.login .animation {
                transform: translateX(0);
                opacity: 1;
                filter: blur(0);
                transition: .7s ease;
                transition-delay: calc(.1s * var(--j));
            }

            .wrapper.active .form-box.login .animation {
                transform: translateX(-120%);
                opacity: 0;
                filter: blur(10px);
                transition-delay: calc(.1s * var(--i));
            }

            .wrapper .form-box.register {
                right: 0;
                padding: 0 40px 0 60px;
                pointer-events: none;
            }

            .wrapper.active .form-box.register {
                pointer-events: auto;
            }

            .wrapper .form-box.register .animation {
                transform: translateX(120%);
                opacity: 0;
                filter: blur(10px);
                transition: .7s ease;
                transition-delay: calc(.1s * var(--j));
            }

            .wrapper.active .form-box.register .animation {
                transform: translateX(0);
                opacity: 1;
                filter: blur(0);
                transition-delay: calc(.1s * var(--i));
            }

            .form-box h2 {
                font-size: 32px;
                color: var(--text-color);
                text-align: center;
            }

            .form-box .input-box {
                position: relative;
                width: 100%;
                height: 50px;
                margin: 25px 0;
            }

            .input-box input {
                width: 100%;
                height: 100%;
                background: transparent;
                border: none;
                outline: none;
                border-bottom: 2px solid var(--text-color);
                padding-left: 28px;
                font-size: 16px;
                color: var(--text-color);
                font-weight: 500;
                transition: .5s;
            }

            .input-box input:focus,
            .input-box input:valid {
                border-bottom-color: var(--color);
            }

            .input-box label {
                position: absolute;
                top: 50%;
                left: 28px;
                transform: translateY(-50%);
                font-size: 16px;
                color: var(--text-color);
                pointer-events: none;
                transition: .5s;
            }

            .input-box input:focus~label,
            .input-box input:valid~label {
                top: -5px;
                color: var(--color);
                left: 0px;
            }

            .input-box i {
                position: absolute;
                top: 55%;
                left: 0;
                transform: translateY(-50%);
                font-size: 18px;
                color: var(--text-color);
                transition: .5s;
            }

            .input-box input:focus~i,
            .input-box input:valid~i {
                color: var(--color);
            }

            .btn {
                position: relative;
                width: 100%;
                height: 45px;
                background: transparent;
                border: 2px solid var(--color);
                outline: none;
                border-radius: 40px;
                cursor: pointer;
                font-size: 16px;
                color: var(--text-color);
                font-weight: 600;
                z-index: 1;
                overflow: hidden;
                margin: 20px 0px 0px 0px;
            }

            .btn::before {
                content: '';
                position: absolute;
                top: -100%;
                left: 0;
                width: 100%;
                height: 300%;
                background: linear-gradient(var(--bg), var(--color), var(--bg), var(--color));
                z-index: -1;
                transition: .5s;
            }

            .btn:hover::before {
                top: 0;
            }

            .form-box .logreg-link {
                font-size: 14.5px;
                color: var(--text-color);
                text-align: center;
                margin: 24px 0 10px;
            }

            .logreg-link p a {
                color: var(--color);
                text-decoration: none;
                font-weight: 600;
            }

            .logreg-link p a:hover {
                text-decoration: underline;
            }

            .wrapper .info-text {
                position: absolute;
                top: 0;
                width: 50%;
                height: 100%;
                display: flex;
                flex-direction: column;
                justify-content: center;
            }

            .wrapper .info-text.login {
                right: 0;
                text-align: right;
                padding: 0px 30px 200px 50px;
            }

            .wrapper .info-text.login .animation {
                transform: translateX(0);
                opacity: 1;
                filter: blur(0);
                transition: .7s ease;
                transition-delay: calc(.1s * var(--j));
            }

            .wrapper.active .info-text.login .animation {
                transform: translateX(120%);
                opacity: 0;
                filter: blur(10px);
                transition-delay: calc(.1s * var(--i));
            }

            .wrapper .info-text.register {
                left: 0;
                text-align: left;
                padding: 0 150px 60px 40px;
                pointer-events: none;
            }

            .wrapper.active .info-text.register {
                pointer-events: auto;
            }

            .wrapper .info-text.register .animation {
                transform: translateX(-120%);
                opacity: 0;
                filter: blur(10px);
                transition: .7s ease;
                transition-delay: calc(.1s * var(--j));
            }

            .wrapper.active .info-text.register .animation {
                transform: translateX(0);
                opacity: 1;
                filter: blur(0);
                transition-delay: calc(.1s * var(--i));
            }

            .info-text h2 {
                font-size: 36px;
                color: var(--text-color);
                line-height: 1.3;
                text-transform: uppercase;
            }

            .info-text p {
                font-size: 16px;
                color: var(--text-color);
            }

            .wrapper .bg-animate {
                position: absolute;
                top: -4px;
                right: 0;
                width: 850px;
                height: 600px;
                background: linear-gradient(45deg, var(--bg02), var(--color));
                border-bottom: 4px solid var(--color);
                transform: rotate(10deg) skewY(40deg);
                transform-origin: bottom right;
                transition: 1.5s ease;
                transition-delay: 1.6s;
            }

            .wrapper.active .bg-animate {
                transition-delay: .5s;
            }

            .wrapper .bg-animate2 {
                position: absolute;
                top: 100%;
                left: 250px;
                width: 940px;
                height: 940px;
                background: var(--bg02);
                border-top: 3px solid var(--color);
                transform: rotate(0) skewY(0);
                transform-origin: bottom left;
                transition: 1.5s ease;
                transition-delay: .5s;
            }

            .wrapper.active .bg-animate2 {
                transform: rotate(-11deg) skewY(-41deg);
                transition-delay: 1.2s;
            }

            @media screen and (max-width: 992px) {
                .wrapper {
                    width: 100%;
                    height: 560px;
                    margin: 20px;
                }
            }

            @media screen and (max-width: 600px) {
                .wrapper {
                    width: 100%;
                    height: 560px;
                    margin: 20px;
                }

                .wrapper .info-text.register,
                .wrapper .info-text.login {
                    display: none;
                }

                .wrapper .form-box.register,
                .wrapper .form-box.login {
                    width: 100%;
                    padding: 24px;
                }
            }
        </style>
    </head>
    <body>
        <div class="wrapper">
            <span class="bg-animate"></span>
            <span class="bg-animate2"></span>

            <!-- Login Form -->
            <div class="form-box login">
                <h2 class="animation" style="--i:0; --j:21;"><%= language.equals("vi") ? "Đăng nhập" : "Login"%></h2>
                <form action="<%= request.getContextPath()%>/login" method="post">
                    <div class="input-box animation" style="--i:1; --j:22;">
                        <input type="text" id="username_log" name="username" required>
                        <label><%= language.equals("vi") ? "Tên người dùng" : "Username"%></label>
                        <i><svg xmlns="http://www.w3.org/2000/svg" width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="lucide lucide-user-round"><circle cx="12" cy="8" r="5"/><path d="M20 21a8 8 0 0 0-16 0"/></svg></i>
                    </div>
                    <div class="input-box animation" style="--i:2; --j:23;">
                        <input type="password" id="password_log" name="password" required autocomplete="current-password">
                        <label><%= language.equals("vi") ? "Mật khẩu" : "Password"%></label>
                        <i><svg xmlns="http://www.w3.org/2000/svg" width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="lucide lucide-lock"><rect width="18" height="11" x="3" y="11" rx="2" ry="2"/><path d="M7 11V7a5 5 0 0 1 10 0v4"/></svg></i>
                    </div>
                    <button type="submit" class="btn animation" style="--i:3; --j:24;"><%= language.equals("vi") ? "Đăng nhập" : "Login"%></button>
                    <div class="logreg-link animation" style="--i:4; --j:25;">
                        <p><%= language.equals("vi") ? "Chưa có tài khoản?" : "Don't have an account?"%> <a href="#" class="register-link"><%= language.equals("vi") ? "Đăng ký" : "Sign Up"%></a></p>
                    </div>
                </form>
                <% if (request.getAttribute("error") != null) {%>
                <p style="color: red; text-align: center;" class="animation" style="--i:5; --j:26;"><%= language.equals("vi") ? "Tên người dùng hoặc mật khẩu không đúng" : request.getAttribute("error")%></p>
                <% }%>
            </div>
            <div class="info-text login">
                <h2 class="animation" style="--i:0; --j:20;"><%= language.equals("vi") ? "Chào mừng trở lại!" : "Welcome Back!"%></h2>
                <p class="animation" style="--i:1; --j:21;"><%= language.equals("vi") ? "Đã là thành viên? Vui lòng đăng nhập." : "Already a Member? Please Login."%></p>
            </div>

            <!-- Register Form -->
            <div class="form-box register">
                <h2 class="animation" style="--i:17; --j:0;"><%= language.equals("vi") ? "Đăng ký" : "Sign Up"%></h2>
                <form action="<%= request.getContextPath()%>/register" method="post">
                    <div class="input-box animation" style="--i:18; --j:1;">
                        <input type="text" id="username_reg" name="username" required>
                        <label><%= language.equals("vi") ? "Tên người dùng" : "Username"%></label>
                        <i><svg xmlns="http://www.w3.org/2000/svg" width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="lucide lucide-user-round"><circle cx="12" cy="8" r="5"/><path d="M20 21a8 8 0 0 0-16 0"/></svg></i>
                    </div>
                    <div class="input-box animation" style="--i:19; --j:2;">
                        <input type="email" id="email_reg" name="email" required>
                        <label>Email</label>
                        <i><svg xmlns="http://www.w3.org/2000/svg" width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="lucide lucide-mail"><rect width="20" height="16" x="2" y="4" rx="2"/><path d="m22 7-8.97 5.7a1.94 1.94 0 0 1-2.06 0L2 7"/></svg></i>
                    </div>
                    <div class="input-box animation" style="--i:20; --j:3;">
                        <input type="password" id="password_reg" name="password" required>
                        <label><%= language.equals("vi") ? "Mật khẩu" : "Password"%></label>
                        <i><svg xmlns="http://www.w3.org/2000/svg" width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="lucide lucide-lock"><rect width="18" height="11" x="3" y="11" rx="2" ry="2"/><path d="M7 11V7a5 5 0 0 1 10 0v4"/></svg></i>
                    </div>
                    <button type="submit" class="btn animation" style="--i:21; --j:4;"><%= language.equals("vi") ? "Đăng ký" : "Sign Up"%></button>
                    <div class="logreg-link animation" style="--i:22; --j:5;">
                        <p><%= language.equals("vi") ? "Đã có tài khoản?" : "Already have an account?"%> <a href="#" class="login-link"><%= language.equals("vi") ? "Đăng nhập" : "Login"%></a></p>
                    </div>
                </form>
                <% if (request.getAttribute("error") != null) {%>
                <p style="color: red; text-align: center;" class="animation" style="--i:23; --j:6;"><%= request.getAttribute("error")%></p>
                <% }%>
            </div>
            <div class="info-text register">
                <h2 class="animation" style="--i:17; --j:0;"><%= language.equals("vi") ? "Chào mừng!" : "Welcome!"%></h2>
                <p class="animation" style="--i:18; --j:1;"><%= language.equals("vi") ? "Tạo tài khoản?" : "Create account?"%></p>
            </div>
        </div>

        <script>
            const wrapper = document.querySelector('.wrapper');
            const registerLink = document.querySelector('.register-link');
            const loginLink = document.querySelector('.login-link');

            registerLink.onclick = (e) => {
                e.preventDefault();
                wrapper.classList.add('active');
            };

            loginLink.onclick = (e) => {
                e.preventDefault();
                wrapper.classList.remove('active');
            };
        </script>
    </body>
</html>