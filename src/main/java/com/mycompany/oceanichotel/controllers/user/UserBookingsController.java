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
            request.setAttribute("bookings", bookings);

            List<BookingHistory> history = userRoomService.getBookingHistory(user.getUserId());
            LOGGER.log(Level.INFO, "Retrieved {0} history records for userId={1}", new Object[]{history.size(), user.getUserId()});
            request.setAttribute("history", history);

            request.setAttribute("statusFilter", statusFilter);
            request.setAttribute("checkInFrom", checkInFrom);
            request.setAttribute("checkInTo", checkInTo);
            request.setAttribute("sortOption", sortOption);

            request.getRequestDispatcher("/WEB-INF/views/user/bookings.jsp").forward(request, response);
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error retrieving bookings or history for userId=" + user.getUserId(), e);
            request.setAttribute("error", "Unable to load bookings or history: " + e.getMessage());
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
            } else if ("confirmMoMo".equals(action)) {
                userBookingService.confirmMoMoPayment(bookingId, user.getUserId());
                LOGGER.info("MoMo payment confirmed for booking ID=" + bookingId + " by userId=" + user.getUserId());
            } else if ("payTest".equals(action)) {
                userBookingService.confirmTestPayment(bookingId, user.getUserId());
                LOGGER.info("Test payment confirmed for booking ID=" + bookingId + " by userId=" + user.getUserId());
            } else {
                LOGGER.log(Level.WARNING, "Unknown action: " + action);
                request.setAttribute("error", "Hành động không hợp lệ: " + action);
                doGet(request, response);
                return;
            }
            response.sendRedirect(request.getContextPath() + "/user/bookings");
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error processing action '" + action + "' for booking ID=" + bookingId, e);
            request.setAttribute("error", "Unable to process action '" + action + "': " + e.getMessage());
            doGet(request, response);
        } catch (NumberFormatException e) {
            LOGGER.log(Level.WARNING, "Invalid bookingId: " + request.getParameter("bookingId"), e);
            request.setAttribute("error", "ID đặt phòng không hợp lệ.");
            doGet(request, response);
        }
    }
}