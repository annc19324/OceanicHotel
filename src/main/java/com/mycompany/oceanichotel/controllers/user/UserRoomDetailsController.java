//package com.mycompany.oceanichotel.controllers.user;
//
//import com.mycompany.oceanichotel.models.Room;
//import com.mycompany.oceanichotel.services.user.UserRoomDetailsService;
//import jakarta.servlet.ServletException;
//import jakarta.servlet.annotation.WebServlet;
//import jakarta.servlet.http.HttpServlet;
//import jakarta.servlet.http.HttpServletRequest;
//import jakarta.servlet.http.HttpServletResponse;
//
//import java.io.IOException;
//import java.sql.SQLException;
//import java.text.SimpleDateFormat;
//import java.util.Date;
//import java.util.logging.Level;
//import java.util.logging.Logger;
//
//@WebServlet("/user/room-details/*")
//public class UserRoomDetailsController extends HttpServlet {
//    private UserRoomDetailsService roomDetailsService;
//    private static final Logger LOGGER = Logger.getLogger(UserRoomDetailsController.class.getName());
//    private static final SimpleDateFormat DATE_FORMAT = new SimpleDateFormat("yyyy-MM-dd");
//
//    @Override
//    public void init() throws ServletException {
//        roomDetailsService = new UserRoomDetailsService();
//    }
//
//    @Override
//    protected void doGet(HttpServletRequest request, HttpServletResponse response)
//            throws ServletException, IOException {
//        String pathInfo = request.getPathInfo();
//        if (pathInfo == null || pathInfo.equals("/")) {
//            LOGGER.warning("Room ID is missing in request: " + request.getRequestURI());
//            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Room ID is required");
//            return;
//        }
//
//        String[] splits = pathInfo.split("/");
//        if (splits.length < 2) {
//            LOGGER.warning("Invalid Room ID format in request: " + pathInfo);
//            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid Room ID");
//            return;
//        }
//
//        int roomId;
//        try {
//            roomId = Integer.parseInt(splits[1]);
//        } catch (NumberFormatException e) {
//            LOGGER.warning("Invalid Room ID format: " + splits[1]);
//            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid Room ID format");
//            return;
//        }
//
//        try {
//            Room room = roomDetailsService.getRoomById(roomId);
//            if (room == null) {
//                LOGGER.info("Room not found for ID: " + roomId);
//                response.sendError(HttpServletResponse.SC_NOT_FOUND, "Room not found");
//                return;
//            }
//
//            String checkIn = request.getParameter("checkIn");
//            String checkOut = request.getParameter("checkOut");
//            if (checkIn != null && checkOut != null) {
//                try {
//                    Date checkInDate = DATE_FORMAT.parse(checkIn);
//                    Date checkOutDate = DATE_FORMAT.parse(checkOut);
//                    if (checkOutDate.before(checkInDate)) {
//                        request.setAttribute("error", "Check-out date must be after check-in date");
//                    }
//                } catch (Exception e) {
//                    request.setAttribute("error", "Invalid date format");
//                }
//            }
//
//            request.setAttribute("room", room);
//            request.setAttribute("checkIn", checkIn);
//            request.setAttribute("checkOut", checkOut);
//            request.setAttribute("adults", request.getParameter("adults"));
//            request.setAttribute("children", request.getParameter("children"));
//            LOGGER.info("Room details fetched successfully for roomId: " + roomId);
//            request.getRequestDispatcher("/WEB-INF/views/user/room_details.jsp").forward(request, response);
//        } catch (SQLException e) {
//            LOGGER.log(Level.SEVERE, "Database error while fetching room details for roomId: " + roomId, e);
//            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Database error occurred");
//        }
//    }
//}