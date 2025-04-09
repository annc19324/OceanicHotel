package com.mycompany.oceanichotel.controllers.receptionist;

import com.mycompany.oceanichotel.models.User;
import com.mycompany.oceanichotel.services.admin.AdminBookingService;
import com.mycompany.oceanichotel.services.admin.AdminRoomService;
import com.mycompany.oceanichotel.utils.DatabaseUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.logging.Logger;
import java.util.logging.Level;

@WebServlet("/receptionist/dashboard")
public class ReceptionistDashboardController extends HttpServlet {

    private AdminBookingService bookingService;
    private AdminRoomService roomService;
    private static final Logger LOGGER = Logger.getLogger(ReceptionistDashboardController.class.getName());

    @Override
    public void init() throws ServletException {
        bookingService = new AdminBookingService();
        roomService = new AdminRoomService();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session != null && session.getAttribute("user") != null) {
            User user = (User) session.getAttribute("user");
            if ("receptionist".equals(user.getRole())) {
                try {
                    int pendingBookings = bookingService.countBookingsByStatus("Pending");
                    int confirmedBookings = bookingService.countBookingsByStatus("Confirmed");
                    int onlineBookings = bookingService.countBookingsByMethod("Online");
                    int onsiteBookings = bookingService.countBookingsByMethod("Onsite");
                    int availableRooms = roomService.countAvailableRooms();
                    int occupiedRooms = roomService.countOccupiedRooms();
                    int todayBookings = countTodayBookings(); // Thêm số lượng đặt phòng hôm nay

                    request.setAttribute("pendingBookings", pendingBookings);
                    request.setAttribute("confirmedBookings", confirmedBookings);
                    request.setAttribute("onlineBookings", onlineBookings);
                    request.setAttribute("onsiteBookings", onsiteBookings);
                    request.setAttribute("availableRooms", availableRooms);
                    request.setAttribute("occupiedRooms", occupiedRooms);
                    request.setAttribute("todayBookings", todayBookings);
                } catch (SQLException e) {
                    LOGGER.log(Level.SEVERE, "Error retrieving dashboard data", e);
                    request.setAttribute("error", "Unable to load dashboard data due to a database error.");
                }
                request.getRequestDispatcher("/WEB-INF/views/receptionist/dashboard.jsp").forward(request, response);
                return;
            }
        }
        LOGGER.info("User not logged in or not a receptionist, redirecting to login.");
        response.sendRedirect(request.getContextPath() + "/receptionist/login");
    }

    private int countTodayBookings() throws SQLException {
        String sql = "SELECT COUNT(*) FROM Bookings WHERE CAST(created_at AS DATE) = CAST(GETDATE() AS DATE)";
        try (Connection conn = DatabaseUtil.getConnection(); PreparedStatement stmt = conn.prepareStatement(sql)) {
            ResultSet rs = stmt.executeQuery();
            return rs.next() ? rs.getInt(1) : 0;
        }
    }
}