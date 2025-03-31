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
    private UserRoomService userRoomService;
    private static final Logger LOGGER = Logger.getLogger(UserBookingsController.class.getName());

    @Override
    public void init() throws ServletException {
        userBookingService = new UserBookingService();
        userRoomService = new UserRoomService();
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
            String statusFilter = request.getParameter("statusFilter");
            String checkInFrom = request.getParameter("checkInFrom");
            String checkInTo = request.getParameter("checkInTo");
            String sortOption = request.getParameter("sortOption");

            List<Booking> bookings = userBookingService.getUserBookings(
                user.getUserId(), statusFilter, checkInFrom, checkInTo, sortOption
            );
            LOGGER.log(Level.INFO, "Retrieved {0} bookings for userId={1}", new Object[]{bookings.size(), user.getUserId()});
            for (Booking b : bookings) {
                LOGGER.info("Booking: ID=" + b.getBookingId() + ", Room=" + b.getRoom().getRoomNumber() + ", Status=" + b.getStatus());
            }
            request.setAttribute("bookings", bookings);

            List<BookingHistory> history = userRoomService.getBookingHistory(user.getUserId());
            LOGGER.log(Level.INFO, "Retrieved {0} history records for userId={1}", new Object[]{history.size(), user.getUserId()});
            for (BookingHistory h : history) {
                LOGGER.info("History: ID=" + h.getHistoryId() + ", Booking ID=" + h.getBookingId() + ", New Status=" + h.getNewStatus());
            }
            request.setAttribute("history", history);

            request.setAttribute("statusFilter", statusFilter);
            request.setAttribute("checkInFrom", checkInFrom);
            request.setAttribute("checkInTo", checkInTo);
            request.setAttribute("sortOption", sortOption);

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
        int bookingId = Integer.parseInt(request.getParameter("bookingId"));

        try {
            if ("cancel".equals(action)) {
                userRoomService.cancelBooking(bookingId, user.getUserId());
                LOGGER.info("Booking ID=" + bookingId + " cancelled by userId=" + user.getUserId());
            } else if ("pay".equals(action)) {
                String method = request.getParameter("method");
                Booking booking = userBookingService.getBookingById(bookingId, user.getUserId());
                if (booking == null || !"Pending".equals(booking.getStatus())) {
                    throw new SQLException("Booking not found or not in Pending status.");
                }

                if ("test".equals(method)) {
                    // Thanh toán Test: xác nhận ngay lập tức
                    userBookingService.confirmBooking(bookingId, user.getUserId());
                    LOGGER.info("Booking ID=" + bookingId + " confirmed immediately (Test payment) by userId=" + user.getUserId());
                } else if ("hotel".equals(method)) {
                    // Thanh toán tại khách sạn: giữ trạng thái Pending, không làm gì thêm
                    LOGGER.info("Booking ID=" + bookingId + " set for payment at hotel, status remains Pending.");
                } else if ("qr".equals(method)) {
                    // Thanh toán bằng mã QR: giữ trạng thái Pending, không làm gì thêm
                    LOGGER.info("Booking ID=" + bookingId + " set for QR payment, status remains Pending.");
                } else if ("momo".equals(method)) {
                    // Thanh toán qua MoMo: tạo giao dịch và chờ xác nhận (đang thực hiện)
                    int transactionId = userBookingService.createTransaction(bookingId, user.getUserId(), booking.getTotalPrice());
                    LOGGER.info("Transaction ID=" + transactionId + " created for MoMo payment for booking ID=" + bookingId);
                    // Hiện tại chỉ tạo giao dịch, chưa xác nhận ngay, chờ logic MoMo hoàn thiện
                }
            }
            response.sendRedirect(request.getContextPath() + "/user/bookings");
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error processing action '" + action + "' for booking ID=" + bookingId, e);
            request.setAttribute("error", "Unable to process action '" + action + "': " + e.getMessage());
            doGet(request, response);
        }
    }
}