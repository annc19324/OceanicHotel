package com.mycompany.oceanichotel.controllers.user;

import com.mycompany.oceanichotel.models.Booking;
import com.mycompany.oceanichotel.models.BookingHistory;
import com.mycompany.oceanichotel.models.User;
import com.mycompany.oceanichotel.services.user.UserBookingService;
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

@WebServlet("/user/bookings")
public class UserBookingsController extends HttpServlet {

    private UserBookingService userBookingService;
    private UserRoomService userRoomService; // Thêm UserRoomService để lấy history
    private static final Logger LOGGER = Logger.getLogger(UserBookingsController.class.getName());

    @Override
    public void init() throws ServletException {
        userBookingService = new UserBookingService();
        userRoomService = new UserRoomService(); // Khởi tạo UserRoomService
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        User user = (User) request.getSession().getAttribute("user");
        if (user == null) {
            LOGGER.info("User not logged in, redirecting to login.");
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }
        LOGGER.info("Current user ID: " + user.getUserId());

        try {
            // Lấy danh sách đặt phòng
            List<Booking> bookings = userBookingService.getUserBookings(user.getUserId());
            LOGGER.log(Level.INFO, "Retrieved {0} bookings for userId={1}",
                    new Object[]{bookings.size(), user.getUserId()});
            for (Booking b : bookings) {
                LOGGER.info("Booking: ID=" + b.getBookingId() + ", Room=" + b.getRoom().getRoomNumber() + ", Status=" + b.getStatus());
            }
            request.setAttribute("bookings", bookings);

            // Lấy lịch sử thay đổi trạng thái
            List<BookingHistory> history = userRoomService.getBookingHistory(user.getUserId());
            LOGGER.log(Level.INFO, "Retrieved {0} history records for userId={1}",
                    new Object[]{history.size(), user.getUserId()});
            for (BookingHistory h : history) {
                LOGGER.info("History: ID=" + h.getHistoryId() + ", Booking ID=" + h.getBookingId() + ", New Status=" + h.getNewStatus());
            }
            request.setAttribute("history", history);

            request.getRequestDispatcher("/WEB-INF/views/user/bookings.jsp").forward(request, response);
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error retrieving bookings or history for userId=" + user.getUserId(), e);
            request.setAttribute("error", "Unable to load bookings or history due to a database error: " + e.getMessage());
            request.getRequestDispatcher("/WEB-INF/views/user/bookings.jsp").forward(request, response);
        }
    }
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        User user = (User) request.getSession().getAttribute("user");
        if (user == null) {
            LOGGER.info("User not logged in, redirecting to login.");
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        String action = request.getParameter("action");
        if ("cancel".equals(action)) {
            int bookingId = Integer.parseInt(request.getParameter("bookingId"));
            try {
                userRoomService.cancelBooking(bookingId, user.getUserId());
                LOGGER.info("Booking ID=" + bookingId + " cancelled by userId=" + user.getUserId());
                response.sendRedirect(request.getContextPath() + "/user/bookings");
            } catch (SQLException e) {
                LOGGER.log(Level.SEVERE, "Error cancelling booking ID=" + bookingId, e);
                request.setAttribute("error", "Unable to cancel booking: " + e.getMessage());
                doGet(request, response); // Tải lại trang với thông báo lỗi
            }
        }
    }
    
}
