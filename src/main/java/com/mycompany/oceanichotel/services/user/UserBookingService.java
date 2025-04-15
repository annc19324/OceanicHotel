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
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.Date;
import java.util.List;
import java.util.concurrent.TimeUnit;
import java.util.logging.Level;
import java.util.logging.Logger;

public class UserBookingService {

    private static final Logger LOGGER = Logger.getLogger(UserBookingService.class.getName());

    public Room getRoomById(int roomId) throws SQLException {
        String query = "SELECT r.room_id, r.room_number, r.type_id, r.price_per_night, "
                + "r.max_adults, r.max_children, r.description, r.is_available, r.created_at "
                + "FROM Rooms r WHERE r.room_id = ?";
        try (Connection conn = DatabaseUtil.getConnection(); PreparedStatement stmt = conn.prepareStatement(query)) {
            stmt.setInt(1, roomId);
            ResultSet rs = stmt.executeQuery();
            if (rs.next()) {
                Room room = new Room();
                room.setRoomId(rs.getInt("room_id"));
                room.setRoomNumber(rs.getString("room_number"));
                room.setPricePerNight(rs.getBigDecimal("price_per_night"));
                room.setMaxAdults(rs.getInt("max_adults"));
                room.setMaxChildren(rs.getInt("max_children"));
                room.setDescription(rs.getString("description"));
                room.setAvailable(rs.getBoolean("is_available"));
                room.setCreatedAt(rs.getTimestamp("created_at"));
                return room;
            }
            return null;
        }
    }

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
                case "newest": query.append(" ORDER BY b.created_at DESC"); break;
                case "oldest": query.append(" ORDER BY b.created_at ASC"); break;
                case "price_asc": query.append(" ORDER BY b.total_price ASC"); break;
                case "price_desc": query.append(" ORDER BY b.total_price DESC"); break;
                case "room_asc": query.append(" ORDER BY r.room_number ASC"); break;
                case "room_desc": query.append(" ORDER BY r.room_number DESC"); break;
                default: query.append(" ORDER BY b.created_at DESC");
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

                if ("Pending".equals(booking.getStatus()) && minutesSinceCreation > 5) {
                    cancelExpiredBooking(booking.getBookingId(), userId);
                    continue;
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
        try (Connection conn = DatabaseUtil.getConnection()) {
            conn.setAutoCommit(false);

            String updateBookingQuery = "UPDATE Bookings SET status = 'Cancelled' WHERE booking_id = ? AND user_id = ? AND status = 'Pending'";
            try (PreparedStatement stmt = conn.prepareStatement(updateBookingQuery)) {
                stmt.setInt(1, bookingId);
                stmt.setInt(2, userId);
                stmt.executeUpdate();
            }

            String updateRoomQuery = "UPDATE Rooms SET is_available = 1 WHERE room_id = (SELECT room_id FROM Bookings WHERE booking_id = ?)";
            try (PreparedStatement stmt = conn.prepareStatement(updateRoomQuery)) {
                stmt.setInt(1, bookingId);
                stmt.executeUpdate();
            }

            String updateTransactionQuery = "UPDATE Transactions SET status = 'Failed' WHERE booking_id = ? AND status = 'Pending'";
            try (PreparedStatement stmt = conn.prepareStatement(updateTransactionQuery)) {
                stmt.setInt(1, bookingId);
                stmt.executeUpdate();
            }

            String insertHistoryQuery = "INSERT INTO Booking_History (booking_id, changed_by, old_status, new_status, changed_at) VALUES (?, ?, 'Pending', 'Cancelled', GETDATE())";
            try (PreparedStatement stmt = conn.prepareStatement(insertHistoryQuery)) {
                stmt.setInt(1, bookingId);
                stmt.setInt(2, userId);
                stmt.executeUpdate();
            }

            conn.commit();
            LOGGER.info("Booking ID=" + bookingId + " and associated transaction auto-cancelled due to payment timeout after 5 minutes.");
        }
    }

    public Booking getBookingById(int bookingId, int userId) throws SQLException {
        String query = "SELECT b.booking_id, b.user_id, b.total_price, b.status "
                + "FROM Bookings b WHERE b.booking_id = ?" + (userId != -1 ? " AND b.user_id = ?" : "");
        try (Connection conn = DatabaseUtil.getConnection(); PreparedStatement stmt = conn.prepareStatement(query)) {
            stmt.setInt(1, bookingId);
            if (userId != -1) {
                stmt.setInt(2, userId);
            }
            ResultSet rs = stmt.executeQuery();
            if (rs.next()) {
                Booking booking = new Booking();
                booking.setBookingId(rs.getInt("booking_id"));
                booking.setUserId(rs.getInt("user_id"));
                booking.setTotalPrice(rs.getBigDecimal("total_price"));
                booking.setStatus(rs.getString("status"));
                return booking;
            }
            return null;
        }
    }

    public int getUserIdByBookingId(int bookingId) throws SQLException {
        String query = "SELECT user_id FROM Bookings WHERE booking_id = ?";
        try (Connection conn = DatabaseUtil.getConnection(); PreparedStatement stmt = conn.prepareStatement(query)) {
            stmt.setInt(1, bookingId);
            ResultSet rs = stmt.executeQuery();
            if (rs.next()) {
                return rs.getInt("user_id");
            }
            return -1;
        }
    }

    public void confirmMoMoPayment(int bookingId, int userId) throws SQLException {
        try (Connection conn = DatabaseUtil.getConnection()) {
            conn.setAutoCommit(false);

            String updateBookingQuery = "UPDATE Bookings SET status = 'Confirmed' WHERE booking_id = ? AND user_id = ? AND status = 'Pending'";
            try (PreparedStatement stmt = conn.prepareStatement(updateBookingQuery)) {
                stmt.setInt(1, bookingId);
                stmt.setInt(2, userId);
                int rowsAffected = stmt.executeUpdate();
                if (rowsAffected == 0) {
                    throw new SQLException("Booking not found or not in Pending status.");
                }
            }

            String updateTransactionQuery = "UPDATE Transactions SET status = 'Success' WHERE booking_id = ? AND status = 'Pending'";
            try (PreparedStatement stmt = conn.prepareStatement(updateTransactionQuery)) {
                stmt.setInt(1, bookingId);
                int rowsAffected = stmt.executeUpdate();
                if (rowsAffected == 0) {
                    throw new SQLException("No pending MoMo transaction found.");
                }
            }

            String insertHistoryQuery = "INSERT INTO Booking_History (booking_id, changed_by, old_status, new_status, changed_at) VALUES (?, ?, 'Pending', 'Confirmed', GETDATE())";
            try (PreparedStatement stmt = conn.prepareStatement(insertHistoryQuery)) {
                stmt.setInt(1, bookingId);
                stmt.setInt(2, userId);
                stmt.executeUpdate();
            }

            conn.commit();
            LOGGER.info("MoMo payment confirmed for booking ID=" + bookingId);
        }
    }

    public void confirmTestPayment(int bookingId, int userId) throws SQLException {
        try (Connection conn = DatabaseUtil.getConnection()) {
            conn.setAutoCommit(false);

            String updateBookingQuery = "UPDATE Bookings SET status = 'Confirmed' WHERE booking_id = ? AND user_id = ? AND status = 'Pending'";
            try (PreparedStatement stmt = conn.prepareStatement(updateBookingQuery)) {
                stmt.setInt(1, bookingId);
                stmt.setInt(2, userId);
                int rowsAffected = stmt.executeUpdate();
                if (rowsAffected == 0) {
                    throw new SQLException("Booking not found or not in Pending status.");
                }
            }

            String updateTransactionQuery = "UPDATE Transactions SET status = 'Success' WHERE booking_id = ? AND status = 'Pending'";
            try (PreparedStatement stmt = conn.prepareStatement(updateTransactionQuery)) {
                stmt.setInt(1, bookingId);
                int rowsAffected = stmt.executeUpdate();
                if (rowsAffected == 0) {
                    throw new SQLException("No pending Test transaction found.");
                }
            }

            String insertHistoryQuery = "INSERT INTO Booking_History (booking_id, changed_by, old_status, new_status, changed_at) VALUES (?, ?, 'Pending', 'Confirmed', GETDATE())";
            try (PreparedStatement stmt = conn.prepareStatement(insertHistoryQuery)) {
                stmt.setInt(1, bookingId);
                stmt.setInt(2, userId);
                stmt.executeUpdate();
            }

            conn.commit();
            LOGGER.info("Test payment confirmed for booking ID=" + bookingId);
        }
    }

    public BigDecimal calculateTotalPrice(int roomId, String checkIn, String checkOut) throws SQLException, ParseException {
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
        }
    }

    public boolean isRoomAvailable(int roomId, Date checkInDate, Date checkOutDate) throws SQLException {
        Calendar today = Calendar.getInstance();
        today.set(Calendar.HOUR_OF_DAY, 0);
        today.set(Calendar.MINUTE, 0);
        today.set(Calendar.SECOND, 0);
        today.set(Calendar.MILLISECOND, 0);
        Calendar minCheckIn = (Calendar) today.clone();
        minCheckIn.add(Calendar.DATE, 2);
        Calendar maxCheckIn = (Calendar) today.clone();
        maxCheckIn.add(Calendar.DATE, 7);

        if (checkInDate.before(minCheckIn.getTime()) || checkInDate.after(maxCheckIn.getTime())) {
            return false;
        }

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

    public void bookRoom(Booking booking) throws SQLException {
        if (!isRoomAvailable(booking.getRoomId(), booking.getCheckInDate(), booking.getCheckOutDate())) {
            throw new SQLException("Room is not available for the selected dates.");
        }

        try (Connection conn = DatabaseUtil.getConnection()) {
            conn.setAutoCommit(false);

            String query = "INSERT INTO Bookings (user_id, room_id, check_in_date, check_out_date, num_adults, num_children, total_price, status, created_at) "
                    + "VALUES (?, ?, ?, ?, ?, ?, ?, ?, GETDATE())";
            try (PreparedStatement stmt = conn.prepareStatement(query, PreparedStatement.RETURN_GENERATED_KEYS)) {
                stmt.setInt(1, booking.getUserId());
                stmt.setInt(2, booking.getRoomId());
                stmt.setDate(3, new java.sql.Date(booking.getCheckInDate().getTime()));
                stmt.setDate(4, new java.sql.Date(booking.getCheckOutDate().getTime()));
                stmt.setInt(5, booking.getNumAdults());
                stmt.setInt(6, booking.getNumChildren());
                stmt.setBigDecimal(7, booking.getTotalPrice());
                stmt.setString(8, booking.getStatus());
                stmt.executeUpdate();

                ResultSet rs = stmt.getGeneratedKeys();
                if (rs.next()) {
                    booking.setBookingId(rs.getInt(1));
                }
            }

            String transactionQuery = "INSERT INTO Transactions (booking_id, user_id, amount, status, payment_method, created_at) "
                    + "VALUES (?, ?, ?, 'Pending', 'Online', GETDATE())";
            try (PreparedStatement stmt = conn.prepareStatement(transactionQuery)) {
                stmt.setInt(1, booking.getBookingId());
                stmt.setInt(2, booking.getUserId());
                stmt.setBigDecimal(3, booking.getTotalPrice());
                stmt.executeUpdate();
            }

            String updateRoomQuery = "UPDATE Rooms SET is_available = 0 WHERE room_id = ?";
            try (PreparedStatement stmt = conn.prepareStatement(updateRoomQuery)) {
                stmt.setInt(1, booking.getRoomId());
                stmt.executeUpdate();
            }

            String insertHistoryQuery = "INSERT INTO Booking_History (booking_id, changed_by, old_status, new_status, changed_at) VALUES (?, ?, NULL, 'Pending', GETDATE())";
            try (PreparedStatement stmt = conn.prepareStatement(insertHistoryQuery)) {
                stmt.setInt(1, booking.getBookingId());
                stmt.setInt(2, booking.getUserId());
                stmt.executeUpdate();
            }

            conn.commit();
            LOGGER.info("Booking saved and transaction created with status 'Pending' for roomId=" + booking.getRoomId());
        }
    }

    public void confirmPayOSPayment(int bookingId, int userId) throws SQLException {
        try (Connection conn = DatabaseUtil.getConnection()) {
            conn.setAutoCommit(false);

            String updateBookingQuery = "UPDATE Bookings SET status = 'Confirmed' WHERE booking_id = ? AND user_id = ? AND status = 'Pending'";
            try (PreparedStatement stmt = conn.prepareStatement(updateBookingQuery)) {
                stmt.setInt(1, bookingId);
                stmt.setInt(2, userId);
                int rowsAffected = stmt.executeUpdate();
                if (rowsAffected == 0) {
                    throw new SQLException("Booking not found or not in Pending status.");
                }
            }

            String updateTransactionQuery = "UPDATE Transactions SET status = 'Success' WHERE booking_id = ? AND status = 'Pending'";
            try (PreparedStatement stmt = conn.prepareStatement(updateTransactionQuery)) {
                stmt.setInt(1, bookingId);
                int rowsAffected = stmt.executeUpdate();
                if (rowsAffected == 0) {
                    throw new SQLException("No pending PayOS transaction found.");
                }
            }

            String insertHistoryQuery = "INSERT INTO Booking_History (booking_id, changed_by, old_status, new_status, changed_at) VALUES (?, ?, 'Pending', 'Confirmed', GETDATE())";
            try (PreparedStatement stmt = conn.prepareStatement(insertHistoryQuery)) {
                stmt.setInt(1, bookingId);
                stmt.setInt(2, userId);
                stmt.executeUpdate();
            }

            conn.commit();
            LOGGER.info("PayOS payment confirmed for booking ID=" + bookingId + ", user ID=" + userId);
        }
    }

    public void cancelBooking(int bookingId, int userId) throws SQLException {
        try (Connection conn = DatabaseUtil.getConnection()) {
            conn.setAutoCommit(false);

            String updateBookingQuery = "UPDATE Bookings SET status = 'Cancelled' WHERE booking_id = ? AND user_id = ? AND status = 'Pending'";
            try (PreparedStatement stmt = conn.prepareStatement(updateBookingQuery)) {
                stmt.setInt(1, bookingId);
                stmt.setInt(2, userId);
                int rowsAffected = stmt.executeUpdate();
                if (rowsAffected == 0) {
                    throw new SQLException("Booking not found or not in Pending status.");
                }
            }

            String updateRoomQuery = "UPDATE Rooms SET is_available = 1 WHERE room_id = (SELECT room_id FROM Bookings WHERE booking_id = ?)";
            try (PreparedStatement stmt = conn.prepareStatement(updateRoomQuery)) {
                stmt.setInt(1, bookingId);
                stmt.executeUpdate();
            }

            String updateTransactionQuery = "UPDATE Transactions SET status = 'Failed' WHERE booking_id = ? AND status = 'Pending'";
            try (PreparedStatement stmt = conn.prepareStatement(updateTransactionQuery)) {
                stmt.setInt(1, bookingId);
                stmt.executeUpdate();
            }

            String insertHistoryQuery = "INSERT INTO Booking_History (booking_id, changed_by, old_status, new_status, changed_at) VALUES (?, ?, 'Pending', 'Cancelled', GETDATE())";
            try (PreparedStatement stmt = conn.prepareStatement(insertHistoryQuery)) {
                stmt.setInt(1, bookingId);
                stmt.setInt(2, userId);
                stmt.executeUpdate();
            }

            conn.commit();
            LOGGER.info("Booking ID=" + bookingId + " cancelled by userId=" + userId);
        }
    }
}