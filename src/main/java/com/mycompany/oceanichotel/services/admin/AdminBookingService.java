package com.mycompany.oceanichotel.services.admin;
/*
 * Copyright (c) 2025 annc19324
 * All rights reserved.
 *
 * This code is the property of annc19324.
 * Unauthorized copying or distribution is prohibited.
 */
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
        if (page < 1) {
            page = 1;
        }
        List<Booking> bookings = new ArrayList<>();
        String query = "SELECT b.*, u.full_name, u.email, r.room_number, rt.type_name " +
                      "FROM Bookings b " +
                      "JOIN Users u ON b.user_id = u.user_id " +
                      "JOIN Rooms r ON b.room_id = r.room_id " +
                      "JOIN Room_Types rt ON r.type_id = rt.type_id " +
                      "WHERE 1=1";
        if (search != null && !search.trim().isEmpty()) {
            query += " AND b.booking_id LIKE ?";
        }
        query += " ORDER BY b.created_at DESC OFFSET ? ROWS FETCH NEXT ? ROWS ONLY";

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
                booking.setNumAdults(rs.getInt("num_adults"));
                booking.setNumChildren(rs.getInt("num_children"));
                booking.setTotalPrice(rs.getBigDecimal("total_price"));
                booking.setStatus(rs.getString("status"));
                booking.setBookingMethod(rs.getString("booking_method"));
                booking.setReceptionistId(rs.getInt("receptionist_id") != 0 ? rs.getInt("receptionist_id") : null);
                booking.setCreatedAt(rs.getTimestamp("created_at"));
                booking.setUserFullName(rs.getString("full_name"));
                booking.setUserEmail(rs.getString("email"));
                booking.setRoomNumber(rs.getString("room_number"));
                booking.setRoomTypeName(rs.getString("type_name"));
                bookings.add(booking);
            }
        }
        return bookings;
    }

    // Các phương thức khác giữ nguyên
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
            if (rs.next()) {
                return rs.getInt(1);
            }
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
                if (rs.next()) {
                    oldStatus = rs.getString("status");
                } else {
                    throw new SQLException("Booking not found");
                }
            }
            if (oldStatus.equals(newStatus)) {
                LOGGER.log(Level.INFO, "No status change needed for booking {0}: {1}", new Object[]{bookingId, oldStatus});
                conn.rollback();
                return;
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
            LOGGER.log(Level.INFO, "Booking {0} updated from {1} to {2} by user {3}",
                    new Object[]{bookingId, oldStatus, newStatus, changedBy});
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error updating booking status for booking " + bookingId, e);
            throw e;
        }
    }

    public int countBookingsByStatus(String status) throws SQLException {
        String sql = "SELECT COUNT(*) FROM Bookings WHERE status = ? AND check_in_date >= CAST(GETDATE() AS DATE)";
        try (Connection conn = DatabaseUtil.getConnection(); PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, status);
            ResultSet rs = stmt.executeQuery();
            if (rs.next()) {
                return rs.getInt(1);
            }
            return 0;
        }
    }

    public int countBookingsByMethod(String method) throws SQLException {
        String sql = "SELECT COUNT(*) FROM Bookings WHERE booking_method = ? AND check_in_date >= CAST(GETDATE() AS DATE)";
        try (Connection conn = DatabaseUtil.getConnection(); PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, method);
            ResultSet rs = stmt.executeQuery();
            if (rs.next()) {
                return rs.getInt(1);
            }
            return 0;
        }
    }
    
    public void updateRoomAvailability(int roomId, boolean isAvailable) throws SQLException {
        String query = "UPDATE Rooms SET is_available = ? WHERE room_id = ?";
        try (Connection conn = DatabaseUtil.getConnection(); PreparedStatement stmt = conn.prepareStatement(query)) {
            stmt.setBoolean(1, isAvailable);
            stmt.setInt(2, roomId);
            int rowsAffected = stmt.executeUpdate();
            if (rowsAffected > 0) {
                LOGGER.log(Level.INFO, "Room {0} availability updated to {1}", new Object[]{roomId, isAvailable});
            } else {
                LOGGER.log(Level.WARNING, "Room {0} not found for availability update", new Object[]{roomId});
            }
        }
    }
}