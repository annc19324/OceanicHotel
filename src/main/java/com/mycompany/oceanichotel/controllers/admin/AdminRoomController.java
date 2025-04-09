package com.mycompany.oceanichotel.controllers.admin;

import com.mycompany.oceanichotel.models.Room;
import com.mycompany.oceanichotel.models.RoomType;
import com.mycompany.oceanichotel.services.admin.AdminRoomService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.math.BigDecimal;
import java.net.URLEncoder;
import java.sql.SQLException;
import java.util.ArrayList;
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
                String typeId = request.getParameter("typeId");

                List<Room> rooms = roomService.getRooms(page, search, status, typeId);
                int totalRooms = roomService.getTotalRooms(search, status, typeId);
                int totalPages = (int) Math.ceil((double) totalRooms / 10);
                List<RoomType> roomTypes = roomService.getAllRoomTypes();

                request.setAttribute("rooms", rooms);
                request.setAttribute("currentPage", page);
                request.setAttribute("totalPages", totalPages);
                request.setAttribute("roomTypes", roomTypes);
                request.getRequestDispatcher("/WEB-INF/views/admin/rooms.jsp").forward(request, response);
            } else if (pathInfo.equals("/add")) {
                List<RoomType> roomTypes = roomService.getAllRoomTypes();
                request.setAttribute("roomTypes", roomTypes);
                request.getRequestDispatcher("/WEB-INF/views/admin/add_room.jsp").forward(request, response);
            } else if (pathInfo.equals("/edit")) {
                int roomId = Integer.parseInt(request.getParameter("roomId"));
                Room room = roomService.getRoomById(roomId);
                List<RoomType> roomTypes = roomService.getAllRoomTypes();
                if (room != null) {
                    request.setAttribute("room", room);
                    request.setAttribute("roomTypes", roomTypes);
                    request.getRequestDispatcher("/WEB-INF/views/admin/edit_room.jsp").forward(request, response);
                } else {
                    response.sendRedirect(request.getContextPath() + "/admin/rooms?error=room_not_found");
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Database error in doGet", e);
            throw new ServletException("Database error", e);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String pathInfo = request.getPathInfo();
        String language = (String) request.getSession().getAttribute("language");
        if (language == null) {
            language = "en";
        }

        try {
            if (pathInfo.equals("/add")) {
                Room room = new Room();
                String roomNumber = request.getParameter("roomNumber");
                if (roomNumber == null || roomNumber.trim().isEmpty()) {
                    throw new IllegalArgumentException("Room number is required.");
                }
                room.setRoomNumber(roomNumber);

                int typeId = Integer.parseInt(request.getParameter("typeId"));
                RoomType roomType = roomService.getRoomTypeById(typeId);
                if (roomType == null) {
                    throw new SQLException("Invalid room type ID: " + typeId);
                }
                room.setRoomType(roomType);

                room.setPricePerNight(new BigDecimal(request.getParameter("pricePerNight")));
                room.setAvailable("true".equals(request.getParameter("isAvailable")));
                room.setDescription(request.getParameter("description"));
                room.setMaxAdults(Integer.parseInt(request.getParameter("maxAdults")));
                room.setMaxChildren(Integer.parseInt(request.getParameter("maxChildren")));

                roomService.addRoom(room);
                response.sendRedirect(request.getContextPath() + "/admin/rooms?message=add_success");
            } else if (pathInfo.equals("/update")) {
                int roomId = Integer.parseInt(request.getParameter("roomId"));
                Room room = new Room();
                room.setRoomId(roomId);
                String roomNumber = request.getParameter("roomNumber");
                if (roomNumber == null || roomNumber.trim().isEmpty()) {
                    throw new IllegalArgumentException("Room number is required.");
                }
                room.setRoomNumber(roomNumber);

                int typeId = Integer.parseInt(request.getParameter("typeId"));
                RoomType roomType = roomService.getRoomTypeById(typeId);
                if (roomType == null) {
                    throw new SQLException("Invalid room type ID: " + typeId);
                }
                room.setRoomType(roomType);

                room.setPricePerNight(new BigDecimal(request.getParameter("pricePerNight")));
                room.setAvailable("true".equals(request.getParameter("isAvailable")));
                room.setDescription(request.getParameter("description"));
                room.setMaxAdults(Integer.parseInt(request.getParameter("maxAdults")));
                room.setMaxChildren(Integer.parseInt(request.getParameter("maxChildren")));

                roomService.updateRoom(room);
                response.sendRedirect(request.getContextPath() + "/admin/rooms?message=update_success");
            } else if (pathInfo.equals("/delete")) {
                int roomId = Integer.parseInt(request.getParameter("roomId"));
                try {
                    roomService.deleteRoom(roomId); // Có thể ném SQLException
                    response.sendRedirect(request.getContextPath() + "/admin/rooms?message=delete_success");
                } catch (SQLException e) {
                    LOGGER.log(Level.WARNING, "Failed to delete room", e);
                    String errorMsg = language.equals("vi")
                            ? (e.getMessage().contains("occupied") ? "Không thể xóa phòng vì phòng đang được sử dụng."
                            : "Không thể xóa phòng vì có " + e.getMessage().split("has ")[1] + " đang đặt.")
                            : e.getMessage();
                    response.sendRedirect(request.getContextPath() + "/admin/rooms?error=" + URLEncoder.encode(errorMsg, "UTF-8"));
                }
            }
        } catch (IllegalArgumentException e) {
            LOGGER.log(Level.WARNING, "Invalid input in doPost", e);
            request.setAttribute("error", language.equals("vi") ? "Dữ liệu không hợp lệ: " + e.getMessage() : "Invalid input: " + e.getMessage());
            handleError(request, response, pathInfo);
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Database error in doPost", e);
            request.setAttribute("error", language.equals("vi") ? "Lỗi cơ sở dữ liệu: " + e.getMessage() : "Database error: " + e.getMessage());
            handleError(request, response, pathInfo);
        }
    }

    private void handleError(HttpServletRequest request, HttpServletResponse response, String pathInfo) throws ServletException, IOException {
        List<RoomType> roomTypes;
        try {
            roomTypes = roomService.getAllRoomTypes();
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Failed to retrieve room types", e);
            roomTypes = new ArrayList<>();
        }
        request.setAttribute("roomTypes", roomTypes);

        if (pathInfo.equals("/add")) {
            Room room = new Room();
            room.setRoomNumber(request.getParameter("roomNumber"));
            room.setPricePerNight(parseBigDecimalOrDefault(request.getParameter("pricePerNight"), BigDecimal.ZERO));
            room.setAvailable("true".equals(request.getParameter("isAvailable")));
            room.setDescription(request.getParameter("description"));
            room.setMaxAdults(parseIntOrDefault(request.getParameter("maxAdults"), 0));
            room.setMaxChildren(parseIntOrDefault(request.getParameter("maxChildren"), 0));
            try {
                int typeId = Integer.parseInt(request.getParameter("typeId"));
                RoomType roomType = roomService.getRoomTypeById(typeId);
                room.setRoomType(roomType);
            } catch (NumberFormatException | SQLException ignored) {
            }
            request.setAttribute("room", room);
            request.getRequestDispatcher("/WEB-INF/views/admin/add_room.jsp").forward(request, response);
        } else if (pathInfo.equals("/update")) {
            int roomId = parseIntOrDefault(request.getParameter("roomId"), -1);
            Room room;
            try {
                room = roomService.getRoomById(roomId);
                if (room != null) {
                    room.setRoomNumber(request.getParameter("roomNumber"));
                    room.setPricePerNight(parseBigDecimalOrDefault(request.getParameter("pricePerNight"), room.getPricePerNight()));
                    room.setAvailable("true".equals(request.getParameter("isAvailable")));
                    room.setDescription(request.getParameter("description"));
                    room.setMaxAdults(parseIntOrDefault(request.getParameter("maxAdults"), room.getMaxAdults()));
                    room.setMaxChildren(parseIntOrDefault(request.getParameter("maxChildren"), room.getMaxChildren()));
                    int typeId = Integer.parseInt(request.getParameter("typeId"));
                    RoomType roomType = roomService.getRoomTypeById(typeId);
                    room.setRoomType(roomType);
                }
            } catch (SQLException e) {
                LOGGER.log(Level.SEVERE, "Failed to retrieve room for update", e);
                room = null;
            }
            request.setAttribute("room", room);
            request.getRequestDispatcher("/WEB-INF/views/admin/edit_room.jsp").forward(request, response);
        } else {
            request.getRequestDispatcher("/WEB-INF/views/admin/rooms.jsp").forward(request, response);
        }
    }

    private int parseIntOrDefault(String value, int defaultValue) {
        try {
            return Integer.parseInt(value);
        } catch (NumberFormatException e) {
            return defaultValue;
        }
    }

    private BigDecimal parseBigDecimalOrDefault(String value, BigDecimal defaultValue) {
        try {
            return new BigDecimal(value);
        } catch (NumberFormatException | NullPointerException e) {
            return defaultValue;
        }
    }
}
