package com.mycompany.oceanichotel.controllers.admin;

import com.mycompany.oceanichotel.models.LoginHistory;
import com.mycompany.oceanichotel.models.User;
import com.mycompany.oceanichotel.services.admin.AdminUserService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.sql.SQLException;
import java.util.List;
import java.util.logging.Logger;
import java.util.logging.Level;

@WebServlet("/admin/users/*")
public class AdminUserController extends HttpServlet {

    private AdminUserService userService;
    private static final Logger LOGGER = Logger.getLogger(AdminUserController.class.getName());

    @Override
    public void init() throws ServletException {
        userService = new AdminUserService();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String pathInfo = request.getPathInfo();
        try {
            if (pathInfo == null || pathInfo.equals("/")) {
                int page = request.getParameter("page") != null ? Integer.parseInt(request.getParameter("page")) : 1;
                String search = request.getParameter("search");

                List<User> users = userService.getUsers(page, search);
                int totalUsers = userService.getTotalUsers(search);
                int totalPages = (int) Math.ceil((double) totalUsers / 10);

                request.setAttribute("users", users);
                request.setAttribute("currentPage", page);
                request.setAttribute("totalPages", totalPages);
                request.getRequestDispatcher("/WEB-INF/views/admin/users.jsp").forward(request, response);
            } else if (pathInfo.equals("/add")) {
                request.getRequestDispatcher("/WEB-INF/views/admin/add_user.jsp").forward(request, response);
            } else if (pathInfo.equals("/edit")) {
                int userId = Integer.parseInt(request.getParameter("userId"));
                User user = userService.getUserById(userId);
                if (user != null) {
                    request.setAttribute("user", user);
                    request.getRequestDispatcher("/WEB-INF/views/admin/edit_user.jsp").forward(request, response);
                } else {
                    response.sendRedirect(request.getContextPath() + "/admin/users?error=user_not_found");
                }
            } else if (pathInfo.equals("/login-history")) {
                int userId = Integer.parseInt(request.getParameter("userId"));
                List<LoginHistory> loginHistory = userService.getLoginHistory(userId);
                request.setAttribute("loginHistory", loginHistory);
                request.getRequestDispatcher("/WEB-INF/views/admin/login_history.jsp").forward(request, response);
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Database error in doGet", e);
            throw new ServletException("Database error", e);
        } catch (NumberFormatException e) {
            LOGGER.log(Level.WARNING, "Invalid userId in doGet: " + request.getParameter("userId"), e);
            response.sendRedirect(request.getContextPath() + "/admin/users?error=invalid_user_id");
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String pathInfo = request.getPathInfo();
        try {
            if (pathInfo.equals("/add")) {
                User user = new User();
                user.setUsername(request.getParameter("username"));
                user.setPassword(request.getParameter("password"));
                user.setEmail(request.getParameter("email"));
                user.setRole(request.getParameter("role"));
                user.setActive("true".equals(request.getParameter("isActive")));
                userService.addUser(user);
                response.sendRedirect(request.getContextPath() + "/admin/users");
            } else if (pathInfo.equals("/update")) {
                int userId = Integer.parseInt(request.getParameter("userId"));
                User user = new User();
                user.setUserId(userId);
                user.setUsername(request.getParameter("username"));
                user.setEmail(request.getParameter("email"));
                user.setRole(request.getParameter("role"));
                user.setActive("true".equals(request.getParameter("isActive")));
                userService.updateUser(user);
                response.sendRedirect(request.getContextPath() + "/admin/users?message=update_success");
            } else if (pathInfo.equals("/delete")) {
                String userIdStr = request.getParameter("userId");
                if (userIdStr == null || userIdStr.trim().isEmpty() || userIdStr.equals("undefined")) {
                    LOGGER.log(Level.WARNING, "Invalid userId in delete: " + userIdStr);
                    response.sendRedirect(request.getContextPath() + "/admin/users?error=invalid_user_id");
                    return;
                }
                int userId = Integer.parseInt(userIdStr);
                if (userId <= 0) {
                    LOGGER.log(Level.WARNING, "Negative or zero userId in delete: " + userId);
                    response.sendRedirect(request.getContextPath() + "/admin/users?error=invalid_user_id");
                    return;
                }
                userService.deleteUser(userId);
                response.sendRedirect(request.getContextPath() + "/admin/users?message=delete_success");
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Database error in doPost", e);
            throw new ServletException("Database error", e);
        } catch (NumberFormatException e) {
            LOGGER.log(Level.WARNING, "NumberFormatException in doPost with userId: " + request.getParameter("userId"), e);
            response.sendRedirect(request.getContextPath() + "/admin/users?error=invalid_user_id");
        }
    }
}