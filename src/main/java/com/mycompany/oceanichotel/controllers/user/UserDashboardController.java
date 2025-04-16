package com.mycompany.oceanichotel.controllers.user;
/*
 * Copyright (c) 2025 annc19324
 * All rights reserved.
 *
 * This code is the property of annc19324.
 * Unauthorized copying or distribution is prohibited.
 */
import com.mycompany.oceanichotel.models.User;
import com.mycompany.oceanichotel.models.RoomType;
import com.mycompany.oceanichotel.services.admin.AdminRoomTypeService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.sql.SQLException;
import java.util.List;
import java.util.logging.Logger;
import java.util.logging.Level;
import java.util.stream.Collectors;

@WebServlet("/user/dashboard")
public class UserDashboardController extends HttpServlet {

    private AdminRoomTypeService roomTypeService;
    private static final Logger LOGGER = Logger.getLogger(UserDashboardController.class.getName());

    @Override
    public void init() throws ServletException {
        roomTypeService = new AdminRoomTypeService();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session != null && session.getAttribute("user") != null) {
            User user = (User) session.getAttribute("user");
            if ("user".equals(user.getRole())) {
                request.setAttribute("username", user.getUsername());
                String searchQuery = request.getParameter("search");
                try {
                    List<RoomType> roomTypes = roomTypeService.getAllRoomTypes();
                    if (searchQuery != null && !searchQuery.trim().isEmpty()) {
                        roomTypes = roomTypes.stream()
                                .filter(rt -> rt.getTypeName().toLowerCase().contains(searchQuery.toLowerCase()))
                                .collect(Collectors.toList());
                    }
                    LOGGER.log(Level.INFO, "Retrieved {0} room types from database.", roomTypes.size());
                    if (roomTypes.isEmpty()) {
                        LOGGER.warning("No room types found in the database.");
                    }
                    request.setAttribute("roomTypes", roomTypes);
                } catch (SQLException e) {
                    LOGGER.log(Level.SEVERE, "Error retrieving room types from database", e);
                    request.setAttribute("error", "Unable to load room types due to a database error.");
                }
                request.getRequestDispatcher("/WEB-INF/views/user/dashboard.jsp").forward(request, response);
                return;
            }
        }
        LOGGER.info("User not logged in or not authorized, redirecting to login.");
        response.sendRedirect(request.getContextPath() + "/login");
    }
}