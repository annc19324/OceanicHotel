package com.mycompany.oceanichotel.controllers.admin;

import com.mycompany.oceanichotel.services.admin.AdminReportService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.sql.SQLException;
import java.util.logging.Level;
import java.util.logging.Logger;

@WebServlet("/admin/reports/*")
public class AdminReportController extends HttpServlet {

    private AdminReportService reportService;
    private static final Logger LOGGER = Logger.getLogger(AdminReportController.class.getName());

    @Override
    public void init() throws ServletException {
        reportService = new AdminReportService();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            double dailyRevenue = reportService.getDailyRevenue();
            double monthlyRevenue = reportService.getMonthlyRevenue();
            int totalRooms = reportService.getTotalRooms();
            int availableRooms = reportService.getAvailableRooms();
            int confirmedBookings = reportService.getConfirmedBookings();
            double utilizationRate = totalRooms > 0 ? (double) (totalRooms - availableRooms) / totalRooms * 100 : 0;

            request.setAttribute("dailyRevenue", String.format("%.2f", dailyRevenue));
            request.setAttribute("monthlyRevenue", String.format("%.2f", monthlyRevenue));
            request.setAttribute("totalRooms", totalRooms);
            request.setAttribute("availableRooms", availableRooms);
            request.setAttribute("confirmedBookings", confirmedBookings);
            request.setAttribute("utilizationRate", String.format("%.2f", utilizationRate));
            request.getRequestDispatcher("/WEB-INF/views/admin/reports.jsp").forward(request, response);
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Database error in doGet", e);
            throw new ServletException("Database error", e);
        }
    }
}