package com.mycompany.oceanichotel.services.admin;
/*
 * Copyright (c) 2025 annc19324
 * All rights reserved.
 *
 * This code is the property of annc19324.
 * Unauthorized copying or distribution is prohibited.
 */
import com.mycompany.oceanichotel.models.RoomType;
import com.mycompany.oceanichotel.models.RoomTypeImage;
import com.mycompany.oceanichotel.utils.DatabaseUtil;

import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import java.util.logging.Logger;
import java.util.logging.Level;

public class AdminRoomTypeService {

    private static final Logger LOGGER = Logger.getLogger(AdminRoomTypeService.class.getName());

    public RoomType getRoomTypeById(int typeId) throws SQLException {
        String sql = "SELECT * FROM Room_Types WHERE type_id = ?";
        try (Connection conn = DatabaseUtil.getConnection(); PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, typeId);
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    RoomType roomType = mapRoomType(rs);
                    roomType.setImages(getRoomTypeImages(typeId));
                    return roomType;
                }
            }
        }
        LOGGER.warning("Không tìm thấy RoomType với typeId=" + typeId);
        return null;
    }

    public List<RoomType> getAllRoomTypes() throws SQLException {
        List<RoomType> roomTypes = new ArrayList<>();
        String sql = "SELECT * FROM Room_Types ORDER BY type_name";
        try (Connection conn = DatabaseUtil.getConnection(); PreparedStatement stmt = conn.prepareStatement(sql); ResultSet rs = stmt.executeQuery()) {
            while (rs.next()) {
                RoomType roomType = mapRoomType(rs);
                roomType.setImages(getRoomTypeImages(rs.getInt("type_id")));
                roomTypes.add(roomType);
            }
        }
        return roomTypes;
    }

    public RoomTypeImage getImageById(int imageId) throws SQLException {
        String sql = "SELECT * FROM Room_Type_Images WHERE image_id = ?";
        try (Connection conn = DatabaseUtil.getConnection(); PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, imageId);
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    return mapRoomTypeImage(rs);
                }
            }
        }
        LOGGER.warning("Không tìm thấy ảnh với imageId=" + imageId);
        return null;
    }

    public void deleteRoomTypeImage(int imageId) throws SQLException {
        String sql = "DELETE FROM Room_Type_Images WHERE image_id = ?";
        try (Connection conn = DatabaseUtil.getConnection(); PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, imageId);
            int rowsAffected = stmt.executeUpdate();
            if (rowsAffected == 0) {
                throw new SQLException("Không tìm thấy ảnh để xóa với imageId=" + imageId);
            }
            LOGGER.info("Xóa ảnh với imageId=" + imageId + " thành công.");
        }
    }

    public void setPrimaryImage(int typeId, int imageId) throws SQLException {
        Connection conn = null;
        try {
            conn = DatabaseUtil.getConnection();
            conn.setAutoCommit(false);

            String sqlReset = "UPDATE Room_Type_Images SET is_primary = 0 WHERE type_id = ?";
            try (PreparedStatement stmtReset = conn.prepareStatement(sqlReset)) {
                stmtReset.setInt(1, typeId);
                stmtReset.executeUpdate();
            }

            String sqlSet = "UPDATE Room_Type_Images SET is_primary = 1 WHERE image_id = ? AND type_id = ?";
            try (PreparedStatement stmtSet = conn.prepareStatement(sqlSet)) {
                stmtSet.setInt(1, imageId);
                stmtSet.setInt(2, typeId);
                int rowsAffected = stmtSet.executeUpdate();
                if (rowsAffected == 0) {
                    throw new SQLException("Không tìm thấy ảnh với imageId=" + imageId + " cho typeId=" + typeId);
                }
            }

            conn.commit();
            LOGGER.info("Đặt ảnh chính với imageId=" + imageId + " cho typeId=" + typeId + " thành công.");
        } catch (SQLException e) {
            if (conn != null) {
                conn.rollback();
            }
            LOGGER.log(Level.SEVERE, "Lỗi khi đặt ảnh chính", e);
            throw e;
        } finally {
            if (conn != null) {
                conn.close();
            }
        }
    }

    public void addRoomTypeImage(int typeId, RoomTypeImage image) throws SQLException {
        String sql = "INSERT INTO Room_Type_Images (type_id, image_url, is_primary) VALUES (?, ?, ?)";
        try (Connection conn = DatabaseUtil.getConnection(); PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, typeId);
            stmt.setString(2, image.getImageUrl());
            stmt.setBoolean(3, image.isPrimary());
            stmt.executeUpdate();
            LOGGER.info("Thêm ảnh mới với imageUrl=" + image.getImageUrl() + " cho typeId=" + typeId);
        }
    }

    public void addRoomType(RoomType roomType) throws SQLException {
        String sql = "INSERT INTO Room_Types (type_name, default_price, max_adults, max_children, description) VALUES (?, ?, ?, ?, ?)";
        try (Connection conn = DatabaseUtil.getConnection(); PreparedStatement stmt = conn.prepareStatement(sql, PreparedStatement.RETURN_GENERATED_KEYS)) {
            stmt.setString(1, roomType.getTypeName());
            stmt.setBigDecimal(2, roomType.getDefaultPrice());
            stmt.setInt(3, roomType.getMaxAdults());
            stmt.setInt(4, roomType.getMaxChildren());
            stmt.setString(5, roomType.getDescription());
            stmt.executeUpdate();

            try (ResultSet rs = stmt.getGeneratedKeys()) {
                if (rs.next()) {
                    roomType.setTypeId(rs.getInt(1));
                }
            }
            for (RoomTypeImage image : roomType.getImages()) {
                addRoomTypeImage(roomType.getTypeId(), image);
            }
            LOGGER.info("Thêm RoomType mới với typeId=" + roomType.getTypeId());
        }
    }

    public void updateRoomType(RoomType roomType) throws SQLException {
        String sql = "UPDATE Room_Types SET type_name = ?, default_price = ?, max_adults = ?, max_children = ?, description = ? WHERE type_id = ?";
        try (Connection conn = DatabaseUtil.getConnection(); PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, roomType.getTypeName());
            stmt.setBigDecimal(2, roomType.getDefaultPrice());
            stmt.setInt(3, roomType.getMaxAdults());
            stmt.setInt(4, roomType.getMaxChildren());
            stmt.setString(5, roomType.getDescription());
            stmt.setInt(6, roomType.getTypeId());
            int rowsAffected = stmt.executeUpdate();
            if (rowsAffected == 0) {
                throw new SQLException("Không tìm thấy RoomType với typeId=" + roomType.getTypeId());
            }
            LOGGER.info("Cập nhật RoomType với typeId=" + roomType.getTypeId() + " thành công.");
        }
    }

    public void deleteRoomType(int typeId) throws SQLException {
        Connection conn = null;
        try {
            conn = DatabaseUtil.getConnection();
            conn.setAutoCommit(false);

            // Kiểm tra xem có phòng nào sử dụng loại phòng này không
            String checkRoomsSql = "SELECT COUNT(*) FROM Rooms WHERE type_id = ?";
            try (PreparedStatement checkStmt = conn.prepareStatement(checkRoomsSql)) {
                checkStmt.setInt(1, typeId);
                ResultSet rs = checkStmt.executeQuery();
                if (rs.next() && rs.getInt(1) > 0) {
                    throw new SQLException("Cannot delete room type because it is in use by " + rs.getInt(1) + " room(s).");
                }
            }

            String sqlImages = "DELETE FROM Room_Type_Images WHERE type_id = ?";
            try (PreparedStatement stmtImages = conn.prepareStatement(sqlImages)) {
                stmtImages.setInt(1, typeId);
                stmtImages.executeUpdate();
            }

            String sqlType = "DELETE FROM Room_Types WHERE type_id = ?";
            try (PreparedStatement stmtType = conn.prepareStatement(sqlType)) {
                stmtType.setInt(1, typeId);
                int rowsAffected = stmtType.executeUpdate();
                if (rowsAffected == 0) {
                    throw new SQLException("Không tìm thấy RoomType với typeId=" + typeId);
                }
            }

            conn.commit();
            LOGGER.info("Xóa RoomType với typeId=" + typeId + " thành công.");
        } catch (SQLException e) {
            if (conn != null) {
                conn.rollback();
            }
            LOGGER.log(Level.SEVERE, "Lỗi khi xóa RoomType", e);
            throw e;
        } finally {
            if (conn != null) {
                conn.close();
            }
        }
    }

    public List<RoomTypeImage> getRoomTypeImages(int typeId) throws SQLException {
        List<RoomTypeImage> images = new ArrayList<>();
        String query = "SELECT * FROM Room_Type_Images WHERE type_id = ? ORDER BY is_primary DESC";
        try (Connection conn = DatabaseUtil.getConnection(); PreparedStatement stmt = conn.prepareStatement(query)) {
            stmt.setInt(1, typeId);
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    images.add(mapRoomTypeImage(rs));
                }
            }
        }
        return images;
    }

    private RoomType mapRoomType(ResultSet rs) throws SQLException {
        RoomType roomType = new RoomType();
        roomType.setTypeId(rs.getInt("type_id"));
        roomType.setTypeName(rs.getString("type_name"));
        roomType.setDefaultPrice(rs.getBigDecimal("default_price"));
        roomType.setMaxAdults(rs.getInt("max_adults"));
        roomType.setMaxChildren(rs.getInt("max_children"));
        roomType.setDescription(rs.getString("description"));
        roomType.setCreatedAt(rs.getTimestamp("created_at"));
        return roomType;
    }

    private RoomTypeImage mapRoomTypeImage(ResultSet rs) throws SQLException {
        RoomTypeImage image = new RoomTypeImage();
        image.setImageId(rs.getInt("image_id"));
        image.setTypeId(rs.getInt("type_id"));
        image.setImageUrl(rs.getString("image_url"));
        image.setIsPrimary(rs.getBoolean("is_primary"));
        image.setCreatedAt(rs.getTimestamp("created_at"));
        return image;
    }
}
