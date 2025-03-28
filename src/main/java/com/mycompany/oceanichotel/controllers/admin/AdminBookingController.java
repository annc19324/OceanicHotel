package com.mycompany.oceanichotel.controllers.admin;

import com.mycompany.oceanichotel.models.Booking;
import com.mycompany.oceanichotel.models.User;
import com.mycompany.oceanichotel.services.admin.AdminBookingService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.sql.SQLException;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

@WebServlet("/admin/bookings/*")
public class AdminBookingController extends HttpServlet {

    private AdminBookingService bookingService;
    private static final Logger LOGGER = Logger.getLogger(AdminBookingController.class.getName());

    @Override
    public void init() throws ServletException {
        bookingService = new AdminBookingService();
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
                // Chuyển hướng đến trang lịch sử thay đổi (chưa triển khai JSP)
                response.sendRedirect(request.getContextPath() + "/admin/bookings");
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Database error in doGet", e);
            throw new ServletException("Database error", e);
        } catch (NumberFormatException e) {
            LOGGER.log(Level.WARNING, "Invalid bookingId in doGet", e);
            response.sendRedirect(request.getContextPath() + "/admin/bookings?error=invalid_input");
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String pathInfo = request.getPathInfo();
        try {
            if (pathInfo.equals("/update")) {
                int bookingId = Integer.parseInt(request.getParameter("bookingId"));
                String status = request.getParameter("status");
                bookingService.updateBookingStatus(bookingId, status, ((User) request.getSession().getAttribute("user")).getUserId());
                response.sendRedirect(request.getContextPath() + "/admin/bookings?message=update_success");
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Database error in doPost", e);
            throw new ServletException("Database error", e);
        } catch (NumberFormatException e) {
            LOGGER.log(Level.WARNING, "Invalid bookingId in doPost", e);
            response.sendRedirect(request.getContextPath() + "/admin/bookings?error=invalid_input");
        }
    }
}