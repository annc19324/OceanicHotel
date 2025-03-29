package com.mycompany.oceanichotel.services.admin;

import com.mycompany.oceanichotel.models.RoomType;
import com.mycompany.oceanichotel.models.RoomTypeImage;
import com.mycompany.oceanichotel.utils.DatabaseUtil;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import java.util.logging.Logger;
import java.util.logging.Level;

public class AdminRoomTypeService {

    private static final Logger LOGGER = Logger.getLogger(AdminRoomTypeService.class.getName());

    public List<RoomType> getAllRoomTypes() throws SQLException {
        List<RoomType> roomTypes = new ArrayList<>();
        String query = "SELECT * FROM Room_Types ORDER BY type_name";
        try (Connection conn = DatabaseUtil.getConnection(); PreparedStatement stmt = conn.prepareStatement(query)) {
            ResultSet rs = stmt.executeQuery();
            while (rs.next()) {
                RoomType roomType = mapRoomType(rs);
                roomType.setImages(getRoomTypeImages(roomType.getTypeId()));
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
                RoomType roomType = mapRoomType(rs);
                roomType.setImages(getRoomTypeImages(typeId));
                return roomType;
            }
        }
        return null;
    }

    public void addRoomType(RoomType roomType) throws SQLException {
        String query = "INSERT INTO Room_Types (type_name, default_price, max_adults, max_children, description, created_at) " +
                      "VALUES (?, ?, ?, ?, ?, GETDATE())";
        try (Connection conn = DatabaseUtil.getConnection(); PreparedStatement stmt = conn.prepareStatement(query, Statement.RETURN_GENERATED_KEYS)) {
            stmt.setString(1, roomType.getTypeName());
            stmt.setDouble(2, roomType.getDefaultPrice());
            stmt.setInt(3, roomType.getMaxAdults());
            stmt.setInt(4, roomType.getMaxChildren());
            stmt.setString(5, roomType.getDescription());
            stmt.executeUpdate();

            ResultSet rs = stmt.getGeneratedKeys();
            if (rs.next()) {
                int typeId = rs.getInt(1);
                for (RoomTypeImage image : roomType.getImages()) {
                    addRoomTypeImage(typeId, image);
                }
            }
        }
    }

    public void updateRoomType(RoomType roomType) throws SQLException {
        String query = "UPDATE Room_Types SET type_name = ?, default_price = ?, max_adults = ?, max_children = ?, description = ? WHERE type_id = ?";
        try (Connection conn = DatabaseUtil.getConnection(); PreparedStatement stmt = conn.prepareStatement(query)) {
            stmt.setString(1, roomType.getTypeName());
            stmt.setDouble(2, roomType.getDefaultPrice());
            stmt.setInt(3, roomType.getMaxAdults());
            stmt.setInt(4, roomType.getMaxChildren());
            stmt.setString(5, roomType.getDescription());
            stmt.setInt(6, roomType.getTypeId());
            stmt.executeUpdate();
        }
    }

    public void deleteRoomType(int typeId) throws SQLException {
        String query = "DELETE FROM Room_Types WHERE type_id = ?";
        try (Connection conn = DatabaseUtil.getConnection(); PreparedStatement stmt = conn.prepareStatement(query)) {
            stmt.setInt(1, typeId);
            stmt.executeUpdate();
        }
    }

    public List<RoomTypeImage> getRoomTypeImages(int typeId) throws SQLException {
        List<RoomTypeImage> images = new ArrayList<>();
        String query = "SELECT * FROM Room_Type_Images WHERE type_id = ? ORDER BY is_primary DESC, created_at ASC";
        try (Connection conn = DatabaseUtil.getConnection(); PreparedStatement stmt = conn.prepareStatement(query)) {
            stmt.setInt(1, typeId);
            ResultSet rs = stmt.executeQuery();
            while (rs.next()) {
                RoomTypeImage image = new RoomTypeImage();
                image.setImageId(rs.getInt("image_id"));
                image.setTypeId(rs.getInt("type_id"));
                image.setImageUrl(rs.getString("image_url"));
                image.setPrimary(rs.getBoolean("is_primary"));
                image.setCreatedAt(rs.getTimestamp("created_at"));
                images.add(image);
            }
        }
        return images;
    }

    public void addRoomTypeImage(int typeId, RoomTypeImage image) throws SQLException {
        String query = "INSERT INTO Room_Type_Images (type_id, image_url, is_primary, created_at) VALUES (?, ?, ?, GETDATE())";
        try (Connection conn = DatabaseUtil.getConnection(); PreparedStatement stmt = conn.prepareStatement(query)) {
            stmt.setInt(1, typeId);
            stmt.setString(2, image.getImageUrl());
            stmt.setBoolean(3, image.isPrimary());
            stmt.executeUpdate();
        }
    }

    public void deleteRoomTypeImage(int imageId) throws SQLException {
        String query = "DELETE FROM Room_Type_Images WHERE image_id = ?";
        try (Connection conn = DatabaseUtil.getConnection(); PreparedStatement stmt = conn.prepareStatement(query)) {
            stmt.setInt(1, imageId);
            stmt.executeUpdate();
        }
    }

    public void setPrimaryImage(int typeId, int imageId) throws SQLException {
        try (Connection conn = DatabaseUtil.getConnection()) {
            String resetQuery = "UPDATE Room_Type_Images SET is_primary = 0 WHERE type_id = ?";
            try (PreparedStatement stmt = conn.prepareStatement(resetQuery)) {
                stmt.setInt(1, typeId);
                stmt.executeUpdate();
            }
            String setQuery = "UPDATE Room_Type_Images SET is_primary = 1 WHERE image_id = ? AND type_id = ?";
            try (PreparedStatement stmt = conn.prepareStatement(setQuery)) {
                stmt.setInt(1, imageId);
                stmt.setInt(2, typeId);
                stmt.executeUpdate();
            }
        }
    }

    private RoomType mapRoomType(ResultSet rs) throws SQLException {
        RoomType roomType = new RoomType();
        roomType.setTypeId(rs.getInt("type_id"));
        roomType.setTypeName(rs.getString("type_name"));
        roomType.setDefaultPrice(rs.getDouble("default_price"));
        roomType.setMaxAdults(rs.getInt("max_adults"));
        roomType.setMaxChildren(rs.getInt("max_children"));
        roomType.setDescription(rs.getString("description"));
        roomType.setCreatedAt(rs.getTimestamp("created_at"));
        return roomType;
    }
}