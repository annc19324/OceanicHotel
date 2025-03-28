package com.mycompany.oceanichotel.controllers.admin;

import com.mycompany.oceanichotel.models.Room;
import com.mycompany.oceanichotel.services.admin.AdminRoomService;
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

@WebServlet("/admin/rooms/*")
public class AdminRoomController extends HttpServlet {

    private AdminRoomService roomService;
    private static final Logger LOGGER = Logger.getLogger(AdminRoomController.class.getName());

    @Override
    public void init() throws ServletException {
        roomService = new AdminRoomService();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String pathInfo = request.getPathInfo();
        try {
            if (pathInfo == null || pathInfo.equals("/")) {
                int page = request.getParameter("page") != null ? Integer.parseInt(request.getParameter("page")) : 1;
                String search = request.getParameter("search");
                String status = request.getParameter("status");
                String roomType = request.getParameter("roomType");

                List<Room> rooms = roomService.getRooms(page, search, status, roomType);
                int totalRooms = roomService.getTotalRooms(search, status, roomType);
                int totalPages = (int) Math.ceil((double) totalRooms / 10);

                request.setAttribute("rooms", rooms);
                request.setAttribute("currentPage", page);
                request.setAttribute("totalPages", totalPages);
                request.getRequestDispatcher("/WEB-INF/views/admin/rooms.jsp").forward(request, response);
            } else if (pathInfo.equals("/add")) {
                request.getRequestDispatcher("/WEB-INF/views/admin/add_room.jsp").forward(request, response);
            } else if (pathInfo.equals("/edit")) {
                int roomId = Integer.parseInt(request.getParameter("roomId"));
                Room room = roomService.getRoomById(roomId);
                if (room != null) {
                    request.setAttribute("room", room);
                    request.getRequestDispatcher("/WEB-INF/views/admin/edit_room.jsp").forward(request, response);
                } else {
                    response.sendRedirect(request.getContextPath() + "/admin/rooms?error=room_not_found");
                }
            } else if (pathInfo.equals("/edit-history")) {
                int roomId = Integer.parseInt(request.getParameter("roomId"));
                // Xử lý lịch sử chỉnh sửa phòng ở đây (chưa triển khai)
                response.sendRedirect(request.getContextPath() + "/admin/rooms");
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Database error in doGet", e);
            throw new ServletException("Database error", e);
        } catch (NumberFormatException e) {
            LOGGER.log(Level.WARNING, "Invalid roomId in doGet: " + request.getParameter("roomId"), e);
            response.sendRedirect(request.getContextPath() + "/admin/rooms?error=invalid_room_id");
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
                Room room = new Room();
                room.setRoomNumber(request.getParameter("roomNumber"));
                room.setRoomType(request.getParameter("roomType"));
                room.setPricePerNight(Double.parseDouble(request.getParameter("pricePerNight")));
                room.setAvailable("true".equals(request.getParameter("isAvailable")));
                room.setDescription(request.getParameter("description"));
                try {
                    roomService.addRoom(room);
                    response.sendRedirect(request.getContextPath() + "/admin/rooms?message=add_success");
                } catch (SQLException e) {
                    if (e.getMessage().contains("Room number already exists")) {
                        request.setAttribute("error", language.equals("vi") ? "Số phòng đã tồn tại!" : "Room number already exists!");
                        request.getRequestDispatcher("/WEB-INF/views/admin/add_room.jsp").forward(request, response);
                    } else {
                        throw e;
                    }
                }
            } else if (pathInfo.equals("/update")) {
                int roomId = Integer.parseInt(request.getParameter("roomId"));
                Room room = new Room();
                room.setRoomId(roomId);
                room.setRoomNumber(request.getParameter("roomNumber"));
                room.setRoomType(request.getParameter("roomType"));
                room.setPricePerNight(Double.parseDouble(request.getParameter("pricePerNight")));
                room.setAvailable("true".equals(request.getParameter("isAvailable")));
                room.setDescription(request.getParameter("description"));
                try {
                    roomService.updateRoom(room);
                    response.sendRedirect(request.getContextPath() + "/admin/rooms?message=update_success");
                } catch (SQLException e) {
                    if (e.getMessage().contains("Room number already exists")) {
                        request.setAttribute("room", room);
                        request.setAttribute("error", language.equals("vi") ? "Số phòng đã tồn tại!" : "Room number already exists!");
                        request.getRequestDispatcher("/WEB-INF/views/admin/edit_room.jsp").forward(request, response);
                    } else {
                        throw e;
                    }
                }
            } else if (pathInfo.equals("/delete")) {
                int roomId = Integer.parseInt(request.getParameter("roomId"));
                roomService.deleteRoom(roomId);
                response.sendRedirect(request.getContextPath() + "/admin/rooms?message=delete_success");
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Database error in doPost", e);
            throw new ServletException("Database error", e);
        } catch (NumberFormatException e) {
            LOGGER.log(Level.WARNING, "Invalid roomId or price in doPost: " + request.getParameter("roomId"), e);
            response.sendRedirect(request.getContextPath() + "/admin/rooms?error=invalid_input");
        }
    }
}