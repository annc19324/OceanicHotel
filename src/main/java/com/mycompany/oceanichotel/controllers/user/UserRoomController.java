package com.mycompany.oceanichotel.controllers.user;

import com.mycompany.oceanichotel.models.Room;
import com.mycompany.oceanichotel.models.User;
import com.mycompany.oceanichotel.services.user.UserRoomService;
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

@WebServlet("/user/rooms")
public class UserRoomController extends HttpServlet {
    private UserRoomService userRoomService;
    private static final Logger LOGGER = Logger.getLogger(UserRoomController.class.getName());

    @Override
    public void init() throws ServletException {
        userRoomService = new UserRoomService();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        User user = (User) request.getSession().getAttribute("user");
        if (user == null || !"user".equals(user.getRole())) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        String typeId = request.getParameter("typeId");

        try {
            if (typeId == null || typeId.trim().isEmpty()) {
                request.setAttribute("error", "Please select a room type.");
            } else {
                List<Room> rooms = userRoomService.getAvailableRoomsByType(typeId);
                request.setAttribute("rooms", rooms);
                LOGGER.log(Level.INFO, "Found {0} available rooms for typeId: {1}", 
                    new Object[]{rooms.size(), typeId});
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error retrieving rooms for typeId: {0}", typeId);
            request.setAttribute("error", "Unable to load rooms due to a database error: " + e.getMessage());
        }

        request.getRequestDispatcher("/WEB-INF/views/user/rooms.jsp").forward(request, response);
    }
}