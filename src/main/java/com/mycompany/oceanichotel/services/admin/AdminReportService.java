package com.mycompany.oceanichotel.services.admin;

import com.mycompany.oceanichotel.utils.DatabaseUtil;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.logging.Logger;
import java.util.logging.Level;

public class AdminReportService {

    private static final Logger LOGGER = Logger.getLogger(AdminReportService.class.getName());

    public double getDailyRevenue() throws SQLException {
        String query = "SELECT SUM(amount) FROM Transactions WHERE status = 'Success' AND CONVERT(date, created_at) = CONVERT(date, GETDATE())";
        try (Connection conn = DatabaseUtil.getConnection(); PreparedStatement stmt = conn.prepareStatement(query)) {
            ResultSet rs = stmt.executeQuery();
            if (rs.next()) return rs.getDouble(1);
        }
        return 0;
    }

    public double getMonthlyRevenue() throws SQLException {
        String query = "SELECT SUM(amount) FROM Transactions WHERE status = 'Success' AND MONTH(created_at) = MONTH(GETDATE()) AND YEAR(created_at) = YEAR(GETDATE())";
        try (Connection conn = DatabaseUtil.getConnection(); PreparedStatement stmt = conn.prepareStatement(query)) {
            ResultSet rs = stmt.executeQuery();
            if (rs.next()) return rs.getDouble(1);
        }
        return 0;
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

    public int getConfirmedBookings() throws SQLException {
        String query = "SELECT COUNT(*) FROM Bookings WHERE status = 'Confirmed'";
        try (Connection conn = DatabaseUtil.getConnection(); PreparedStatement stmt = conn.prepareStatement(query)) {
            ResultSet rs = stmt.executeQuery();
            if (rs.next()) return rs.getInt(1);
        }
        return 0;
    }
}