/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
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
/**
 *
 * @author annc1
 */
//@WebServlet("/admin/users/*")
public class AdminUserController extends HttpServlet {
    private AdminUserService userService;

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
                // Hiển thị danh sách người dùng
                List<User> users = userService.getAllUsers();
                request.setAttribute("users", users);
                request.getRequestDispatcher("/WEB-INF/admin/dashboard.jsp").forward(request, response);
            } else if (pathInfo.equals("/edit")) {
                // Chuyển hướng đến trang chỉnh sửa (chưa triển khai giao diện)
                int userId = Integer.parseInt(request.getParameter("userId"));
                User user = userService.getUserById(userId);
                request.setAttribute("user", user);
                response.getWriter().write("Edit user: " + user.getUsername()); // Placeholder
            } else if (pathInfo.equals("/login-history")) {
                // Hiển thị lịch sử đăng nhập (chưa triển khai giao diện)
                int userId = Integer.parseInt(request.getParameter("userId"));
                response.getWriter().write("Login history for user ID: " + userId); // Placeholder
            }
        } catch (SQLException e) {
            throw new ServletException("Database error", e);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String pathInfo = request.getPathInfo();
        
        if (pathInfo != null && pathInfo.equals("/delete")) {
            try {
                int userId = Integer.parseInt(request.getParameter("userId"));
                userService.deleteUser(userId);
                response.sendRedirect(request.getContextPath() + "/admin/users");
            } catch (SQLException e) {
                throw new ServletException("Delete error", e);
            }
        }
    }
}