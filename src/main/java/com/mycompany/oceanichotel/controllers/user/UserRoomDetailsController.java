package com.mycompany.oceanichotel.controllers.user;
/*
 * Copyright (c) 2025 annc19324
 * All rights reserved.
 *
 * This code is the property of annc19324.
 * Unauthorized copying or distribution is prohibited.
 */
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
import java.util.logging.Logger;
import java.util.logging.Level;

@WebServlet("/user/room-details/*")
public class UserRoomDetailsController extends HttpServlet {

    private UserRoomService userRoomService;
    private static final Logger LOGGER = Logger.getLogger(UserRoomDetailsController.class.getName());

    @Override
    public void init() throws ServletException {
        userRoomService = new UserRoomService();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        User user = (User) request.getSession().getAttribute("user");
        if (user == null || !"user".equals(user.getRole())) {
            LOGGER.info("User not logged in or not authorized, redirecting to login.");
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        String pathInfo = request.getPathInfo();
        if (pathInfo == null || pathInfo.length() <= 1) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Room ID is required.");
            return;
        }

        String roomIdStr = pathInfo.substring(1); // Lấy roomId từ URL (ví dụ: /user/room-details/1 -> "1")
        try {
            int roomId = Integer.parseInt(roomIdStr);
            Room room = userRoomService.getRoomById(roomId);
            if (room == null) {
                LOGGER.warning("Room not found with ID: " + roomId);
                request.setAttribute("error", "Phòng không tồn tại.");
            } else {
                request.setAttribute("room", room);
            }
        } catch (NumberFormatException e) {
            LOGGER.log(Level.WARNING, "Invalid room ID: " + roomIdStr, e);
            request.setAttribute("error", "ID phòng không hợp lệ.");
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error retrieving room details for roomId: " + roomIdStr, e);
            request.setAttribute("error", "Không thể tải chi tiết phòng do lỗi cơ sở dữ liệu.");
        }

        request.getRequestDispatcher("/WEB-INF/views/user/room_details.jsp").forward(request, response);
    }
}