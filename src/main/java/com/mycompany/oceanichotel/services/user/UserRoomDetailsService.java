//package com.mycompany.oceanichotel.services.user;
//
//import com.mycompany.oceanichotel.models.Room;
//import com.mycompany.oceanichotel.models.RoomType;
//import com.mycompany.oceanichotel.models.RoomTypeImage;
//import com.mycompany.oceanichotel.services.admin.AdminRoomTypeService;
//import com.mycompany.oceanichotel.utils.DatabaseUtil;
//
//import java.sql.Connection;
//import java.sql.PreparedStatement;
//import java.sql.ResultSet;
//import java.sql.SQLException;
//import java.util.ArrayList;
//import java.util.List;
//import java.util.logging.Level;
//import java.util.logging.Logger;
//
//public class UserRoomDetailsService {
//    private static final Logger LOGGER = Logger.getLogger(UserRoomDetailsService.class.getName());
//    private AdminRoomTypeService roomTypeService;
//
//    public UserRoomDetailsService() {
//        this.roomTypeService = new AdminRoomTypeService();
//    }
//
//    public Room getRoomById(int roomId) throws SQLException {
//        Room room = null;
//        String query = "SELECT r.room_id, r.room_number, r.type_id, r.price_per_night, r.max_adults, r.max_children, r.description, r.is_available, r.created_at " +
//                       "FROM rooms r " +
//                       "WHERE r.room_id = ?";
//
//        Connection conn = null;
//        try {
//            conn = DatabaseUtil.getConnection();
//            if (conn == null) {
//                LOGGER.severe("Database connection is null");
//                throw new SQLException("Failed to establish database connection");
//            }
//
//            try (PreparedStatement stmt = conn.prepareStatement(query)) {
//                stmt.setInt(1, roomId);
//                ResultSet rs = stmt.executeQuery();
//
//                if (rs.next()) {
//                    room = new Room();
//                    room.setRoomId(rs.getInt("room_id"));
//                    room.setRoomNumber(rs.getString("room_number"));
//                    room.setPricePerNight(rs.getDouble("price_per_night"));
//                    room.setMaxAdults(rs.getInt("max_adults"));
//                    room.setMaxChildren(rs.getInt("max_children"));
//                    room.setDescription(rs.getString("description"));
//                    room.setAvailable(rs.getBoolean("is_available"));
//                    room.setCreatedAt(rs.getTimestamp("created_at"));
//
//                    // Lấy RoomType
//                    int typeId = rs.getInt("type_id");
//                    RoomType roomType = roomTypeService.getRoomTypeById(typeId);
//                    if (roomType != null) {
//                        room.setRoomType(roomType);
//                    } else {
//                        LOGGER.warning("RoomType not found for type_id: " + typeId);
//                    }
//
//                    // Lấy danh sách ảnh trực tiếp từ room_images dựa trên room_id
//                    List<RoomTypeImage> images = getRoomImagesByRoomId(roomId);
//                    if (!images.isEmpty()) {
//                        roomType.setImages(images); // Gán danh sách ảnh vào RoomType
//                        room.setPrimaryImage(images.stream()
//                            .filter(RoomTypeImage::isPrimary)
//                            .findFirst()
//                            .orElse(images.get(0))); // Lấy ảnh primary hoặc ảnh đầu tiên
//                    }
//                } else {
//                    LOGGER.info("No room found for roomId: " + roomId);
//                }
//            }
//        } catch (SQLException e) {
//            LOGGER.log(Level.SEVERE, "Error fetching room details for roomId: " + roomId, e);
//            throw e;
//        } finally {
//            if (conn != null) {
//                try {
//                    conn.close();
//                } catch (SQLException e) {
//                    LOGGER.log(Level.WARNING, "Error closing connection", e);
//                }
//            }
//        }
//        return room;
//    }
//
//    private List<RoomTypeImage> getRoomImagesByRoomId(int roomId) throws SQLException {
//        List<RoomTypeImage> images = new ArrayList<>();
//        String query = "SELECT image_id, room_id, image_url, is_primary, created_at " +
//                       "FROM room_images " +
//                       "WHERE room_id = ?";
//
//        Connection conn = null;
//        try {
//            conn = DatabaseUtil.getConnection();
//            if (conn == null) {
//                LOGGER.severe("Database connection is null");
//                throw new SQLException("Failed to establish database connection");
//            }
//
//            try (PreparedStatement stmt = conn.prepareStatement(query)) {
//                stmt.setInt(1, roomId);
//                ResultSet rs = stmt.executeQuery();
//
//                while (rs.next()) {
//                    RoomTypeImage image = new RoomTypeImage();
//                    image.setImageId(rs.getInt("image_id"));
//                    image.setTypeId(rs.getInt("room_id")); // Dùng room_id thay vì type_id
//                    image.setImageUrl(rs.getString("image_url"));
//                    image.setPrimary(rs.getBoolean("is_primary"));
//                    image.setCreatedAt(rs.getTimestamp("created_at"));
//                    images.add(image);
//                }
//            }
//        } catch (SQLException e) {
//            LOGGER.log(Level.SEVERE, "Error fetching images for room id: " + roomId, e);
//            throw e;
//        } finally {
//            if (conn != null) {
//                try {
//                    conn.close();
//                } catch (SQLException e) {
//                    LOGGER.log(Level.WARNING, "Error closing connection", e);
//                }
//            }
//        }
//        return images;
//    }
//}