/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.mycompany.oceanichotel.controllers.user;

/**
 *
 * @author annc1
 */
import com.mycompany.oceanichotel.models.User;
import com.mycompany.oceanichotel.services.user.UserService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.sql.SQLException;
import java.util.logging.Level;
import java.util.logging.Logger;

@WebServlet("/user/change-password")
public class ChangePasswordController extends HttpServlet {

    private UserService userService;
    private static final Logger LOGGER = Logger.getLogger(ChangePasswordController.class.getName());

    @Override
    public void init() throws ServletException {
        userService = new UserService();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }
        request.getRequestDispatcher("/WEB-INF/views/user/change_password.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        User user = (User) session.getAttribute("user");
        String language = (String) session.getAttribute("language");
        if (language == null) {
            language = "en";
        }

        String currentPassword = request.getParameter("currentPassword");
        String newPassword = request.getParameter("newPassword");
        String confirmPassword = request.getParameter("confirmPassword");

        try {
            if (!newPassword.equals(confirmPassword)) {
                request.setAttribute("message", language.equals("vi") ? "Mật khẩu mới và xác nhận không khớp!" : "New password and confirmation do not match!");
                request.setAttribute("error", true);
            } else {
                userService.changePassword(user.getUserId(), currentPassword, newPassword, language);
                request.setAttribute("message", language.equals("vi") ? "Đổi mật khẩu thành công!" : "Password changed successfully!");
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error changing password for user {0}", String.valueOf(user.getUserId()));
            LOGGER.log(Level.SEVERE, "Exception details: ", e);
            request.setAttribute("message", e.getMessage());
            request.setAttribute("error", true);
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Unexpected error changing password", e);
            request.setAttribute("message", language.equals("vi") ? "Lỗi không xác định khi đổi mật khẩu!" : "Unknown error changing password!");
            request.setAttribute("error", true);
        }
        request.getRequestDispatcher("/WEB-INF/views/user/change_password.jsp").forward(request, response);
    }
}
