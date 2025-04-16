package com.mycompany.oceanichotel.services.user;
/*
 * Copyright (c) 2025 annc19324
 * All rights reserved.
 *
 * This code is the property of annc19324.
 * Unauthorized copying or distribution is prohibited.
 */
import com.mycompany.oceanichotel.models.Booking;
import com.mycompany.oceanichotel.models.BookingHistory;
import com.mycompany.oceanichotel.models.Room;
import com.mycompany.oceanichotel.models.RoomType;
import com.mycompany.oceanichotel.services.admin.AdminRoomTypeService;
import com.mycompany.oceanichotel.utils.DatabaseUtil;

import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;
import java.util.concurrent.TimeUnit;
import java.util.logging.Logger;
import java.util.logging.Level;

public class UserRoomService {

    private final AdminRoomTypeService roomTypeService;
    private static final Logger LOGGER = Logger.getLogger(UserRoomService.class.getName());

    public UserRoomService() {
        this.roomTypeService = new AdminRoomTypeService();
    }

    public List<RoomType> getAllRoomTypes() throws SQLException {
        LOGGER.info("Bắt đầu lấy danh sách tất cả loại phòng.");
        List<RoomType> roomTypes = roomTypeService.getAllRoomTypes();
        LOGGER.log(Level.INFO, "Đã lấy được {0} loại phòng.", roomTypes.size());
        return roomTypes;
    }

    public List<Room> getAvailableRoomsByType(String typeId) throws SQLException {
        if (typeId == null || typeId.trim().isEmpty()) {
            LOGGER.warning("typeId không hợp lệ: null hoặc rỗng.");
            throw new IllegalArgumentException("typeId không được null hoặc rỗng.");
        }

        int parsedTypeId;
        try {
            parsedTypeId = Integer.parseInt(typeId);
        } catch (NumberFormatException e) {
            LOGGER.log(Level.WARNING, "typeId không phải là số: {0}", typeId);
            throw new IllegalArgumentException("typeId phải là một số nguyên hợp lệ.");
        }

        List<Room> rooms = new ArrayList<>();
        String query = "SELECT r.room_id, r.room_number, r.type_id, r.price_per_night, "
                + "r.max_adults, r.max_children, r.description, r.is_available, r.created_at "
                + "FROM Rooms r WHERE r.type_id = ? AND r.is_available = 1";

        try (Connection conn = DatabaseUtil.getConnection(); PreparedStatement stmt = conn.prepareStatement(query)) {
            stmt.setInt(1, parsedTypeId);
            LOGGER.info("Thực thi truy vấn lấy phòng trống cho typeId=" + parsedTypeId);

            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    Room room = mapRoom(rs);
                    rooms.add(room);
                }
            }
            LOGGER.log(Level.INFO, "Đã tìm thấy {0} phòng trống cho typeId={1}", new Object[]{rooms.size(), parsedTypeId});
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Lỗi khi lấy danh sách phòng trống cho typeId={0}", parsedTypeId);
            throw e;
        }
        return rooms;
    }

    public Room getRoomById(int roomId) throws SQLException {
        if (roomId <= 0) {
            LOGGER.warning("roomId không hợp lệ: " + roomId);
            throw new IllegalArgumentException("roomId phải là số nguyên dương.");
        }

        String query = "SELECT r.room_id, r.room_number, r.type_id, r.price_per_night, "
                + "r.max_adults, r.max_children, r.description, r.is_available, r.created_at "
                + "FROM Rooms r WHERE r.room_id = ?";

        try (Connection conn = DatabaseUtil.getConnection(); PreparedStatement stmt = conn.prepareStatement(query)) {
            stmt.setInt(1, roomId);
            LOGGER.info("Thực thi truy vấn lấy chi tiết phòng với roomId=" + roomId);

            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    Room room = mapRoom(rs);
                    LOGGER.info("Đã tìm thấy phòng với roomId=" + roomId);
                    return room;
                }
            }
            LOGGER.warning("Không tìm thấy phòng với roomId=" + roomId);
            return null;
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Lỗi khi lấy chi tiết phòng với roomId={0}", roomId);
            throw e;
        }
    }

    private Room mapRoom(ResultSet rs) throws SQLException {
        Room room = new Room();
        room.setRoomId(rs.getInt("room_id"));
        room.setRoomNumber(rs.getString("room_number"));
        room.setPricePerNight(rs.getBigDecimal("price_per_night"));
        room.setMaxAdults(rs.getInt("max_adults"));
        room.setMaxChildren(rs.getInt("max_children"));
        room.setDescription(rs.getString("description"));
        room.setAvailable(rs.getBoolean("is_available"));
        room.setCreatedAt(rs.getTimestamp("created_at"));

        int typeId = rs.getInt("type_id");
        try {
            RoomType roomType = roomTypeService.getRoomTypeById(typeId);
            room.setRoomType(roomType);
        } catch (SQLException e) {
            LOGGER.log(Level.WARNING, "Không thể lấy RoomType cho typeId={0}: {1}", new Object[]{typeId, e.getMessage()});
            room.setRoomType(null);
        }
        return room;
    }

    public void bookRoom(Booking booking) throws SQLException {
        Connection conn = null;
        PreparedStatement stmtBooking = null;
        PreparedStatement stmtRoom = null;
        PreparedStatement stmtHistory = null;

        try {
            conn = DatabaseUtil.getConnection();
            conn.setAutoCommit(false);
            LOGGER.info("Starting transaction for booking roomId=" + booking.getRoomId());

            String insertBookingQuery = "INSERT INTO Bookings (user_id, room_id, check_in_date, check_out_date, total_price, status, num_adults, num_children) "
                    + "VALUES (?, ?, ?, ?, ?, ?, ?, ?)";
            stmtBooking = conn.prepareStatement(insertBookingQuery, Statement.RETURN_GENERATED_KEYS);
            stmtBooking.setInt(1, booking.getUserId());
            stmtBooking.setInt(2, booking.getRoomId());
            stmtBooking.setDate(3, new java.sql.Date(booking.getCheckInDate().getTime()));
            stmtBooking.setDate(4, new java.sql.Date(booking.getCheckOutDate().getTime()));
            stmtBooking.setBigDecimal(5, booking.getTotalPrice());
            stmtBooking.setString(6, booking.getStatus());
            stmtBooking.setInt(7, booking.getNumAdults());
            stmtBooking.setInt(8, booking.getNumChildren());
            int rowsAffected = stmtBooking.executeUpdate();
            LOGGER.info("Inserted into Bookings, rows affected: " + rowsAffected);

            ResultSet generatedKeys = stmtBooking.getGeneratedKeys();
            int bookingId;
            if (generatedKeys.next()) {
                bookingId = generatedKeys.getInt(1);
                booking.setBookingId(bookingId);
                LOGGER.info("Generated booking_id: " + bookingId);
            } else {
                throw new SQLException("Không thể lấy booking_id sau khi tạo booking.");
            }

            String updateRoomQuery = "UPDATE Rooms SET is_available = 0 WHERE room_id = ?";
            stmtRoom = conn.prepareStatement(updateRoomQuery);
            stmtRoom.setInt(1, booking.getRoomId());
            rowsAffected = stmtRoom.executeUpdate();
            LOGGER.info("Updated Rooms availability, rows affected: " + rowsAffected);

            String insertHistoryQuery = "INSERT INTO Booking_History (booking_id, changed_by, old_status, new_status) "
                    + "VALUES (?, ?, ?, ?)";
            stmtHistory = conn.prepareStatement(insertHistoryQuery);
            stmtHistory.setInt(1, bookingId);
            stmtHistory.setInt(2, booking.getUserId());
            stmtHistory.setString(3, null);
            stmtHistory.setString(4, booking.getStatus());
            rowsAffected = stmtHistory.executeUpdate();
            LOGGER.info("Inserted into Booking_History, rows affected: " + rowsAffected);

            conn.commit();
            LOGGER.info("Transaction committed successfully for roomId=" + booking.getRoomId() + ", bookingId=" + bookingId);
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error during booking process for roomId=" + booking.getRoomId(), e);
            if (conn != null) {
                try {
                    LOGGER.info("Rolling back transaction for roomId=" + booking.getRoomId());
                    conn.rollback();
                } catch (SQLException rollbackEx) {
                    LOGGER.log(Level.SEVERE, "Rollback failed", rollbackEx);
                }
            }
            throw e;
        } finally {
            if (stmtBooking != null) try { stmtBooking.close(); } catch (SQLException ignored) {}
            if (stmtRoom != null) try { stmtRoom.close(); } catch (SQLException ignored) {}
            if (stmtHistory != null) try { stmtHistory.close(); } catch (SQLException ignored) {}
            if (conn != null) try { conn.close(); } catch (SQLException ignored) {}
        }
    }

    public List<Booking> getUserBookings(int userId) throws SQLException {
        if (userId <= 0) {
            LOGGER.warning("userId không hợp lệ: " + userId);
            throw new IllegalArgumentException("userId phải là số nguyên dương.");
        }

        List<Booking> bookings = new ArrayList<>();
        String query = "SELECT b.booking_id, b.user_id, b.room_id, b.check_in_date, b.check_out_date, "
                + "b.total_price, b.status, b.num_adults, b.num_children, b.created_at, "
                + "r.room_number, rt.type_name "
                + "FROM Bookings b "
                + "JOIN Rooms r ON b.room_id = r.room_id "
                + "JOIN Room_Types rt ON r.type_id = rt.type_id "
                + "WHERE b.user_id = ? "
                + "ORDER BY b.created_at DESC";

        try (Connection conn = DatabaseUtil.getConnection(); PreparedStatement stmt = conn.prepareStatement(query)) {
            stmt.setInt(1, userId);
            LOGGER.info("Thực thi truy vấn lấy danh sách đặt phòng cho userId=" + userId);

            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    Booking booking = new Booking();
                    booking.setBookingId(rs.getInt("booking_id"));
                    booking.setUserId(rs.getInt("user_id"));
                    booking.setRoomId(rs.getInt("room_id"));
                    booking.setCheckInDate(rs.getDate("check_in_date"));
                    booking.setCheckOutDate(rs.getDate("check_out_date"));
                    booking.setTotalPrice(rs.getBigDecimal("total_price"));
                    booking.setStatus(rs.getString("status"));
                    booking.setNumAdults(rs.getInt("num_adults"));
                    booking.setNumChildren(rs.getInt("num_children"));
                    Room room = new Room();
                    room.setRoomNumber(rs.getString("room_number"));
                    RoomType roomType = new RoomType();
                    roomType.setTypeName(rs.getString("type_name"));
                    room.setRoomType(roomType);
                    booking.setRoom(room);
                    bookings.add(booking);
                }
            }
            LOGGER.log(Level.INFO, "Đã tìm thấy {0} đặt phòng cho userId={1}", new Object[]{bookings.size(), userId});
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Lỗi khi lấy danh sách đặt phòng cho userId={0}", userId);
            throw e;
        }
        return bookings;
    }

    public List<BookingHistory> getBookingHistory(int userId) throws SQLException {
        if (userId <= 0) {
            LOGGER.warning("userId không hợp lệ: " + userId);
            throw new IllegalArgumentException("userId phải là số nguyên dương.");
        }

        List<BookingHistory> historyList = new ArrayList<>();
        String query = "SELECT bh.history_id, bh.booking_id, bh.changed_by, bh.old_status, bh.new_status, bh.changed_at "
                + "FROM Booking_History bh "
                + "JOIN Bookings b ON bh.booking_id = b.booking_id "
                + "WHERE b.user_id = ? "
                + "ORDER BY bh.changed_at DESC";

        try (Connection conn = DatabaseUtil.getConnection(); PreparedStatement stmt = conn.prepareStatement(query)) {
            stmt.setInt(1, userId);
            LOGGER.info("Thực thi truy vấn lấy lịch sử đặt phòng cho userId=" + userId);

            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    BookingHistory history = new BookingHistory();
                    history.setHistoryId(rs.getInt("history_id"));
                    history.setBookingId(rs.getInt("booking_id"));
                    history.setChangedBy(rs.getInt("changed_by"));
                    history.setOldStatus(rs.getString("old_status"));
                    history.setNewStatus(rs.getString("new_status"));
                    history.setChangedAt(rs.getTimestamp("changed_at"));
                    historyList.add(history);
                }
            }
            LOGGER.log(Level.INFO, "Đã tìm thấy {0} bản ghi lịch sử cho userId={1}", new Object[]{historyList.size(), userId});
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Lỗi khi lấy lịch sử đặt phòng cho userId={0}", userId);
            throw e;
        }
        return historyList;
    }

    public void cancelBooking(int bookingId, int userId) throws SQLException {
        try (Connection conn = DatabaseUtil.getConnection()) {
            conn.setAutoCommit(false);

            String checkQuery = "SELECT status, check_in_date, room_id FROM Bookings WHERE booking_id = ? AND user_id = ?";
            String status;
            Date checkInDate;
            int roomId;
            try (PreparedStatement checkStmt = conn.prepareStatement(checkQuery)) {
                checkStmt.setInt(1, bookingId);
                checkStmt.setInt(2, userId);
                ResultSet rs = checkStmt.executeQuery();
                if (!rs.next()) {
                    throw new SQLException("Booking not found or not owned by userId=" + userId);
                }
                status = rs.getString("status");
                checkInDate = rs.getDate("check_in_date");
                roomId = rs.getInt("room_id");

                long hoursUntilCheckIn = TimeUnit.HOURS.convert(checkInDate.getTime() - new Date().getTime(), TimeUnit.MILLISECONDS);
                if (!"Pending".equals(status) || hoursUntilCheckIn <= 24) {
                    throw new SQLException("Booking cannot be cancelled: status=" + status + ", hours until check-in=" + hoursUntilCheckIn);
                }
            }

            String updateBookingQuery = "UPDATE Bookings SET status = 'Cancelled' WHERE booking_id = ?";
            try (PreparedStatement stmt = conn.prepareStatement(updateBookingQuery)) {
                stmt.setInt(1, bookingId);
                stmt.executeUpdate();
            }

            String updateRoomQuery = "UPDATE Rooms SET is_available = 1 WHERE room_id = ?";
            try (PreparedStatement stmt = conn.prepareStatement(updateRoomQuery)) {
                stmt.setInt(1, roomId);
                stmt.executeUpdate();
            }

            String updateTransactionQuery = "UPDATE Transactions SET status = 'Failed' WHERE booking_id = ? AND status = 'Pending'";
            try (PreparedStatement stmt = conn.prepareStatement(updateTransactionQuery)) {
                stmt.setInt(1, bookingId);
                stmt.executeUpdate();
            }

            String insertHistoryQuery = "INSERT INTO Booking_History (booking_id, changed_by, old_status, new_status) VALUES (?, ?, ?, ?)";
            try (PreparedStatement stmt = conn.prepareStatement(insertHistoryQuery)) {
                stmt.setInt(1, bookingId);
                stmt.setInt(2, userId);
                stmt.setString(3, "Pending");
                stmt.setString(4, "Cancelled");
                stmt.executeUpdate();
            }

            conn.commit();
            LOGGER.info("Booking ID=" + bookingId + " cancelled manually by userId=" + userId);
        }
    }
}