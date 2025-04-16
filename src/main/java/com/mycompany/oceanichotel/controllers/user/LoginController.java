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
import com.mycompany.oceanichotel.utils.DatabaseUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;

@WebServlet("/login")
public class LoginController extends HttpServlet {
    private UserService userService;

    @Override
    public void init() throws ServletException {
        userService = new UserService();
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.getRequestDispatcher("/WEB-INF/views/public/login.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String username = req.getParameter("username");
        String password = req.getParameter("password");
        String language = (String) req.getSession().getAttribute("language");
        if (language == null) {
            language = "en"; // Giá trị mặc định nếu session chưa có
        }

        try {
            User user = userService.loginUser(username, password);
            if (user != null) {
                if (!user.isActive()) {
                    req.setAttribute("error", language.equals("vi") ? "Tài khoản của bạn đã bị khóa!" : "Your account is locked!");
                    req.getRequestDispatcher("/WEB-INF/views/public/login.jsp").forward(req, resp);
                    return;
                }

                HttpSession session = req.getSession();
                session.setAttribute("user", user);
                // Lưu language và theme từ User vào session
                session.setAttribute("language", user.getLanguage() != null ? user.getLanguage() : "en");
                session.setAttribute("theme", user.getTheme() != null ? user.getTheme() : "light");

                String ipAddress = req.getRemoteAddr();
                try (Connection conn = DatabaseUtil.getConnection();
                     PreparedStatement stmt = conn.prepareStatement("INSERT INTO Login_History (user_id, ip_address) VALUES (?, ?)")) {
                    stmt.setInt(1, user.getUserId());
                    stmt.setString(2, ipAddress);
                    stmt.executeUpdate();
                } catch (SQLException e) {
                    throw new ServletException("Error logging login history", e);
                }

                switch (user.getRole()) {
                    case "admin":
                        resp.sendRedirect(req.getContextPath() + "/admin/dashboard");
                        break;
                    case "receptionist":
                        resp.sendRedirect(req.getContextPath() + "/receptionist/dashboard");
                        break;
                    case "user":
                    default:
                        resp.sendRedirect(req.getContextPath() + "/user/dashboard");
                        break;
                }
            } else {
                req.setAttribute("error", language.equals("vi") ? "Tên người dùng hoặc mật khẩu không đúng!" : "Invalid username or password!");
                req.getRequestDispatcher("/WEB-INF/views/public/login.jsp").forward(req, resp);
            }
        } catch (SQLException e) {
            throw new ServletException("Database error during login", e);
        }
    }
}