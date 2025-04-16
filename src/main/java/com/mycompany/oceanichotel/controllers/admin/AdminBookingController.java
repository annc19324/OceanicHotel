
package com.mycompany.oceanichotel.controllers.admin;
/*
 * Copyright (c) 2025 annc19324
 * All rights reserved.
 *
 * This code is the property of annc19324.
 * Unauthorized copying or distribution is prohibited.
 */
import com.mycompany.oceanichotel.models.Booking;
import com.mycompany.oceanichotel.models.Transaction;
import com.mycompany.oceanichotel.models.User;
import com.mycompany.oceanichotel.services.admin.AdminBookingService;
import com.mycompany.oceanichotel.services.admin.AdminTransactionService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.util.Date;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

@WebServlet("/admin/bookings/*")
public class AdminBookingController extends HttpServlet {

    private AdminBookingService bookingService;
    private AdminTransactionService transactionService;
    private static final Logger LOGGER = Logger.getLogger(AdminBookingController.class.getName());

    @Override
    public void init() throws ServletException {
        bookingService = new AdminBookingService();
        transactionService = new AdminTransactionService();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String pathInfo = request.getPathInfo();
        try {
            if (pathInfo == null || pathInfo.equals("/")) {
                int page = request.getParameter("page") != null ? Integer.parseInt(request.getParameter("page")) : 1;
                String search = request.getParameter("search");

                List<Booking> bookings = bookingService.getBookings(page, search);
                int totalBookings = bookingService.getTotalBookings(search);
                int totalPages = (int) Math.ceil((double) totalBookings / 10);

                request.setAttribute("bookings", bookings);
                request.setAttribute("currentPage", page);
                request.setAttribute("totalPages", totalPages);
                request.getRequestDispatcher("/WEB-INF/views/admin/bookings.jsp").forward(request, response);
            } else if (pathInfo.equals("/history")) {
                int bookingId = Integer.parseInt(request.getParameter("bookingId"));
                response.sendRedirect(request.getContextPath() + "/admin/bookings");
            } else if (pathInfo.equals("/update")) {
                handleUpdate(request, response);
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Database error in doGet", e);
            throw new ServletException("Database error", e);
        } catch (NumberFormatException e) {
            LOGGER.log(Level.WARNING, "Invalid page or bookingId in doGet: " + request.getParameter("page"), e);
            response.sendRedirect(request.getContextPath() + "/admin/bookings?error=invalid_input");
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String pathInfo = request.getPathInfo();
        if (pathInfo != null && pathInfo.equals("/update")) {
            handleUpdate(request, response);
        } else {
            LOGGER.log(Level.WARNING, "Invalid pathInfo in doPost: " + pathInfo);
            response.sendRedirect(request.getContextPath() + "/admin/bookings?error=invalid_request");
        }
    }

    private void handleUpdate(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            String bookingIdParam = request.getParameter("bookingId");
            String status = request.getParameter("status");

            if (bookingIdParam == null || bookingIdParam.trim().isEmpty()) {
                LOGGER.log(Level.WARNING, "Booking ID is null or empty in handleUpdate");
                response.sendRedirect(request.getContextPath() + "/admin/bookings?error=missing_booking_id");
                return;
            }

            int bookingId = Integer.parseInt(bookingIdParam);
            if (status == null || (!status.equals("Confirmed") && !status.equals("Cancelled"))) {
                LOGGER.log(Level.WARNING, "Invalid status received: " + status);
                response.sendRedirect(request.getContextPath() + "/admin/bookings?error=invalid_status");
                return;
            }

            User user = (User) request.getSession().getAttribute("user");
            if (user == null) {
                LOGGER.log(Level.WARNING, "No user in session for booking update");
                response.sendRedirect(request.getContextPath() + "/login?error=session_expired");
                return;
            }

            List<Booking> bookings = bookingService.getBookings(1, String.valueOf(bookingId));
            if (bookings.isEmpty()) {
                LOGGER.log(Level.WARNING, "Booking not found for ID: " + bookingId);
                response.sendRedirect(request.getContextPath() + "/admin/bookings?error=booking_not_found");
                return;
            }

            Booking booking = bookings.get(0);
            String currentStatus = booking.getStatus();

            if (currentStatus.equals("Cancelled") && status.equals("Confirmed")) {
                LOGGER.log(Level.WARNING, "Cannot change status from Cancelled to Confirmed for booking: " + bookingId);
                response.sendRedirect(request.getContextPath() + "/admin/bookings?error=invalid_status_transition");
                return;
            }

            // Cập nhật trạng thái booking
            bookingService.updateBookingStatus(bookingId, status, user.getUserId());

            // Logic bổ sung
            if (status.equals("Confirmed") && !currentStatus.equals("Confirmed")) {
                Transaction transaction = new Transaction();
                transaction.setBookingId(bookingId);
                transaction.setUserId(booking.getUserId());
                transaction.setAmount(booking.getTotalPrice());
                transaction.setStatus("Pending");
                transaction.setPaymentMethod("Online");
                transaction.setCreatedAt(new Timestamp(System.currentTimeMillis()));
                transaction.setReceptionistId(user.getUserId());
                transaction.setUserFullName(booking.getUserFullName());
                transaction.setUserEmail(booking.getUserEmail());
                transaction.setRoomNumber(booking.getRoomNumber());
                transaction.setRoomTypeName(booking.getRoomTypeName());

                transactionService.createTransaction(transaction);
                LOGGER.log(Level.INFO, "Pending transaction created for booking: " + bookingId);

                // Kiểm tra check-out để tự động đặt phòng thành trống
                if (booking.getCheckOutDate().before(new Date())) {
                    bookingService.updateRoomAvailability(booking.getRoomId(), true);
                    LOGGER.log(Level.INFO, "Room " + booking.getRoomId() + " set to Available after check-out for booking: " + bookingId);
                }
            } else if (status.equals("Cancelled") && !currentStatus.equals("Cancelled")) {
                bookingService.updateRoomAvailability(booking.getRoomId(), true);
                LOGGER.log(Level.INFO, "Room " + booking.getRoomId() + " set to Available for booking: " + bookingId);
            }

            response.sendRedirect(request.getContextPath() + "/admin/bookings?message=update_success");
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Database error in handleUpdate for bookingId: " + request.getParameter("bookingId"), e);
            throw new ServletException("Database error", e);
        } catch (NumberFormatException e) {
            LOGGER.log(Level.WARNING, "Invalid bookingId in handleUpdate: " + request.getParameter("bookingId"), e);
            response.sendRedirect(request.getContextPath() + "/admin/bookings?error=invalid_booking_id");
        }
    }
}