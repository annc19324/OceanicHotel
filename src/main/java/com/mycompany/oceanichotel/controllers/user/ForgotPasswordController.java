package com.mycompany.oceanichotel.controllers.user;
/*
 * Copyright (c) 2025 annc19324
 * All rights reserved.
 *
 * This code is the property of annc19324.
 * Unauthorized copying or distribution is prohibited.
 */
import com.mycompany.oceanichotel.services.user.UserService;
import com.mycompany.oceanichotel.utils.EmailUtil;
import jakarta.mail.MessagingException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.security.SecureRandom;
import java.sql.SQLException;
import java.time.LocalDateTime;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

@WebServlet("/forgot-password")
public class ForgotPasswordController extends HttpServlet {

    private static final Logger logger = LoggerFactory.getLogger(ForgotPasswordController.class);
    private UserService userService;
    private static final int TOKEN_LENGTH = 8;
    private static final long TOKEN_EXPIRY_MINUTES = 2;

    @Override
    public void init() throws ServletException {
        userService = new UserService();
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession();
        session.removeAttribute("resetToken");
        session.removeAttribute("resetEmail");
        session.removeAttribute("tokenExpiry");
        req.getRequestDispatcher("/WEB-INF/views/public/forgot_password.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession();
        String language = (String) session.getAttribute("language");
        if (language == null) {
            language = "en";
        }
        String step = req.getParameter("step");

        if (step == null) {
            String email = req.getParameter("email");
            try {
                if (userService.isEmailExists(email)) {
                    String username = userService.getUsernameByEmail(email);
                    logger.info("Email {} exists, associated username: {}", email, username);
                    req.setAttribute("username", username);
                    req.setAttribute("email", email);
                    req.getRequestDispatcher("/WEB-INF/views/public/forgot_password.jsp").forward(req, resp);
                } else {
                    logger.warn("Email {} does not exist", email);
                    req.setAttribute("error", language.equals("vi") ? "Email không tồn tại!" : "Email does not exist!");
                    req.getRequestDispatcher("/WEB-INF/views/public/forgot_password.jsp").forward(req, resp);
                }
            } catch (SQLException e) {
                logger.error("Database error during email check for {}", email, e);
                req.setAttribute("error", language.equals("vi") ? "Lỗi cơ sở dữ liệu: " + e.getMessage() : "Database error: " + e.getMessage());
                req.getRequestDispatcher("/WEB-INF/views/public/forgot_password.jsp").forward(req, resp);
            }
        } else if ("sendCode".equals(step)) {
            String email = req.getParameter("email");
            try {
                if (userService.isEmailExists(email)) {
                    String resetToken = generateResetToken();
                    session.setAttribute("resetToken", resetToken);
                    session.setAttribute("resetEmail", email);
                    LocalDateTime expiry = LocalDateTime.now().plusMinutes(TOKEN_EXPIRY_MINUTES);
                    session.setAttribute("tokenExpiry", expiry);

                    String subject = language.equals("vi") ? "Mã xác nhận đặt lại mật khẩu" : "Password Reset Verification Code";
                    logger.info("Attempting to send reset code to {}: {}", email, resetToken);
                    try {
                        EmailUtil.sendEmail(email, subject, resetToken, language); // Truyền resetToken và language
                        logger.info("Email sent successfully to {}", email);
                        req.setAttribute("success", language.equals("vi") ? "Mã xác nhận đã được gửi đến email của bạn!" : "Verification code has been sent to your email!");
                    } catch (MessagingException e) {
                        logger.error("Failed to send email to {}: {}", email, e.getMessage(), e);
                        req.setAttribute("error", language.equals("vi") ? "Lỗi gửi email: " + e.getMessage() : "Email sending error: " + e.getMessage());
                    }
                    req.getRequestDispatcher("/WEB-INF/views/public/forgot_password.jsp").forward(req, resp);
                } else {
                    logger.warn("Email {} does not exist during sendCode step", email);
                    req.setAttribute("error", language.equals("vi") ? "Email không tồn tại!" : "Email does not exist!");
                    req.getRequestDispatcher("/WEB-INF/views/public/forgot_password.jsp").forward(req, resp);
                }
            } catch (SQLException e) {
                logger.error("Database error during forgot password for {}", email, e);
                req.setAttribute("error", language.equals("vi") ? "Lỗi cơ sở dữ liệu: " + e.getMessage() : "Database error: " + e.getMessage());
                req.getRequestDispatcher("/WEB-INF/views/public/forgot_password.jsp").forward(req, resp);
            }
        } else if ("reset".equals(step)) {
            String code = req.getParameter("code");
            String newPassword = req.getParameter("new_password");
            String resetToken = (String) session.getAttribute("resetToken");
            String email = (String) session.getAttribute("resetEmail");
            LocalDateTime tokenExpiry = (LocalDateTime) session.getAttribute("tokenExpiry");

            if (resetToken == null || email == null || tokenExpiry == null) {
                logger.warn("Invalid reset session: token={}, email={}, expiry={}", resetToken, email, tokenExpiry);
                req.setAttribute("error", language.equals("vi") ? "Phiên đặt lại mật khẩu không hợp lệ!" : "Invalid password reset session!");
                session.removeAttribute("resetToken");
                session.removeAttribute("resetEmail");
                session.removeAttribute("tokenExpiry");
                req.getRequestDispatcher("/WEB-INF/views/public/forgot_password.jsp").forward(req, resp);
                return;
            }

            if (LocalDateTime.now().isAfter(tokenExpiry)) {
                logger.warn("Token expired for email {}: expiry={}", email, tokenExpiry);
                req.setAttribute("error", language.equals("vi") ? "Mã xác nhận đã hết hạn!" : "Verification code has expired!");
                session.removeAttribute("resetToken");
                session.removeAttribute("resetEmail");
                session.removeAttribute("tokenExpiry");
                req.getRequestDispatcher("/WEB-INF/views/public/forgot_password.jsp").forward(req, resp);
                return;
            }

            if (resetToken.equals(code)) {
                try {
                    userService.resetPassword(email, newPassword);
                    logger.info("Password reset successfully for {}", email);
                    session.removeAttribute("resetToken");
                    session.removeAttribute("resetEmail");
                    session.removeAttribute("tokenExpiry");
                    resp.sendRedirect(req.getContextPath() + "/login");
                } catch (SQLException e) {
                    logger.error("Error resetting password for {}", email, e);
                    req.setAttribute("error", language.equals("vi") ? "Lỗi đặt lại mật khẩu: " + e.getMessage() : "Error resetting password: " + e.getMessage());
                    req.getRequestDispatcher("/WEB-INF/views/public/forgot_password.jsp").forward(req, resp);
                }
            } else {
                logger.warn("Invalid verification code for {}: provided={}, expected={}", email, code, resetToken);
                req.setAttribute("error", language.equals("vi") ? "Mã xác nhận không đúng!" : "Invalid verification code!");
                req.getRequestDispatcher("/WEB-INF/views/public/forgot_password.jsp").forward(req, resp);
            }
        }
    }

    private String generateResetToken() {
        String characters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
        SecureRandom random = new SecureRandom();
        StringBuilder token = new StringBuilder(TOKEN_LENGTH);
        for (int i = 0; i < TOKEN_LENGTH; i++) {
            token.append(characters.charAt(random.nextInt(characters.length())));
        }
        return token.toString();
    }
}