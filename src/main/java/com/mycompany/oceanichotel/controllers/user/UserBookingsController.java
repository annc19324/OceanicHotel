package com.mycompany.oceanichotel.controllers.user;

import com.mycompany.oceanichotel.models.Booking;
import com.mycompany.oceanichotel.models.User;
import com.mycompany.oceanichotel.services.user.UserBookingService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.util.List;
import java.util.logging.Logger;
import java.util.logging.Level;

@WebServlet("/user/bookings")
public class UserBookingsController extends HttpServlet {
    private UserBookingService userBookingService;
    private static final Logger LOGGER = Logger.getLogger(UserBookingsController.class.getName());

    @Override
    public void init() throws ServletException {
        userBookingService = new UserBookingService();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        User user = (User) request.getSession().getAttribute("user");
        if (user == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        try {
            List<Booking> bookings = userBookingService.getUserBookings(user.getUserId());
            request.setAttribute("bookings", bookings);
            request.getRequestDispatcher("/WEB-INF/views/user/bookings.jsp").forward(request, response);
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error retrieving bookings", e);
            request.setAttribute("error", "Unable to load bookings.");
            request.getRequestDispatcher("/WEB-INF/views/user/bookings.jsp").forward(request, response);
        }
    }
}