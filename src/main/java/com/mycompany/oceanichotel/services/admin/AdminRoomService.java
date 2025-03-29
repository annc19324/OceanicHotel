package com.mycompany.oceanichotel.services.admin;

import com.mycompany.oceanichotel.models.Room;
import com.mycompany.oceanichotel.utils.DatabaseUtil;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
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
            stmt.setObject(2, excludeRoomId, java.sql.Types.INTEGER);
            stmt.setObject(3, excludeRoomId, java.sql.Types.INTEGER);
            ResultSet rs = stmt.executeQuery();
            if (rs.next()) {
                return rs.getInt(1) > 0;
            }
        }
        return false;
    }

    public List<Room> getRooms(int page, String search, String status, String roomType) throws SQLException {
        if (page < 1) {
            LOGGER.log(Level.WARNING, "Invalid page number: {0}, defaulting to 1", page);
            page = 1;
        }
        List<Room> rooms = new ArrayList<>();
        String query = "SELECT * FROM Rooms WHERE 1=1";
        if (search != null && !search.trim().isEmpty()) {
            query += " AND room_number LIKE ?";
        }
        if (status != null && !status.isEmpty()) {
            query += " AND is_available = ?";
        }
        if (roomType != null && !roomType.isEmpty()) {
            query += " AND room_type = ?";
        }
        query += " ORDER BY room_id OFFSET ? ROWS FETCH NEXT ? ROWS ONLY";

        try (Connection conn = DatabaseUtil.getConnection(); PreparedStatement stmt = conn.prepareStatement(query)) {
            int paramIndex = 1;
            if (search != null && !search.trim().isEmpty()) {
                stmt.setString(paramIndex++, "%" + search + "%");
            }
            if (status != null && !status.isEmpty()) {
                stmt.setBoolean(paramIndex++, Boolean.parseBoolean(status));
            }
            if (roomType != null && !roomType.isEmpty()) {
                stmt.setString(paramIndex++, roomType);
            }
            stmt.setInt(paramIndex++, (page - 1) * PAGE_SIZE);
            stmt.setInt(paramIndex, PAGE_SIZE);

            ResultSet rs = stmt.executeQuery();
            while (rs.next()) {
                Room room = new Room();
                room.setRoomId(rs.getInt("room_id"));
                room.setRoomNumber(rs.getString("room_number"));
                room.setRoomType(rs.getString("room_type"));
                room.setPricePerNight(rs.getDouble("price_per_night"));
                room.setAvailable(rs.getBoolean("is_available"));
                room.setDescription(rs.getString("description"));
                room.setImageUrl(rs.getString("image_url"));
                room.setMaxAdults(rs.getInt("max_adults"));
                room.setMaxChildren(rs.getInt("max_children"));
                room.setCreatedAt(rs.getTimestamp("created_at"));
                rooms.add(room);
            }
        }
        return rooms;
    }

    public int getTotalRooms(String search, String status, String roomType) throws SQLException {
        String query = "SELECT COUNT(*) FROM Rooms WHERE 1=1";
        if (search != null && !search.trim().isEmpty()) {
            query += " AND room_number LIKE ?";
        }
        if (status != null && !status.isEmpty()) {
            query += " AND is_available = ?";
        }
        if (roomType != null && !roomType.isEmpty()) {
            query += " AND room_type = ?";
        }
        try (Connection conn = DatabaseUtil.getConnection(); PreparedStatement stmt = conn.prepareStatement(query)) {
            int paramIndex = 1;
            if (search != null && !search.trim().isEmpty()) {
                stmt.setString(paramIndex++, "%" + search + "%");
            }
            if (status != null && !status.isEmpty()) {
                stmt.setBoolean(paramIndex++, Boolean.parseBoolean(status));
            }
            if (roomType != null && !roomType.isEmpty()) {
                stmt.setString(paramIndex++, roomType);
            }
            ResultSet rs = stmt.executeQuery();
            if (rs.next()) {
                return rs.getInt(1);
            }
        }
        return 0;
    }

    public Room getRoomById(int roomId) throws SQLException {
        String query = "SELECT * FROM Rooms WHERE room_id = ?";
        try (Connection conn = DatabaseUtil.getConnection(); PreparedStatement stmt = conn.prepareStatement(query)) {
            stmt.setInt(1, roomId);
            ResultSet rs = stmt.executeQuery();
            if (rs.next()) {
                Room room = new Room();
                room.setRoomId(rs.getInt("room_id"));
                room.setRoomNumber(rs.getString("room_number"));
                room.setRoomType(rs.getString("room_type"));
                room.setPricePerNight(rs.getDouble("price_per_night"));
                room.setAvailable(rs.getBoolean("is_available"));
                room.setDescription(rs.getString("description"));
                room.setImageUrl(rs.getString("image_url"));
                room.setMaxAdults(rs.getInt("max_adults"));
                room.setMaxChildren(rs.getInt("max_children"));
                room.setCreatedAt(rs.getTimestamp("created_at"));
                return room;
            }
        }
        return null;
    }

    public void addRoom(Room room) throws SQLException {
        if (isRoomNumberExists(room.getRoomNumber(), null)) {
            throw new SQLException("Room number already exists: " + room.getRoomNumber());
        }
        String query = "INSERT INTO Rooms (room_number, room_type, price_per_night, is_available, description, image_url, max_adults, max_children, created_at) VALUES (?, ?, ?, ?, ?, ?, ?, ?, GETDATE())";
        try (Connection conn = DatabaseUtil.getConnection(); PreparedStatement stmt = conn.prepareStatement(query)) {
            stmt.setString(1, room.getRoomNumber());
            stmt.setString(2, room.getRoomType());
            stmt.setDouble(3, room.getPricePerNight());
            stmt.setBoolean(4, room.isAvailable());
            stmt.setString(5, room.getDescription());
            stmt.setString(6, room.getImageUrl());
            stmt.setInt(7, room.getMaxAdults());
            stmt.setInt(8, room.getMaxChildren());
            stmt.executeUpdate();
        }
    }

    public void updateRoom(Room room) throws SQLException {
        if (isRoomNumberExists(room.getRoomNumber(), room.getRoomId())) {
            throw new SQLException("Room number already exists: " + room.getRoomNumber());
        }
        String query = "UPDATE Rooms SET room_number = ?, room_type = ?, price_per_night = ?, is_available = ?, description = ?, image_url = ?, max_adults = ?, max_children = ? WHERE room_id = ?";
        try (Connection conn = DatabaseUtil.getConnection(); PreparedStatement stmt = conn.prepareStatement(query)) {
            stmt.setString(1, room.getRoomNumber());
            stmt.setString(2, room.getRoomType());
            stmt.setDouble(3, room.getPricePerNight());
            stmt.setBoolean(4, room.isAvailable());
            stmt.setString(5, room.getDescription());
            stmt.setString(6, room.getImageUrl());
            stmt.setInt(7, room.getMaxAdults());
            stmt.setInt(8, room.getMaxChildren());
            stmt.setInt(9, room.getRoomId());
            stmt.executeUpdate();
        }
    }

    public void deleteRoom(int roomId) throws SQLException {
        String query = "DELETE FROM Rooms WHERE room_id = ?";
        try (Connection conn = DatabaseUtil.getConnection(); PreparedStatement stmt = conn.prepareStatement(query)) {
            stmt.setInt(1, roomId);
            stmt.executeUpdate();
        }
    }
}