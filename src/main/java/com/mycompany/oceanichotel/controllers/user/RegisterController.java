package com.mycompany.oceanichotel.controllers.user;
/*
 * Copyright (c) 2025 annc19324
 * All rights reserved.
 *
 * This code is the property of annc19324.
 * Unauthorized copying or distribution is prohibited.
 */
import com.mycompany.oceanichotel.models.User;
import com.mycompany.oceanichotel.services.user.UserService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.sql.SQLException;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.Calendar;

@WebServlet("/register")
public class RegisterController extends HttpServlet {

    private UserService userService;

    @Override
    public void init() throws ServletException {
        userService = new UserService();
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.getRequestDispatcher("/WEB-INF/views/public/register.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String username = req.getParameter("username");
        String email = req.getParameter("email");
        String password = req.getParameter("password");
        String fullName = req.getParameter("full_name");
        String phoneNumber = req.getParameter("phone_number");
        String cccd = req.getParameter("cccd");
        String gender = req.getParameter("gender");
        String language = (String) req.getSession().getAttribute("language");
        String theme = (String) req.getSession().getAttribute("theme");
        if (language == null) {
            language = "en";
        }
        if (theme == null) {
            theme = "light";
        }
        if (cccd == null || cccd.trim().isEmpty()) {
            req.setAttribute("error", language.equals("vi") ? "Vui lòng nhập CCCD!" : "Please enter ID Card!");
            req.getRequestDispatcher("/WEB-INF/views/public/register.jsp").forward(req, resp);
            return;
        }

        User user = new User(username, password, email, fullName);
        user.setFullName(fullName);
        user.setPhoneNumber(phoneNumber);
        user.setCccd(cccd);
        user.setRole("user");
        user.setTheme(theme);
        user.setAvatar("avatar-default.jpg"); // Already correctly set

        String dobDay = req.getParameter("dob_day");
        String dobMonth = req.getParameter("dob_month");
        String dobYear = req.getParameter("dob_year");

        String dateOfBirthStr;
        if (dobDay != null && dobMonth != null && dobYear != null
                && !dobDay.isEmpty() && !dobMonth.isEmpty() && !dobYear.isEmpty()) {
            dateOfBirthStr = dobYear + "-" + dobMonth + "-" + dobDay;
        } else {
            req.setAttribute("error", language.equals("vi") ? "Vui lòng chọn đầy đủ ngày sinh!" : "Please select full date of birth!");
            req.getRequestDispatcher("/WEB-INF/views/public/register.jsp").forward(req, resp);
            return;
        }

        try {
            SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
            java.util.Date dateOfBirth = sdf.parse(dateOfBirthStr);
            user.setDateOfBirth(dateOfBirth);

            java.util.Date now = new java.util.Date();
            Calendar dobCal = Calendar.getInstance();
            dobCal.setTime(dateOfBirth);
            Calendar nowCal = Calendar.getInstance();
            nowCal.setTime(now);

            int age = nowCal.get(Calendar.YEAR) - dobCal.get(Calendar.YEAR);
            if (nowCal.get(Calendar.DAY_OF_YEAR) < dobCal.get(Calendar.DAY_OF_YEAR)) {
                age--;
            }

            if (dateOfBirth.after(now)) {
                req.setAttribute("error", language.equals("vi") ? "Ngày sinh không thể là ngày trong tương lai!" : "Date of birth cannot be a future date!");
                req.getRequestDispatcher("/WEB-INF/views/public/register.jsp").forward(req, resp);
                return;
            } else if (age < 16) {
                req.setAttribute("error", language.equals("vi") ? "Bạn cần trên 16 tuổi để tạo tài khoản!" : "You need to be over 16 to create an account!");
                req.getRequestDispatcher("/WEB-INF/views/public/register.jsp").forward(req, resp);
                return;
            }
        } catch (ParseException e) {
            req.setAttribute("error", language.equals("vi") ? "Định dạng ngày sinh không hợp lệ!" : "Invalid date of birth format!");
            req.getRequestDispatcher("/WEB-INF/views/public/register.jsp").forward(req, resp);
            return;
        }

        user.setGender(gender);

        try {
            userService.registerUser(user, language);
            resp.sendRedirect(req.getContextPath() + "/login");
        } catch (SQLException e) {
            req.setAttribute("error", e.getMessage());
            req.getRequestDispatcher("/WEB-INF/views/public/register.jsp").forward(req, resp);
        }
    }
}