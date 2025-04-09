package com.mycompany.oceanichotel.services.user;

import com.mycompany.oceanichotel.models.Booking;
import com.mycompany.oceanichotel.models.Room;
import com.mycompany.oceanichotel.models.RoomType;
import com.mycompany.oceanichotel.utils.DatabaseUtil;
import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;
import java.util.concurrent.TimeUnit;
import java.util.logging.Level;
import java.util.logging.Logger;

public class UserBookingService {

    private static final Logger LOGGER = Logger.getLogger(UserBookingService.class.getName());

    public List<Booking> getUserBookings(int userId, String statusFilter, String checkInFrom, String checkInTo, String sortOption) throws SQLException {
        List<Booking> bookings = new ArrayList<>();
        StringBuilder query = new StringBuilder(
                "SELECT b.booking_id, b.user_id, b.room_id, b.check_in_date, b.check_out_date, "
                + "b.total_price, b.status, b.num_adults, b.num_children, b.created_at, r.room_number, rt.type_name "
                + "FROM Bookings b "
                + "JOIN Rooms r ON b.room_id = r.room_id "
                + "JOIN Room_Types rt ON r.type_id = rt.type_id "
                + "WHERE b.user_id = ?"
        );

        List<String> conditions = new ArrayList<>();
        if (statusFilter != null && !statusFilter.isEmpty()) {
            conditions.add("b.status = ?");
        }
        if (checkInFrom != null && !checkInFrom.isEmpty()) {
            conditions.add("b.check_in_date >= ?");
        }
        if (checkInTo != null && !checkInTo.isEmpty()) {
            conditions.add("b.check_in_date <= ?");
        }
        if (!conditions.isEmpty()) {
            query.append(" AND ").append(String.join(" AND ", conditions));
        }

        if (sortOption != null && !sortOption.isEmpty()) {
            switch (sortOption.toLowerCase()) {
                case "newest":
                    query.append(" ORDER BY b.created_at DESC");
                    break;
                case "oldest":
                    query.append(" ORDER BY b.created_at ASC");
                    break;
                case "price_asc":
                    query.append(" ORDER BY b.total_price ASC");
                    break;
                case "price_desc":
                    query.append(" ORDER BY b.total_price DESC");
                    break;
                case "room_asc":
                    query.append(" ORDER BY r.room_number ASC");
                    break;
                case "room_desc":
                    query.append(" ORDER BY r.room_number DESC");
                    break;
                default:
                    query.append(" ORDER BY b.created_at DESC");
            }
        } else {
            query.append(" ORDER BY b.created_at DESC");
        }

        try (Connection conn = DatabaseUtil.getConnection(); PreparedStatement stmt = conn.prepareStatement(query.toString())) {
            int paramIndex = 1;
            stmt.setInt(paramIndex++, userId);
            if (statusFilter != null && !statusFilter.isEmpty()) {
                stmt.setString(paramIndex++, statusFilter);
            }
            if (checkInFrom != null && !checkInFrom.isEmpty()) {
                stmt.setDate(paramIndex++, java.sql.Date.valueOf(checkInFrom));
            }
            if (checkInTo != null && !checkInTo.isEmpty()) {
                stmt.setDate(paramIndex++, java.sql.Date.valueOf(checkInTo));
            }

            LOGGER.info("Executing query: " + query.toString());
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
                booking.setCreatedAt(rs.getTimestamp("created_at"));

                long diffInMillies = Math.abs(booking.getCheckOutDate().getTime() - booking.getCheckInDate().getTime());
                int nights = (int) TimeUnit.DAYS.convert(diffInMillies, TimeUnit.MILLISECONDS);
                booking.setNights(nights);

                long hoursUntilCheckIn = TimeUnit.HOURS.convert(booking.getCheckInDate().getTime() - new Date().getTime(), TimeUnit.MILLISECONDS);
                booking.setCanCancel(hoursUntilCheckIn > 24);
                long minutesSinceCreation = TimeUnit.MINUTES.convert(new Date().getTime() - booking.getCreatedAt().getTime(), TimeUnit.MILLISECONDS);

                if ("Pending".equals(booking.getStatus()) && booking.getCreatedAt() != null) {
                    long hoursSinceCreation = TimeUnit.HOURS.convert(new Date().getTime() - booking.getCreatedAt().getTime(), TimeUnit.MILLISECONDS);
                    if (minutesSinceCreation > 15) {
                        cancelExpiredBooking(booking.getBookingId(), userId);
                        continue;
                    }
                }

                Room room = new Room();
                room.setRoomId(rs.getInt("room_id"));
                room.setRoomNumber(rs.getString("room_number"));
                RoomType roomType = new RoomType();
                roomType.setTypeName(rs.getString("type_name"));
                room.setRoomType(roomType);
                booking.setRoom(room);

                bookings.add(booking);
            }
            LOGGER.log(Level.INFO, "Retrieved {0} bookings for userId={1}", new Object[]{bookings.size(), userId});
        }
        return bookings;
    }

    private void cancelExpiredBooking(int bookingId, int userId) throws SQLException {
        String updateQuery = "UPDATE Bookings SET status = 'Cancelled' WHERE booking_id = ? AND user_id = ? AND status = 'Pending'";
        String insertHistoryQuery = "INSERT INTO Booking_History (booking_id, changed_by, old_status, new_status, changed_at) VALUES (?, ?, ?, ?, GETDATE())";

        try (Connection conn = DatabaseUtil.getConnection()) {
            conn.setAutoCommit(false);

            try (PreparedStatement updateStmt = conn.prepareStatement(updateQuery)) {
                updateStmt.setInt(1, bookingId);
                updateStmt.setInt(2, userId);
                updateStmt.executeUpdate();
            }

            try (PreparedStatement historyStmt = conn.prepareStatement(insertHistoryQuery)) {
                historyStmt.setInt(1, bookingId);
                historyStmt.setInt(2, userId);
                historyStmt.setString(3, "Pending");
                historyStmt.setString(4, "Cancelled");
                historyStmt.executeUpdate();
            }

            conn.commit();
            LOGGER.info("Booking ID=" + bookingId + " auto-cancelled due to payment timeout.");
        }
    }

    public Booking getBookingById(int bookingId, int userId) throws SQLException {
        String query = "SELECT b.booking_id, b.total_price, b.status "
                + "FROM Bookings b WHERE b.booking_id = ? AND b.user_id = ?";
        try (Connection conn = DatabaseUtil.getConnection(); PreparedStatement stmt = conn.prepareStatement(query)) {
            stmt.setInt(1, bookingId);
            stmt.setInt(2, userId);
            ResultSet rs = stmt.executeQuery();
            if (rs.next()) {
                Booking booking = new Booking();
                booking.setBookingId(rs.getInt("booking_id"));
                booking.setTotalPrice(rs.getBigDecimal("total_price"));
                booking.setStatus(rs.getString("status"));
                return booking;
            }
            return null;
        }
    }

    public int createTransaction(int bookingId, int userId, double amount) throws SQLException {
        String query = "INSERT INTO Transactions (booking_id, user_id, amount, status) VALUES (?, ?, ?, 'Pending')";
        try (Connection conn = DatabaseUtil.getConnection(); PreparedStatement stmt = conn.prepareStatement(query, PreparedStatement.RETURN_GENERATED_KEYS)) {
            stmt.setInt(1, bookingId);
            stmt.setInt(2, userId);
            stmt.setBigDecimal(3, BigDecimal.valueOf(amount)); // Chuyển double thành BigDecimal
            stmt.executeUpdate();

            ResultSet rs = stmt.getGeneratedKeys();
            if (rs.next()) {
                return rs.getInt(1); // Trả về transaction_id
            }
            throw new SQLException("Failed to retrieve transaction ID.");
        }
    }

    public boolean hasPendingMoMoTransaction(int bookingId) throws SQLException {
        String query = "SELECT COUNT(*) FROM Transactions WHERE booking_id = ? AND status = 'Pending'";
        try (Connection conn = DatabaseUtil.getConnection(); PreparedStatement stmt = conn.prepareStatement(query)) {
            stmt.setInt(1, bookingId);
            ResultSet rs = stmt.executeQuery();
            if (rs.next()) {
                return rs.getInt(1) > 0;
            }
            return false;
        }
    }

    public void confirmMoMoPayment(int bookingId, int userId) throws SQLException {
        String updateBookingQuery = "UPDATE Bookings SET status = 'Confirmed' WHERE booking_id = ? AND user_id = ? AND status = 'Pending'";
        String updateTransactionQuery = "UPDATE Transactions SET status = 'Success' WHERE booking_id = ? AND status = 'Pending'";
        String insertHistoryQuery = "INSERT INTO Booking_History (booking_id, changed_by, old_status, new_status, changed_at) VALUES (?, ?, ?, ?, GETDATE())";

        try (Connection conn = DatabaseUtil.getConnection()) {
            conn.setAutoCommit(false);

            try (PreparedStatement updateStmt = conn.prepareStatement(updateBookingQuery)) {
                updateStmt.setInt(1, bookingId);
                updateStmt.setInt(2, userId);
                int rowsAffected = updateStmt.executeUpdate();
                if (rowsAffected == 0) {
                    throw new SQLException("Booking not found or not in Pending status.");
                }
            }

            try (PreparedStatement updateTransStmt = conn.prepareStatement(updateTransactionQuery)) {
                updateTransStmt.setInt(1, bookingId);
                int rowsAffected = updateTransStmt.executeUpdate();
                if (rowsAffected == 0) {
                    throw new SQLException("No pending MoMo transaction found.");
                }
            }

            try (PreparedStatement historyStmt = conn.prepareStatement(insertHistoryQuery)) {
                historyStmt.setInt(1, bookingId);
                historyStmt.setInt(2, userId);
                historyStmt.setString(3, "Pending");
                historyStmt.setString(4, "Confirmed");
                historyStmt.executeUpdate();
            }

            conn.commit();
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error confirming MoMo payment for booking ID=" + bookingId, e);
            throw e;
        }
    }

    public void confirmBooking(int bookingId, int userId) throws SQLException {
        String updateQuery = "UPDATE Bookings SET status = 'Confirmed' WHERE booking_id = ? AND user_id = ? AND status = 'Pending'";
        String insertHistoryQuery = "INSERT INTO Booking_History (booking_id, changed_by, old_status, new_status, changed_at) VALUES (?, ?, ?, ?, GETDATE())";

        try (Connection conn = DatabaseUtil.getConnection()) {
            conn.setAutoCommit(false);

            try (PreparedStatement updateStmt = conn.prepareStatement(updateQuery)) {
                updateStmt.setInt(1, bookingId);
                updateStmt.setInt(2, userId);
                int rowsAffected = updateStmt.executeUpdate();
                if (rowsAffected == 0) {
                    throw new SQLException("Booking not found or already confirmed/cancelled.");
                }
            }

            try (PreparedStatement historyStmt = conn.prepareStatement(insertHistoryQuery)) {
                historyStmt.setInt(1, bookingId);
                historyStmt.setInt(2, userId);
                historyStmt.setString(3, "Pending");
                historyStmt.setString(4, "Confirmed");
                historyStmt.executeUpdate();
            }

            conn.commit();
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error confirming booking ID=" + bookingId, e);
            throw e;
        }
    }

    public BigDecimal calculateTotalPrice(int roomId, String checkIn, String checkOut) throws SQLException {
        String query = "SELECT price_per_night FROM Rooms WHERE room_id = ?";
        try (Connection conn = DatabaseUtil.getConnection(); PreparedStatement stmt = conn.prepareStatement(query)) {
            stmt.setInt(1, roomId);
            ResultSet rs = stmt.executeQuery();
            if (rs.next()) {
                BigDecimal pricePerNight = rs.getBigDecimal("price_per_night");
                long diffInMillies = Math.abs(new SimpleDateFormat("yyyy-MM-dd").parse(checkOut).getTime() - new SimpleDateFormat("yyyy-MM-dd").parse(checkIn).getTime());
                long nights = TimeUnit.DAYS.convert(diffInMillies, TimeUnit.MILLISECONDS);
                return pricePerNight.multiply(BigDecimal.valueOf(nights));
            }
            return BigDecimal.ZERO;
        } catch (Exception e) {
            throw new SQLException("Error calculating total price", e);
        }
    }

    public boolean isRoomAvailable(int roomId, Date checkInDate, Date checkOutDate) throws SQLException {
        String query = "SELECT COUNT(*) FROM Bookings "
                + "WHERE room_id = ? AND status != 'Cancelled' "
                + "AND (check_in_date < ? AND check_out_date > ?)";
        try (Connection conn = DatabaseUtil.getConnection(); PreparedStatement stmt = conn.prepareStatement(query)) {
            stmt.setInt(1, roomId);
            stmt.setDate(2, new java.sql.Date(checkOutDate.getTime()));
            stmt.setDate(3, new java.sql.Date(checkInDate.getTime()));
            ResultSet rs = stmt.executeQuery();
            if (rs.next()) {
                return rs.getInt(1) == 0;
            }
            return true;
        }
    }

    public void saveBooking(Booking booking) throws SQLException {
        if (!isRoomAvailable(booking.getRoomId(), booking.getCheckInDate(), booking.getCheckOutDate())) {
            throw new SQLException("Room is not available for the selected dates.");
        }

        String query = "INSERT INTO Bookings (user_id, room_id, check_in_date, check_out_date, num_adults, num_children, total_price, status, created_at) "
                + "VALUES (?, ?, ?, ?, ?, ?, ?, ?, GETDATE())";
        try (Connection conn = DatabaseUtil.getConnection(); PreparedStatement stmt = conn.prepareStatement(query)) {
            stmt.setInt(1, booking.getUserId());
            stmt.setInt(2, booking.getRoomId());
            stmt.setDate(3, new java.sql.Date(booking.getCheckInDate().getTime()));
            stmt.setDate(4, new java.sql.Date(booking.getCheckOutDate().getTime()));
            stmt.setInt(5, booking.getNumAdults());
            stmt.setInt(6, booking.getNumChildren());
            stmt.setBigDecimal(7, booking.getTotalPrice());
            stmt.setString(8, booking.getStatus());
            stmt.executeUpdate();
            LOGGER.info("Booking saved for roomId=" + booking.getRoomId());
        }
    }
}