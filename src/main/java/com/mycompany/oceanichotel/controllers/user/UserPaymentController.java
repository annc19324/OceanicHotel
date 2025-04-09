//package com.mycompany.oceanichotel.controllers.user;
//
//import com.mycompany.oceanichotel.models.Booking;
//import com.mycompany.oceanichotel.models.User;
//import com.mycompany.oceanichotel.services.user.UserBookingService;
//import jakarta.servlet.ServletException;
//import jakarta.servlet.annotation.WebServlet;
//import jakarta.servlet.http.HttpServlet;
//import jakarta.servlet.http.HttpServletRequest;
//import jakarta.servlet.http.HttpServletResponse;
//import java.io.IOException;
//import java.util.logging.Logger;
//import java.util.logging.Level;
//
//@WebServlet("/user/payment")
//public class UserPaymentController extends HttpServlet {
//    private UserBookingService userBookingService;
//    private static final Logger LOGGER = Logger.getLogger(UserPaymentController.class.getName());
//
//    @Override
//    public void init() throws ServletException {
//        userBookingService = new UserBookingService();
//    }
//
//    @Override
//    protected void doPost(HttpServletRequest request, HttpServletResponse response)
//            throws ServletException, IOException {
//        User user = (User) request.getSession().getAttribute("user");
//        if (user == null) {
//            response.sendRedirect(request.getContextPath() + "/login");
//            return;
//        }
//
//        try {
//            Booking booking = new Booking();
//            booking.setUserId(user.getUserId());
//            booking.setRoomId(Integer.parseInt(request.getParameter("roomId")));
//            booking.setCheckInDate(new java.text.SimpleDateFormat("yyyy-MM-dd").parse(request.getParameter("checkIn")));
//            booking.setCheckOutDate(new java.text.SimpleDateFormat("yyyy-MM-dd").parse(request.getParameter("checkOut")));
//            booking.setAdults(Integer.parseInt(request.getParameter("adults")));
//            booking.setChildren(Integer.parseInt(request.getParameter("children")));
//            booking.setTotalPrice(Double.parseDouble(request.getParameter("totalPrice")));
//            booking.setStatus("PENDING");
//
//            userBookingService.saveBooking(booking); // Lưu booking vào DB
//            request.setAttribute("booking", booking);
//            request.getRequestDispatcher("/WEB-INF/views/user/payment.jsp").forward(request, response);
//        } catch (Exception e) {
//            LOGGER.log(Level.SEVERE, "Error processing payment", e);
//            request.setAttribute("error", "Unable to process payment.");
//            request.getRequestDispatcher("/WEB-INF/views/user/payment.jsp").forward(request, response);
//        }
//    }
//}