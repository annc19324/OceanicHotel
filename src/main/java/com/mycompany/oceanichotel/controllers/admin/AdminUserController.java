package com.mycompany.oceanichotel.controllers.admin;

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
        String language = (String) request.getSession().getAttribute("language");
        if (language == null) {
            language = "en";
            request.getSession().setAttribute("language", language);
        }
        try {
            if (pathInfo.equals("/add")) {
                User user = new User();
                user.setUsername(request.getParameter("username"));
                user.setEmail(request.getParameter("email"));
                user.setPassword(request.getParameter("password")); // Nên mã hóa mật khẩu trong thực tế
                user.setRole(request.getParameter("role"));
                try {
                    userService.addUser(user);
                    response.sendRedirect(request.getContextPath() + "/admin/users?message=add_success");
                } catch (SQLException e) {
                    if (e.getMessage().contains("Username already exists")) {
                        request.setAttribute("error", language.equals("vi") ? "Tên người dùng đã tồn tại!" : "Username already exists!");
                    } else if (e.getMessage().contains("Email already exists")) {
                        request.setAttribute("error", language.equals("vi") ? "Email đã tồn tại!" : "Email already exists!");
                    } else {
                        throw e;
                    }
                    request.getRequestDispatcher("/WEB-INF/views/admin/add_user.jsp").forward(request, response);
                }
            } else if (pathInfo.equals("/update")) {
                int userId = Integer.parseInt(request.getParameter("userId"));
                User user = new User();
                user.setUserId(userId);
                user.setUsername(request.getParameter("username"));
                user.setEmail(request.getParameter("email"));
                String password = request.getParameter("password");
                if (password != null && !password.isEmpty()) {
                    user.setPassword(password); // Nên mã hóa mật khẩu trong thực tế
                }
                user.setRole(request.getParameter("role"));
                try {
                    userService.updateUser(user);
                    response.sendRedirect(request.getContextPath() + "/admin/users?message=update_success");
                } catch (SQLException e) {
                    if (e.getMessage().contains("Username already exists")) {
                        request.setAttribute("error", language.equals("vi") ? "Tên người dùng đã tồn tại!" : "Username already exists!");
                    } else if (e.getMessage().contains("Email already exists")) {
                        request.setAttribute("error", language.equals("vi") ? "Email đã tồn tại!" : "Email already exists!");
                    } else {
                        throw e;
                    }
                    request.setAttribute("user", user);
                    request.getRequestDispatcher("/WEB-INF/views/admin/edit_user.jsp").forward(request, response);
                }
            } else if (pathInfo.equals("/delete")) {
                int userId = Integer.parseInt(request.getParameter("userId"));
                userService.deleteUser(userId);
                response.sendRedirect(request.getContextPath() + "/admin/users?message=delete_success");
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Database error in doPost", e);
            throw new ServletException("Database error", e);
        } catch (NumberFormatException e) {
            LOGGER.log(Level.WARNING, "Invalid userId in doPost: " + request.getParameter("userId"), e);
            response.sendRedirect(request.getContextPath() + "/admin/users?error=invalid_input");
        }
    }
}