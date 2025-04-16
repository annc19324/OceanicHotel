package com.mycompany.oceanichotel.controllers.receptionist;
/*
 * Copyright (c) 2025 annc19324
 * All rights reserved.
 *
 * This code is the property of annc19324.
 * Unauthorized copying or distribution is prohibited.
 */
import com.mycompany.oceanichotel.models.Room;
import com.mycompany.oceanichotel.models.User;
import com.mycompany.oceanichotel.services.admin.AdminRoomService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.sql.SQLException;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

@WebServlet("/receptionist/rooms")
public class ReceptionistRoomController extends HttpServlet {

    private AdminRoomService roomService;
    private static final Logger LOGGER = Logger.getLogger(ReceptionistRoomController.class.getName());

    @Override
    public void init() throws ServletException {
        roomService = new AdminRoomService();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        User user = (User) request.getSession().getAttribute("user");
        if (user == null || !"receptionist".equals(user.getRole())) {
            response.sendRedirect(request.getContextPath() + "/login?error=unauthorized");
            return;
        }

        try {
            int page = request.getParameter("page") != null ? Integer.parseInt(request.getParameter("page")) : 1;
            String search = request.getParameter("search");

            List<Room> rooms = roomService.getRooms(page, search, null, null); // Lấy tất cả phòng
            int totalRooms = roomService.getTotalRooms(search, null, null);
            int totalPages = (int) Math.ceil((double) totalRooms / 10);

            request.setAttribute("rooms", rooms);
            request.setAttribute("currentPage", page);
            request.setAttribute("totalPages", totalPages);
            request.getRequestDispatcher("/WEB-INF/views/receptionist/rooms.jsp").forward(request, response);
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Database error in doGet", e);
            throw new ServletException("Database error", e);
        } catch (NumberFormatException e) {
            LOGGER.log(Level.WARNING, "Invalid page in doGet", e);
            response.sendRedirect(request.getContextPath() + "/receptionist/rooms?error=invalid_input");
        }
    }
}