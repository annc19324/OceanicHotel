package com.mycompany.oceanichotel.controllers.user;

import com.mycompany.oceanichotel.models.Booking;
import com.mycompany.oceanichotel.models.BookingHistory;
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

@WebServlet("/user/bookings")
public class UserBookingsController extends HttpServlet {
    private UserRoomService userRoomService;
    private static final Logger LOGGER = Logger.getLogger(UserBookingsController.class.getName());

    @Override
    public void init() throws ServletException {
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

        try {
            // Lấy danh sách đặt phòng
            List<Booking> bookings = userRoomService.getUserBookings(user.getUserId());
            LOGGER.log(Level.INFO, "Retrieved {0} bookings for userId={1}", new Object[]{bookings.size(), user.getUserId()});

            // Lấy lịch sử thay đổi trạng thái
            List<BookingHistory> history = userRoomService.getBookingHistory(user.getUserId());
            LOGGER.log(Level.INFO, "Retrieved {0} history records for userId={1}", new Object[]{history.size(), user.getUserId()});

            // Set attributes vào request
            request.setAttribute("bookings", bookings);
            request.setAttribute("history", history);

            // Forward tới JSP
            request.getRequestDispatcher("/WEB-INF/views/user/bookings.jsp").forward(request, response);
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error retrieving bookings or history for userId=" + user.getUserId(), e);
            request.setAttribute("error", "Unable to load bookings.");
            request.getRequestDispatcher("/WEB-INF/views/user/bookings.jsp").forward(request, response);
        }
    }
}