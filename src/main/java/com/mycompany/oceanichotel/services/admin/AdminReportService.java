package com.mycompany.oceanichotel.services.admin;
/*
 * Copyright (c) 2025 annc19324
 * All rights reserved.
 *
 * This code is the property of annc19324.
 * Unauthorized copying or distribution is prohibited.
 */
import com.mycompany.oceanichotel.utils.DatabaseUtil;
import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.Date;
import java.util.logging.Logger;

public class AdminReportService {

    private static final Logger LOGGER = Logger.getLogger(AdminReportService.class.getName());

    public BigDecimal getRevenue(String reportType, Date startDate, Date endDate) throws SQLException { // Đổi từ double sang BigDecimal
        String query = "SELECT SUM(amount) FROM Transactions WHERE status = 'Success'";
        if (startDate != null && endDate != null) {
            query += " AND created_at BETWEEN ? AND ?";
        } else if ("daily".equals(reportType)) {
            query += " AND CONVERT(date, created_at) = CONVERT(date, GETDATE())";
        } else if ("monthly".equals(reportType)) {
            query += " AND MONTH(created_at) = MONTH(GETDATE()) AND YEAR(created_at) = YEAR(GETDATE())";
        } else if ("yearly".equals(reportType)) {
            query += " AND YEAR(created_at) = YEAR(GETDATE())";
        }

        try (Connection conn = DatabaseUtil.getConnection(); PreparedStatement stmt = conn.prepareStatement(query)) {
            if (startDate != null && endDate != null) {
                stmt.setTimestamp(1, new java.sql.Timestamp(startDate.getTime()));
                stmt.setTimestamp(2, new java.sql.Timestamp(endDate.getTime()));
            }
            ResultSet rs = stmt.executeQuery();
            if (rs.next()) {
                BigDecimal revenue = rs.getBigDecimal(1);
                return revenue != null ? revenue : BigDecimal.ZERO; // Tránh null
            }
        }
        return BigDecimal.ZERO;
    }

    public int getTotalRooms() throws SQLException {
        String query = "SELECT COUNT(*) FROM Rooms";
        try (Connection conn = DatabaseUtil.getConnection(); PreparedStatement stmt = conn.prepareStatement(query)) {
            ResultSet rs = stmt.executeQuery();
            if (rs.next()) return rs.getInt(1);
        }
        return 0;
    }

    public int getAvailableRooms() throws SQLException {
        String query = "SELECT COUNT(*) FROM Rooms WHERE is_available = 1";
        try (Connection conn = DatabaseUtil.getConnection(); PreparedStatement stmt = conn.prepareStatement(query)) {
            ResultSet rs = stmt.executeQuery();
            if (rs.next()) return rs.getInt(1);
        }
        return 0;
    }

    public int getConfirmedBookings(String reportType, Date startDate, Date endDate) throws SQLException {
        String query = "SELECT COUNT(*) FROM Bookings WHERE status = 'Confirmed'";
        if (startDate != null && endDate != null) {
            query += " AND check_in_date BETWEEN ? AND ?";
        } else if ("daily".equals(reportType)) {
            query += " AND CONVERT(date, check_in_date) = CONVERT(date, GETDATE())";
        } else if ("monthly".equals(reportType)) {
            query += " AND MONTH(check_in_date) = MONTH(GETDATE()) AND YEAR(check_in_date) = YEAR(GETDATE())";
        } else if ("yearly".equals(reportType)) {
            query += " AND YEAR(check_in_date) = YEAR(GETDATE())";
        }

        try (Connection conn = DatabaseUtil.getConnection(); PreparedStatement stmt = conn.prepareStatement(query)) {
            if (startDate != null && endDate != null) {
                stmt.setTimestamp(1, new java.sql.Timestamp(startDate.getTime()));
                stmt.setTimestamp(2, new java.sql.Timestamp(endDate.getTime()));
            }
            ResultSet rs = stmt.executeQuery();
            if (rs.next()) return rs.getInt(1);
        }
        return 0;
    }
}