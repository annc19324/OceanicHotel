package com.mycompany.oceanichotel.services.admin;

import com.mycompany.oceanichotel.models.Room;
import com.mycompany.oceanichotel.models.RoomType;
import com.mycompany.oceanichotel.utils.DatabaseUtil;
import java.math.BigDecimal;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import java.util.logging.Logger;
import java.util.logging.Level;

public class AdminRoomService {

    private static final int PAGE_SIZE = 10;
    private static final Logger LOGGER = Logger.getLogger(AdminRoomService.class.getName());

    public boolean isRoomNumberExists(String roomNumber, Integer excludeRoomId) throws SQLException {
        String query = "SELECT COUNT(*) FROM Rooms WHERE room_number = ? AND (room_id != ? OR ? IS NULL)";
        try (Connection conn = DatabaseUtil.getConnection(); PreparedStatement stmt = conn.prepareStatement(query)) {
            stmt.setString(1, roomNumber);
            stmt.setObject(2, excludeRoomId, Types.INTEGER);
            stmt.setObject(3, excludeRoomId, Types.INTEGER);
            ResultSet rs = stmt.executeQuery();
            return rs.next() && rs.getInt(1) > 0;
        }
    }

    public List<Room> getRooms(int page, String search, String status, String typeId) throws SQLException {
        if (page < 1) {
            LOGGER.log(Level.WARNING, "Invalid page number: {0}, defaulting to 1", page);
            page = 1;
        }
        List<Room> rooms = new ArrayList<>();
        String query = "SELECT r.*, rt.type_id, rt.type_name, rt.default_price, rt.max_adults AS rt_max_adults, rt.max_children AS rt_max_children "
                + "FROM Rooms r JOIN Room_Types rt ON r.type_id = rt.type_id WHERE 1=1";
        if (search != null && !search.trim().isEmpty()) {
            query += " AND r.room_number LIKE ?";
        }
        if (status != null && !status.isEmpty()) {
            query += " AND r.is_available = ?";
        }
        if (typeId != null && !typeId.isEmpty()) {
            query += " AND r.type_id = ?";
        }
        query += " ORDER BY r.room_id OFFSET ? ROWS FETCH NEXT ? ROWS ONLY";

        try (Connection conn = DatabaseUtil.getConnection(); PreparedStatement stmt = conn.prepareStatement(query)) {
            int paramIndex = 1;
            if (search != null && !search.trim().isEmpty()) {
                stmt.setString(paramIndex++, "%" + search + "%");
            }
            if (status != null && !status.isEmpty()) {
                stmt.setBoolean(paramIndex++, Boolean.parseBoolean(status));
            }
            if (typeId != null && !typeId.isEmpty()) {
                stmt.setInt(paramIndex++, Integer.parseInt(typeId));
            }
            stmt.setInt(paramIndex++, (page - 1) * PAGE_SIZE);
            stmt.setInt(paramIndex, PAGE_SIZE);

            ResultSet rs = stmt.executeQuery();
            while (rs.next()) {
                Room room = mapRoom(rs);
                rooms.add(room);
            }
        }
        return rooms;
    }

    public int getTotalRooms(String search, String status, String typeId) throws SQLException {
        String query = "SELECT COUNT(*) FROM Rooms r WHERE 1=1";
        if (search != null && !search.trim().isEmpty()) {
            query += " AND r.room_number LIKE ?";
        }
        if (status != null && !status.isEmpty()) {
            query += " AND r.is_available = ?";
        }
        if (typeId != null && !typeId.isEmpty()) {
            query += " AND r.type_id = ?";
        }
        try (Connection conn = DatabaseUtil.getConnection(); PreparedStatement stmt = conn.prepareStatement(query)) {
            int paramIndex = 1;
            if (search != null && !search.trim().isEmpty()) {
                stmt.setString(paramIndex++, "%" + search + "%");
            }
            if (status != null && !status.isEmpty()) {
                stmt.setBoolean(paramIndex++, Boolean.parseBoolean(status));
            }
            if (typeId != null && !typeId.isEmpty()) {
                stmt.setInt(paramIndex++, Integer.parseInt(typeId));
            }
            ResultSet rs = stmt.executeQuery();
            return rs.next() ? rs.getInt(1) : 0;
        }
    }

    public Room getRoomById(int roomId) throws SQLException {
        String query = "SELECT r.*, rt.type_id, rt.type_name, rt.default_price, rt.max_adults AS rt_max_adults, rt.max_children AS rt_max_children "
                + "FROM Rooms r JOIN Room_Types rt ON r.type_id = rt.type_id WHERE r.room_id = ?";
        try (Connection conn = DatabaseUtil.getConnection(); PreparedStatement stmt = conn.prepareStatement(query)) {
            stmt.setInt(1, roomId);
            ResultSet rs = stmt.executeQuery();
            if (rs.next()) {
                return mapRoom(rs);
            }
        }
        return null;
    }

    public List<RoomType> getAllRoomTypes() throws SQLException {
        List<RoomType> roomTypes = new ArrayList<>();
        String query = "SELECT * FROM Room_Types";
        try (Connection conn = DatabaseUtil.getConnection(); PreparedStatement stmt = conn.prepareStatement(query); ResultSet rs = stmt.executeQuery()) {
            while (rs.next()) {
                RoomType roomType = new RoomType();
                roomType.setTypeId(rs.getInt("type_id"));
                roomType.setTypeName(rs.getString("type_name"));
                roomType.setDefaultPrice(rs.getBigDecimal("default_price"));
                roomType.setMaxAdults(rs.getInt("max_adults"));
                roomType.setMaxChildren(rs.getInt("max_children"));
                roomTypes.add(roomType);
            }
        }
        return roomTypes;
    }

    public RoomType getRoomTypeById(int typeId) throws SQLException {
        String query = "SELECT * FROM Room_Types WHERE type_id = ?";
        try (Connection conn = DatabaseUtil.getConnection(); PreparedStatement stmt = conn.prepareStatement(query)) {
            stmt.setInt(1, typeId);
            ResultSet rs = stmt.executeQuery();
            if (rs.next()) {
                RoomType roomType = new RoomType();
                roomType.setTypeId(rs.getInt("type_id"));
                roomType.setTypeName(rs.getString("type_name"));
                roomType.setDefaultPrice(rs.getBigDecimal("default_price"));
                roomType.setMaxAdults(rs.getInt("max_adults"));
                roomType.setMaxChildren(rs.getInt("max_children"));
                return roomType;
            }
        }
        return null;
    }

    public void addRoom(Room room) throws SQLException {
        if (room.getRoomType() == null || room.getRoomType().getTypeId() <= 0) {
            throw new SQLException("Room type is required.");
        }
        if (isRoomNumberExists(room.getRoomNumber(), null)) {
            throw new SQLException("Room number already exists: " + room.getRoomNumber());
        }
        String query = "INSERT INTO Rooms (room_number, type_id, price_per_night, is_available, description, max_adults, max_children, created_at) "
                + "VALUES (?, ?, ?, ?, ?, ?, ?, GETDATE())";
        try (Connection conn = DatabaseUtil.getConnection(); PreparedStatement stmt = conn.prepareStatement(query)) {
            stmt.setString(1, room.getRoomNumber());
            stmt.setInt(2, room.getRoomType().getTypeId());
            stmt.setBigDecimal(3, room.getPricePerNight());
            stmt.setBoolean(4, room.isAvailable());
            stmt.setString(5, room.getDescription());
            stmt.setInt(6, room.getMaxAdults());
            stmt.setInt(7, room.getMaxChildren());
            stmt.executeUpdate();
        }
    }

    public void updateRoom(Room room) throws SQLException {
        if (room.getRoomType() == null || room.getRoomType().getTypeId() <= 0) {
            throw new SQLException("Room type is required.");
        }
        if (isRoomNumberExists(room.getRoomNumber(), room.getRoomId())) {
            throw new SQLException("Room number already exists: " + room.getRoomNumber());
        }
        String query = "UPDATE Rooms SET room_number = ?, type_id = ?, price_per_night = ?, is_available = ?, description = ?, max_adults = ?, max_children = ? "
                + "WHERE room_id = ?";
        try (Connection conn = DatabaseUtil.getConnection(); PreparedStatement stmt = conn.prepareStatement(query)) {
            stmt.setString(1, room.getRoomNumber());
            stmt.setInt(2, room.getRoomType().getTypeId());
            stmt.setBigDecimal(3, room.getPricePerNight());
            stmt.setBoolean(4, room.isAvailable());
            stmt.setString(5, room.getDescription());
            stmt.setInt(6, room.getMaxAdults());
            stmt.setInt(7, room.getMaxChildren());
            stmt.setInt(8, room.getRoomId());
            stmt.executeUpdate();
        }
    }

    public void deleteRoom(int roomId) throws SQLException {
        Connection conn = null;
        try {
            conn = DatabaseUtil.getConnection();
            conn.setAutoCommit(false);

            // Kiểm tra trạng thái phòng
            String checkAvailabilitySql = "SELECT is_available FROM Rooms WHERE room_id = ?";
            boolean isAvailable = false;
            try (PreparedStatement checkStmt = conn.prepareStatement(checkAvailabilitySql)) {
                checkStmt.setInt(1, roomId);
                ResultSet rs = checkStmt.executeQuery();
                if (rs.next()) {
                    isAvailable = rs.getBoolean("is_available");
                } else {
                    throw new SQLException("Room with roomId=" + roomId + " not found.");
                }
            }

            if (!isAvailable) {
                throw new SQLException("Cannot delete room because it is currently occupied.");
            }

            // Kiểm tra xem có đặt phòng nào liên quan không
            String checkBookingsSql = "SELECT COUNT(*) FROM Bookings WHERE room_id = ? AND status IN ('Pending', 'Confirmed')";
            try (PreparedStatement checkBookingsStmt = conn.prepareStatement(checkBookingsSql)) {
                checkBookingsStmt.setInt(1, roomId);
                ResultSet rs = checkBookingsStmt.executeQuery();
                if (rs.next() && rs.getInt(1) > 0) {
                    throw new SQLException("Cannot delete room because it has " + rs.getInt(1) + " active booking(s).");
                }
            }

            // Xóa ảnh của phòng (nếu có)
            String sqlImages = "DELETE FROM Room_Images WHERE room_id = ?";
            try (PreparedStatement stmtImages = conn.prepareStatement(sqlImages)) {
                stmtImages.setInt(1, roomId);
                stmtImages.executeUpdate();
            }

            // Xóa phòng
            String sqlRoom = "DELETE FROM Rooms WHERE room_id = ?";
            try (PreparedStatement stmtRoom = conn.prepareStatement(sqlRoom)) {
                stmtRoom.setInt(1, roomId);
                stmtRoom.executeUpdate();
            }

            conn.commit();
            LOGGER.info("Deleted Room with roomId=" + roomId + " successfully.");
        } catch (SQLException e) {
            if (conn != null) {
                conn.rollback();
            }
            LOGGER.log(Level.SEVERE, "Error deleting Room", e);
            throw e; // Ném lại để controller xử lý thông báo lỗi
        } finally {
            if (conn != null) {
                conn.close();
            }
        }
    }

    private Room mapRoom(ResultSet rs) throws SQLException {
        Room room = new Room();
        room.setRoomId(rs.getInt("room_id"));
        room.setRoomNumber(rs.getString("room_number"));

        RoomType roomType = new RoomType();
        roomType.setTypeId(rs.getInt("type_id"));
        roomType.setTypeName(rs.getString("type_name"));
        roomType.setDefaultPrice(rs.getBigDecimal("default_price"));
        roomType.setMaxAdults(rs.getInt("rt_max_adults"));
        roomType.setMaxChildren(rs.getInt("rt_max_children"));
        room.setRoomType(roomType);

        room.setPricePerNight(rs.getBigDecimal("price_per_night"));
        room.setAvailable(rs.getBoolean("is_available"));
        room.setDescription(rs.getString("description"));
        room.setMaxAdults(rs.getInt("max_adults"));
        room.setMaxChildren(rs.getInt("max_children"));
        room.setCreatedAt(rs.getTimestamp("created_at"));
        return room;
    }

    public int countAvailableRooms() throws SQLException {
        String sql = "SELECT COUNT(*) FROM Rooms WHERE is_available = 1";
        try (Connection conn = DatabaseUtil.getConnection(); PreparedStatement stmt = conn.prepareStatement(sql)) {
            ResultSet rs = stmt.executeQuery();
            if (rs.next()) {
                return rs.getInt(1);
            }
            return 0;
        }
    }

    public int countOccupiedRooms() throws SQLException {
        String sql = "SELECT COUNT(*) FROM Rooms WHERE is_available = 0";
        try (Connection conn = DatabaseUtil.getConnection(); PreparedStatement stmt = conn.prepareStatement(sql)) {
            ResultSet rs = stmt.executeQuery();
            if (rs.next()) {
                return rs.getInt(1);
            }
            return 0;
        }
    }
}
