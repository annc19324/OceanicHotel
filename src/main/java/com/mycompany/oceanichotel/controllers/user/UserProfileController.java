package com.mycompany.oceanichotel.controllers.user;

import com.mycompany.oceanichotel.models.User;
import com.mycompany.oceanichotel.services.user.UserService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.sql.SQLException;
import java.util.logging.Logger;
import java.util.logging.Level;

@WebServlet("/user/profile")
public class UserProfileController extends HttpServlet {
    private UserService userService;
    private static final Logger LOGGER = Logger.getLogger(UserProfileController.class.getName());

    @Override
    public void init() throws ServletException {
        userService = new UserService();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        User user = (User) request.getSession().getAttribute("user");
        if (user == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }
        request.setAttribute("user", user);
        request.getRequestDispatcher("/WEB-INF/views/user/profile.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        User user = (User) request.getSession().getAttribute("user");
        if (user == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        user.setUsername(request.getParameter("fullName")); // Sửa lại để khớp với JSP
        user.setEmail(request.getParameter("email"));
        user.setAvatar(request.getParameter("avatar"));

        try {
            userService.updateUser(user);
            request.setAttribute("successMessage", "Profile updated successfully.");
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error updating profile", e);
            request.setAttribute("errorMessage", "Unable to update profile.");
        }
        request.setAttribute("user", user);
        request.getRequestDispatcher("/WEB-INF/views/user/profile.jsp").forward(request, response);
    }
}