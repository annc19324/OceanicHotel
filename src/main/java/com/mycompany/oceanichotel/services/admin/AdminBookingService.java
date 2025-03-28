package com.mycompany.oceanichotel.services.admin;

import com.mycompany.oceanichotel.models.Booking;
import com.mycompany.oceanichotel.utils.DatabaseUtil;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import java.util.logging.Logger;
import java.util.logging.Level;

public class AdminBookingService {

    private static final int PAGE_SIZE = 10;
    private static final Logger LOGGER = Logger.getLogger(AdminBookingService.class.getName());

    public List<Booking> getBookings(int page, String search) throws SQLException {
        if (page < 1) page = 1;
        List<Booking> bookings = new ArrayList<>();
        String query = "SELECT * FROM Bookings WHERE 1=1";
        if (search != null && !search.trim().isEmpty()) {
            query += " AND booking_id LIKE ?";
        }
        query += " ORDER BY booking_id OFFSET ? ROWS FETCH NEXT ? ROWS ONLY";

        try (Connection conn = DatabaseUtil.getConnection(); PreparedStatement stmt = conn.prepareStatement(query)) {
            int paramIndex = 1;
            if (search != null && !search.trim().isEmpty()) {
                stmt.setString(paramIndex++, "%" + search + "%");
            }
            stmt.setInt(paramIndex++, (page - 1) * PAGE_SIZE);
            stmt.setInt(paramIndex, PAGE_SIZE);

            ResultSet rs = stmt.executeQuery();
            while (rs.next()) {
                Booking booking = new Booking();
                booking.setBookingId(rs.getInt("booking_id"));
                booking.setUserId(rs.getInt("user_id"));
                booking.setRoomId(rs.getInt("room_id"));
                booking.setCheckInDate(rs.getDate("check_in_date"));
                booking.setCheckOutDate(rs.getDate("check_out_date"));
                booking.setTotalPrice(rs.getDouble("total_price"));
                booking.setStatus(rs.getString("status"));
                bookings.add(booking);
            }
        }
        return bookings;
    }

    public int getTotalBookings(String search) throws SQLException {
        String query = "SELECT COUNT(*) FROM Bookings WHERE 1=1";
        if (search != null && !search.trim().isEmpty()) {
            query += " AND booking_id LIKE ?";
        }
        try (Connection conn = DatabaseUtil.getConnection(); PreparedStatement stmt = conn.prepareStatement(query)) {
            if (search != null && !search.trim().isEmpty()) {
                stmt.setString(1, "%" + search + "%");
            }
            ResultSet rs = stmt.executeQuery();
            if (rs.next()) return rs.getInt(1);
        }
        return 0;
    }

    public void updateBookingStatus(int bookingId, String newStatus, int changedBy) throws SQLException {
        String oldStatusQuery = "SELECT status FROM Bookings WHERE booking_id = ?";
        String updateQuery = "UPDATE Bookings SET status = ? WHERE booking_id = ?";
        String historyQuery = "INSERT INTO Booking_History (booking_id, old_status, new_status, changed_by, changed_at) VALUES (?, ?, ?, ?, GETDATE())";

        try (Connection conn = DatabaseUtil.getConnection()) {
            conn.setAutoCommit(false);
            String oldStatus = null;
            try (PreparedStatement stmt = conn.prepareStatement(oldStatusQuery)) {
                stmt.setInt(1, bookingId);
                ResultSet rs = stmt.executeQuery();
                if (rs.next()) oldStatus = rs.getString("status");
            }
            try (PreparedStatement stmt = conn.prepareStatement(updateQuery)) {
                stmt.setString(1, newStatus);
                stmt.setInt(2, bookingId);
                stmt.executeUpdate();
            }
            try (PreparedStatement stmt = conn.prepareStatement(historyQuery)) {
                stmt.setInt(1, bookingId);
                stmt.setString(2, oldStatus);
                stmt.setString(3, newStatus);
                stmt.setInt(4, changedBy);
                stmt.executeUpdate();
            }
            conn.commit();
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error updating booking status", e);
            throw e;
        }
    }
}