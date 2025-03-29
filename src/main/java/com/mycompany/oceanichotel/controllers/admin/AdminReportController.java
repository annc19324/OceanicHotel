package com.mycompany.oceanichotel.controllers.admin;

import com.mycompany.oceanichotel.services.admin.AdminReportService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.sql.SQLException;
import java.text.SimpleDateFormat;
import java.util.Date;
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
            String reportType = request.getParameter("reportType") != null ? request.getParameter("reportType") : "daily";
            String startDateStr = request.getParameter("startDate");
            String endDateStr = request.getParameter("endDate");
            SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
            Date startDate = startDateStr != null && !startDateStr.isEmpty() ? sdf.parse(startDateStr) : null;
            Date endDate = endDateStr != null && !endDateStr.isEmpty() ? sdf.parse(endDateStr) : null;

            double totalRevenue = reportService.getRevenue(reportType, startDate, endDate);
            int totalRooms = reportService.getTotalRooms();
            int availableRooms = reportService.getAvailableRooms();
            int confirmedBookings = reportService.getConfirmedBookings(reportType, startDate, endDate);
            double utilizationRate = totalRooms > 0 ? (double) (totalRooms - availableRooms) / totalRooms * 100 : 0;

            request.setAttribute("totalRevenue", String.format("%.2f", totalRevenue));
            request.setAttribute("totalRooms", totalRooms);
            request.setAttribute("availableRooms", availableRooms);
            request.setAttribute("confirmedBookings", confirmedBookings);
            request.setAttribute("utilizationRate", String.format("%.2f", utilizationRate));
            request.getRequestDispatcher("/WEB-INF/views/admin/reports.jsp").forward(request, response);
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Database error in doGet", e);
            throw new ServletException("Database error", e);
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error parsing dates", e);
            throw new ServletException("Invalid date format", e);
        }
    }
}