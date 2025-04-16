package com.mycompany.oceanichotel.controllers.user;
/*
 * Copyright (c) 2025 annc19324
 * All rights reserved.
 *
 * This code is the property of annc19324.
 * Unauthorized copying or distribution is prohibited.
 */
import com.mycompany.oceanichotel.models.Booking;
import com.mycompany.oceanichotel.models.Room;
import com.mycompany.oceanichotel.models.User;
import com.mycompany.oceanichotel.services.user.UserBookingService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.math.BigDecimal;
import java.sql.SQLException;
import java.text.SimpleDateFormat;
import java.util.Calendar;
import java.util.Date;
import java.util.logging.Logger;
import java.util.logging.Level;

@WebServlet("/user/book-room")
public class UserBookingController extends HttpServlet {
    private UserBookingService userBookingService;
    private static final Logger LOGGER = Logger.getLogger(UserBookingController.class.getName());
    private static final SimpleDateFormat DATE_FORMAT = new SimpleDateFormat("yyyy-MM-dd");

    @Override
    public void init() throws ServletException {
        userBookingService = new UserBookingService();
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

        String roomIdStr = request.getParameter("roomId");
        if (roomIdStr == null || roomIdStr.trim().isEmpty()) {
            LOGGER.warning("Room ID is missing in booking request.");
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Room ID is required.");
            return;
        }

        try {
            int roomId = Integer.parseInt(roomIdStr);
            Room room = userBookingService.getRoomById(roomId); // Giả định UserBookingService có phương thức này, nếu không thì cần thêm
            if (room == null || !room.isAvailable()) {
                LOGGER.warning("Room not found or not available for booking: " + roomId);
                request.setAttribute("error", "Phòng không tồn tại hoặc đã được đặt.");
                request.getRequestDispatcher("/WEB-INF/views/user/room_details.jsp").forward(request, response);
                return;
            }

            request.setAttribute("room", room);
            request.getRequestDispatcher("/WEB-INF/views/user/book_room.jsp").forward(request, response);
        } catch (NumberFormatException e) {
            LOGGER.log(Level.WARNING, "Invalid room ID: " + roomIdStr, e);
            request.setAttribute("error", "ID phòng không hợp lệ.");
            request.getRequestDispatcher("/WEB-INF/views/user/room_details.jsp").forward(request, response);
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error retrieving room for booking: " + roomIdStr, e);
            request.setAttribute("error", "Không thể tải thông tin phòng do lỗi cơ sở dữ liệu.");
            request.getRequestDispatcher("/WEB-INF/views/user/room_details.jsp").forward(request, response);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        User user = (User) request.getSession().getAttribute("user");
        if (user == null || !"user".equals(user.getRole())) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        String roomIdStr = request.getParameter("roomId");
        String checkInDateStr = request.getParameter("checkInDate");
        String checkOutDateStr = request.getParameter("checkOutDate");
        String adultsStr = request.getParameter("adults");
        String childrenStr = request.getParameter("children");

        try {
            int roomId = Integer.parseInt(roomIdStr);
            Room room = userBookingService.getRoomById(roomId); // Giả định có phương thức này
            if (room == null || !room.isAvailable()) {
                request.setAttribute("error", "Phòng không còn trống để đặt.");
                request.setAttribute("room", room);
                request.getRequestDispatcher("/WEB-INF/views/user/book_room.jsp").forward(request, response);
                return;
            }

            Date checkInDate = DATE_FORMAT.parse(checkInDateStr);
            Date checkOutDate = DATE_FORMAT.parse(checkOutDateStr);
            int numAdults = Integer.parseInt(adultsStr);
            int numChildren = Integer.parseInt(childrenStr);

            // Kiểm tra ngày nhận phòng phải từ 2-7 ngày sau ngày hiện tại
            Calendar today = Calendar.getInstance();
            today.set(Calendar.HOUR_OF_DAY, 0);
            today.set(Calendar.MINUTE, 0);
            today.set(Calendar.SECOND, 0);
            today.set(Calendar.MILLISECOND, 0);
            Calendar minCheckIn = (Calendar) today.clone();
            minCheckIn.add(Calendar.DATE, 2);
            Calendar maxCheckIn = (Calendar) today.clone();
            maxCheckIn.add(Calendar.DATE, 7);

            if (checkInDate.before(minCheckIn.getTime()) || checkInDate.after(maxCheckIn.getTime())) {
                request.setAttribute("error", "Ngày nhận phòng phải từ 2 đến 7 ngày sau ngày hiện tại.");
                request.setAttribute("room", room);
                request.getRequestDispatcher("/WEB-INF/views/user/book_room.jsp").forward(request, response);
                return;
            }

            if (checkOutDate.before(checkInDate)) {
                request.setAttribute("error", "Ngày trả phòng phải sau ngày nhận phòng.");
                request.setAttribute("room", room);
                request.getRequestDispatcher("/WEB-INF/views/user/book_room.jsp").forward(request, response);
                return;
            }
            if (numAdults + numChildren > room.getMaxAdults() + room.getMaxChildren()) {
                request.setAttribute("error", "Số người vượt quá sức chứa tối đa của phòng.");
                request.setAttribute("room", room);
                request.getRequestDispatcher("/WEB-INF/views/user/book_room.jsp").forward(request, response);
                return;
            }

            long diffInMillies = checkOutDate.getTime() - checkInDate.getTime();
            int days = (int) (diffInMillies / (1000 * 60 * 60 * 24));
            BigDecimal totalPrice = room.getPricePerNight().multiply(new BigDecimal(days));

            Booking booking = new Booking();
            booking.setUserId(user.getUserId());
            booking.setRoomId(roomId);
            booking.setCheckInDate(checkInDate);
            booking.setCheckOutDate(checkOutDate);
            booking.setTotalPrice(totalPrice);
            booking.setStatus("Pending"); // Ban đầu là Pending, chờ thanh toán
            booking.setNumAdults(numAdults);
            booking.setNumChildren(numChildren);

            userBookingService.bookRoom(booking); // Sử dụng UserBookingService để tạo Transaction

            LOGGER.info("Booking created successfully for roomId=" + roomId + ", userId=" + user.getUserId());
            response.sendRedirect(request.getContextPath() + "/user/bookings");
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error processing booking for roomId: " + roomIdStr, e);
            request.setAttribute("error", "Không thể đặt phòng do lỗi: " + e.getMessage());
            request.getRequestDispatcher("/WEB-INF/views/user/book_room.jsp").forward(request, response);
        }
    }
}