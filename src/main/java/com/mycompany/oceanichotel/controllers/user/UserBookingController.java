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
import java.text.SimpleDateFormat;
import java.util.logging.Logger;
import java.util.logging.Level;

@WebServlet("/user/booking")
public class UserBookingController extends HttpServlet {
    private UserBookingService userBookingService;
    private static final Logger LOGGER = Logger.getLogger(UserBookingController.class.getName());

    @Override
    public void init() throws ServletException {
        userBookingService = new UserBookingService();
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        User user = (User) request.getSession().getAttribute("user");
        if (user == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        try {
            Booking booking = new Booking();
            booking.setUserId(user.getUserId());
            booking.setRoomId(Integer.parseInt(request.getParameter("roomId")));
            booking.setCheckInDate(new SimpleDateFormat("yyyy-MM-dd").parse(request.getParameter("checkIn")));
            booking.setCheckOutDate(new SimpleDateFormat("yyyy-MM-dd").parse(request.getParameter("checkOut")));
            booking.setAdults(Integer.parseInt(request.getParameter("adults")));
            booking.setChildren(Integer.parseInt(request.getParameter("children")));
            booking.setTotalPrice(userBookingService.calculateTotalPrice(booking.getRoomId(), request.getParameter("checkIn"), request.getParameter("checkOut")));
            booking.setStatus("PENDING");

            request.setAttribute("booking", booking);
            request.setAttribute("user", user);
            request.getRequestDispatcher("/WEB-INF/views/user/booking.jsp").forward(request, response);
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error processing booking", e);
            request.setAttribute("error", "Unable to process booking.");
            request.getRequestDispatcher("/WEB-INF/views/user/booking.jsp").forward(request, response);
        }
    }
}