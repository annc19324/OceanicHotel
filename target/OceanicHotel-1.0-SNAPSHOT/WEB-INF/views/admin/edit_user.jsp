<%--
    Copyright (c) 2025 annc19324
    All rights reserved.

    This code is the property of annc19324.
    Unauthorized copying or distribution is prohibited.
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.mycompany.oceanichotel.models.User" %>
<%@ page import="java.text.SimpleDateFormat" %>
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
    User user = (User) request.getAttribute("user");
    String error = (String) request.getAttribute("error");

    String dobDay = "";
    String dobMonth = "";
    String dobYear = "";
    if (user != null && user.getDateOfBirth() != null) {
        SimpleDateFormat dayFormat = new SimpleDateFormat("dd");
        SimpleDateFormat monthFormat = new SimpleDateFormat("MM");
        SimpleDateFormat yearFormat = new SimpleDateFormat("yyyy");
        dobDay = dayFormat.format(user.getDateOfBirth());
        dobMonth = monthFormat.format(user.getDateOfBirth());
        dobYear = yearFormat.format(user.getDateOfBirth());
    }
%>
<!DOCTYPE html>
<html lang="<%= language%>">
<head>
    <meta charset="UTF-8">
    <title><%= language.equals("vi") ? "Sửa người dùng - Khách sạn Oceanic" : "Edit User - Oceanic Hotel"%></title>
    <link rel="icon" href="<%= request.getContextPath()%>/assets/images/logo.png" type="image/x-icon">
    <link rel="stylesheet" href="<%= request.getContextPath()%>/assets/css/main.css">
    <link rel="stylesheet" href="<%= request.getContextPath()%>/assets/css/form.css">
    <link rel="stylesheet" href="<%= request.getContextPath()%>/assets/css/modal.css">
    <style>
        .date-select-wrapper {
            display: flex;
            gap: 10px;
        }
        .error-input {
            font-size: 12px;
            color: red;
            margin-top: 5px;
            display: none;
            text-align: left;
        }
        .dark-mode .error-input {
            color: #ff6666;
        }
    </style>
</head>
<body class="<%= theme.equals("dark") ? "dark-mode" : ""%>" data-theme="<%= theme%>">
    <div class="admin-container">
        <nav class="sidebar">
            <div class="sidebar-header">
                <a style="color: white; margin-bottom: 20px; font-size: 24px; font-weight: 600; letter-spacing: 0.5px;" href="<%= request.getContextPath()%>/admin/dashboard">Oceanic Hotel</a>
            </div>
            <ul>
                <li><a href="<%= request.getContextPath()%>/admin/dashboard"><%= language.equals("vi") ? "Tổng quan" : "Dashboard"%></a></li>
                <li class="active"><a href="<%= request.getContextPath()%>/admin/users"><%= language.equals("vi") ? "Quản lý người dùng" : "User Management"%></a></li>
                <li><a href="<%= request.getContextPath()%>/admin/room-types"><%= language.equals("vi") ? "Quản lý loại phòng" : "Room Type Management"%></a></li>
                <li><a href="<%= request.getContextPath()%>/admin/rooms"><%= language.equals("vi") ? "Quản lý phòng" : "Room Management"%></a></li>
                <li><a href="<%= request.getContextPath()%>/admin/bookings"><%= language.equals("vi") ? "Quản lý đặt phòng" : "Booking Management"%></a></li>
                <li><a href="<%= request.getContextPath()%>/admin/transactions"><%= language.equals("vi") ? "Quản lý giao dịch" : "Transaction Management"%></a></li>
                <li><a href="<%= request.getContextPath()%>/admin/settings"><%= language.equals("vi") ? "Cấu hình hệ thống" : "System Settings"%></a></li>
                <li><a href="<%= request.getContextPath()%>/admin/reports"><%= language.equals("vi") ? "Báo cáo" : "Reports"%></a></li>
                <li><a href="<%= request.getContextPath()%>/logout"><%= language.equals("vi") ? "Đăng xuất" : "Logout"%></a></li>
            </ul>
        </nav>
        <div class="main-content">
            <form action="<%= request.getContextPath()%>/admin/users/update" method="POST" onsubmit="return validateForm()">
                <input type="hidden" name="userId" value="<%= user.getUserId()%>">
                <div class="form-group">
                    <label for="username"><%= language.equals("vi") ? "Tên người dùng" : "Username"%></label>
                    <input type="text" id="username" name="username" value="<%= user.getUsername()%>" required>
                    <p class="error-input" id="username-error"></p>
                </div>
                <div class="form-group">
                    <label for="full_name"><%= language.equals("vi") ? "Họ và tên" : "Full Name"%></label>
                    <input type="text" id="full_name" name="full_name" value="<%= user.getFullName()%>" required>
                    <p class="error-input" id="full_name-error"></p>
                </div>
                <div class="form-group">
                    <label for="email"><%= language.equals("vi") ? "Email" : "Email"%></label>
                    <input type="email" id="email" name="email" value="<%= user.getEmail()%>" required>
                    <p class="error-input" id="email-error"></p>
                </div>
                <div class="form-group">
                    <label for="password"><%= language.equals("vi") ? "Mật khẩu mới (để trống nếu không đổi)" : "New Password (leave blank if unchanged)"%></label>
                    <input type="password" id="password" name="password">
                    <p class="error-input" id="password-error"></p>
                </div>
                <div class="form-group">
                    <label for="role"><%= language.equals("vi") ? "Vai trò" : "Role"%></label>
                    <select id="role" name="role" required>
                        <option value="admin" <%= user.getRole().equals("admin") ? "selected" : ""%>><%= language.equals("vi") ? "Quản trị viên" : "Admin"%></option>
                        <option value="user" <%= user.getRole().equals("user") ? "selected" : ""%>><%= language.equals("vi") ? "Người dùng" : "User"%></option>
                        <option value="receptionist" <%= user.getRole().equals("receptionist") ? "selected" : ""%>><%= language.equals("vi") ? "Lễ tân" : "Receptionist"%></option>
                    </select>
                </div>
                <div class="form-group">
                    <label for="cccd"><%= language.equals("vi") ? "CCCD" : "ID Card"%></label>
                    <input type="text" id="cccd" name="cccd" value="<%= user.getCccd() != null ? user.getCccd() : ""%>">
                    <p class="error-input" id="cccd-error"></p>
                </div>
                <div class="form-group">
                    <label for="phone_number"><%= language.equals("vi") ? "Số điện thoại" : "Phone Number"%></label>
                    <input type="text" id="phone_number" name="phone_number" value="<%= user.getPhoneNumber() != null ? user.getPhoneNumber() : ""%>">
                    <p class="error-input" id="phone_number-error"></p>
                </div>
                <div class="form-group">
                    <label><%= language.equals("vi") ? "Ngày sinh (bắt buộc)" : "Date of Birth (required)"%></label>
                    <div class="date-select-wrapper" style="width: 50%">
                        <select id="dob_day" name="dob_day" required>
                            <option value=""><%= language.equals("vi") ? "Ngày" : "Day"%></option>
                            <% for (int i = 1; i <= 31; i++) { %>
                            <option value="<%= String.format("%02d", i)%>" <%= dobDay.equals(String.format("%02d", i)) ? "selected" : ""%>><%= String.format("%02d", i)%></option>
                            <% } %>
                        </select>
                        <select id="dob_month" name="dob_month" required>
                            <option value=""><%= language.equals("vi") ? "Tháng" : "Month"%></option>
                            <% for (int i = 1; i <= 12; i++) { %>
                            <option value="<%= String.format("%02d", i)%>" <%= dobMonth.equals(String.format("%02d", i)) ? "selected" : ""%>><%= String.format("%02d", i)%></option>
                            <% } %>
                        </select>
                        <select id="dob_year" name="dob_year" required>
                            <option value=""><%= language.equals("vi") ? "Năm" : "Year"%></option>
                            <% int currentYear = java.time.Year.now().getValue(); %>
                            <% for (int i = currentYear - 16; i >= currentYear - 100; i--) { %>
                            <option value="<%= i%>" <%= dobYear.equals(String.valueOf(i)) ? "selected" : ""%>><%= i%></option>
                            <% } %>
                        </select>
                    </div>
                    <p class="error-input" id="date_of_birth-error"></p>
                </div>
                <div class="form-group">
                    <label for="gender"><%= language.equals("vi") ? "Giới tính" : "Gender"%></label>
                    <select id="gender" name="gender">
                        <option value="Other" <%= user.getGender() == null || "Other".equals(user.getGender()) ? "selected" : "" %>><%= language.equals("vi") ? "Khác" : "Other"%></option>
                        <option value="Male" <%= "Male".equals(user.getGender()) ? "selected" : ""%>><%= language.equals("vi") ? "Nam" : "Male"%></option>
                        <option value="Female" <%= "Female".equals(user.getGender()) ? "selected" : ""%>><%= language.equals("vi") ? "Nữ" : "Female"%></option>
                    </select>
                    <p class="error-input" id="gender-error"></p>
                </div>
                <div class="form-group">
                    <label for="is_active"><%= language.equals("vi") ? "Hoạt động" : "Active"%></label>
                    <select id="is_active" name="is_active">
                        <option value="1" <%= user.isActive() ? "selected" : ""%>><%= language.equals("vi") ? "Có" : "Yes"%></option>
                        <option value="0" <%= !user.isActive() ? "selected" : ""%>><%= language.equals("vi") ? "Không" : "No"%></option>
                    </select>
                </div>
                <div class="form-buttons">
                    <button type="submit" class="action-btn add-btn"><%= language.equals("vi") ? "Lưu" : "Save"%></button>
                    <a href="<%= request.getContextPath()%>/admin/users" class="action-btn cancel-btn"><%= language.equals("vi") ? "Hủy" : "Cancel"%></a>
                </div>
            </form>
            <% if (error != null) {%>
            <div class="custom-modal" id="errorModal" style="display: flex;">
                <div class="modal-content animate-modal">
                    <h3><%= language.equals("vi") ? "Lỗi" : "Error"%></h3>
                    <p><%= error%></p>
                    <div class="modal-buttons">
                        <button class="modal-btn cancel-btn" onclick="document.getElementById('errorModal').style.display = 'none'">
                            <%= language.equals("vi") ? "Đóng" : "Close"%>
                        </button>
                    </div>
                </div>
            </div>
            <% }%>
        </div>
    </div>
    <script>
        window.onload = function () {
            document.querySelectorAll(".error-input").forEach(e => e.style.display = "none");
            validateDateOfBirth(); // Kiểm tra ngay khi tải trang
        };

        function validateDateOfBirth() {
            const day = document.getElementById("dob_day").value;
            const month = document.getElementById("dob_month").value;
            const year = document.getElementById("dob_year").value;
            const errorElement = document.getElementById("date_of_birth-error");
            const language = '<%= language%>';

            if (!day || !month || !year) {
                errorElement.style.display = "block";
                errorElement.textContent = language === "vi" ? "Vui lòng chọn đầy đủ ngày, tháng, năm!" : "Please select full day, month, and year!";
                return false;
            }

            const dobDate = new Date(year, month - 1, day);
            if (isNaN(dobDate.getTime()) || dobDate.getDate() != parseInt(day)) {
                errorElement.style.display = "block";
                errorElement.textContent = language === "vi" ? "Ngày sinh không hợp lệ (ví dụ: 31/02)!" : "Invalid date of birth (e.g., 31/02)!";
                return false;
            }

            const now = new Date();
            const ageDiffMs = now - dobDate;
            const ageDate = new Date(ageDiffMs);
            const age = Math.abs(ageDate.getUTCFullYear() - 1970);

            if (dobDate >= now) {
                errorElement.style.display = "block";
                errorElement.textContent = language === "vi" ? "Ngày sinh không thể là hôm nay hoặc tương lai!" : "Date of birth cannot be today or future!";
                return false;
            } else if (age < 16) {
                errorElement.style.display = "block";
                errorElement.textContent = language === "vi" ? "Người dùng phải trên 16 tuổi!" : "User must be over 16 years old!";
                return false;
            }

            errorElement.style.display = "none";
            return true;
        }

        function validateUsername() {
            const username = document.getElementById("username").value.trim();
            const errorElement = document.getElementById("username-error");
            const regex = /^[a-zA-Z0-9]{6,}$/;
            const language = '<%= language%>';
            if (!regex.test(username)) {
                errorElement.style.display = "block";
                errorElement.textContent = language === "vi" ? "Tên người dùng phải ít nhất 6 ký tự, chỉ chứa chữ cái và số!" : "Username must be at least 6 characters, only letters and numbers!";
                return false;
            } else {
                errorElement.style.display = "none";
                return true;
            }
        }

        function validateFullName() {
            const fullName = document.getElementById("full_name").value.trim();
            const errorElement = document.getElementById("full_name-error");
            const language = '<%= language%>';
            if (!fullName) {
                errorElement.style.display = "block";
                errorElement.textContent = language === "vi" ? "Vui lòng nhập họ và tên!" : "Please enter full name!";
                return false;
            } else {
                errorElement.style.display = "none";
                return true;
            }
        }

        function validateEmail() {
            const email = document.getElementById("email").value.trim();
            const errorElement = document.getElementById("email-error");
            const regex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
            const language = '<%= language%>';
            if (!regex.test(email)) {
                errorElement.style.display = "block";
                errorElement.textContent = language === "vi" ? "Email không hợp lệ!" : "Invalid email format!";
                return false;
            } else {
                errorElement.style.display = "none";
                return true;
            }
        }

        function validatePassword() {
            const password = document.getElementById("password").value;
            const errorElement = document.getElementById("password-error");
            const regex = /^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@#$%^&+=!]).{8,}$/;
            const language = '<%= language%>';
            if (password && !regex.test(password)) {
                errorElement.style.display = "block";
                errorElement.textContent = language === "vi" ? "Mật khẩu phải có ít nhất 8 ký tự, bao gồm chữ hoa, chữ thường, số và ký tự đặc biệt!" : "Password must be at least 8 characters with uppercase, lowercase, number, and special character!";
                return false;
            } else {
                errorElement.style.display = "none";
                return true;
            }
        }

        function validateCCCD() {
            const cccd = document.getElementById("cccd").value.trim();
            const errorElement = document.getElementById("cccd-error");
            const regex = /^[0-9]{12}$/;
            const language = '<%= language%>';
            if (cccd && !regex.test(cccd)) {
                errorElement.style.display = "block";
                errorElement.textContent = language === "vi" ? "CCCD phải là 12 chữ số!" : "ID Card must be 12 digits!";
                return false;
            } else {
                errorElement.style.display = "none";
                return true;
            }
        }

        function validatePhoneNumber() {
            const phone = document.getElementById("phone_number").value.trim();
            const errorElement = document.getElementById("phone_number-error");
            const regex = /^[0-9]{10,15}$/;
            const language = '<%= language%>';
            if (phone && !regex.test(phone)) {
                errorElement.style.display = "block";
                errorElement.textContent = language === "vi" ? "Số điện thoại phải từ 10-15 chữ số!" : "Phone number must be 10-15 digits!";
                return false;
            } else {
                errorElement.style.display = "none";
                return true;
            }
        }

        function validateGender() {
            const gender = document.getElementById("gender").value;
            const errorElement = document.getElementById("gender-error");
            const language = '<%= language%>';
            if (!["Male", "Female", "Other"].includes(gender)) {
                errorElement.style.display = "block";
                errorElement.textContent = language === "vi" ? "Giới tính phải là 'Nam', 'Nữ' hoặc 'Khác'!" : "Gender must be 'Male', 'Female', or 'Other'!";
                return false;
            } else {
                errorElement.style.display = "none";
                return true;
            }
        }

        function validateForm() {
            const isDateValid = validateDateOfBirth();
            const isUsernameValid = validateUsername();
            const isFullNameValid = validateFullName();
            const isEmailValid = validateEmail();
            const isPasswordValid = validatePassword();
            const isCccdValid = validateCCCD();
            const isPhoneValid = validatePhoneNumber();
            const isGenderValid = validateGender();

            return isDateValid && isUsernameValid && isFullNameValid && isEmailValid && isPasswordValid &&
                   isCccdValid && isPhoneValid && isGenderValid;
        }

        document.getElementById("username").addEventListener("input", validateUsername);
        document.getElementById("full_name").addEventListener("input", validateFullName);
        document.getElementById("email").addEventListener("input", validateEmail);
        document.getElementById("password").addEventListener("input", validatePassword);
        document.getElementById("cccd").addEventListener("input", validateCCCD);
        document.getElementById("phone_number").addEventListener("input", validatePhoneNumber);
        document.getElementById("dob_day").addEventListener("change", validateDateOfBirth);
        document.getElementById("dob_month").addEventListener("change", validateDateOfBirth);
        document.getElementById("dob_year").addEventListener("change", validateDateOfBirth);
        document.getElementById("gender").addEventListener("change", validateGender);
    </script>
</body>
</html>