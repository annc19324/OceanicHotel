package com.mycompany.oceanichotel.services.user;

import com.mycompany.oceanichotel.models.Room;
import com.mycompany.oceanichotel.models.RoomType;
import com.mycompany.oceanichotel.models.RoomTypeImage;
import com.mycompany.oceanichotel.services.admin.AdminRoomTypeService;
import com.mycompany.oceanichotel.utils.DatabaseUtil;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;

public class UserRoomService {
    private AdminRoomTypeService roomTypeService;

    public UserRoomService() {
        this.roomTypeService = new AdminRoomTypeService();
    }

    public List<RoomType> searchAvailableRoomTypes(LocalDate checkInDate, LocalDate checkOutDate, int adults, int children) throws SQLException {
        List<RoomType> availableRoomTypes = new ArrayList<>();
        String query = "SELECT rt.type_id, rt.type_name, rt.default_price, rt.max_adults, rt.max_children, rt.description " +
                      "FROM Room_Types rt " +
                      "WHERE rt.max_adults >= ? AND rt.max_children >= ? " +
                      "AND EXISTS (SELECT 1 FROM Rooms r " +
                      "WHERE r.type_id = rt.type_id AND r.is_available = true " +
                      "AND NOT EXISTS (SELECT 1 FROM Bookings b " +
                      "WHERE b.room_id = r.room_id " +
                      "AND (b.check_in_date <= ? AND b.check_out_date >= ?)))";

        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(query)) {
            stmt.setInt(1, adults);
            stmt.setInt(2, children);
            stmt.setDate(3, java.sql.Date.valueOf(checkOutDate));
            stmt.setDate(4, java.sql.Date.valueOf(checkInDate));

            ResultSet rs = stmt.executeQuery();
            while (rs.next()) {
                RoomType roomType = new RoomType();
                roomType.setTypeId(rs.getInt("type_id"));
                roomType.setTypeName(rs.getString("type_name"));
                roomType.setDefaultPrice(rs.getDouble("default_price"));
                roomType.setMaxAdults(rs.getInt("max_adults"));
                roomType.setMaxChildren(rs.getInt("max_children"));
                roomType.setDescription(rs.getString("description"));
                
                // Get images and set primary image
                List<RoomTypeImage> images = roomTypeService.getRoomTypeImages(roomType.getTypeId());
                roomType.setImages(images);
                // The primary image is automatically available through roomType.getPrimaryImage()
                
                availableRoomTypes.add(roomType);
            }
        }
        return availableRoomTypes;
    }

    public Room getRoomById(int roomId) throws SQLException {
        String query = "SELECT r.room_id, r.room_number, r.price_per_night, r.is_available, r.type_id " +
                      "FROM Rooms r WHERE r.room_id = ?";
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(query)) {
            stmt.setInt(1, roomId);
            ResultSet rs = stmt.executeQuery();
            if (rs.next()) {
                Room room = new Room();
                room.setRoomId(rs.getInt("room_id"));
                room.setRoomNumber(rs.getString("room_number"));
                room.setPricePerNight(rs.getDouble("price_per_night"));
                room.setAvailable(rs.getBoolean("is_available"));
                int typeId = rs.getInt("type_id");
                // Use getRoomTypeById instead of getRoomType
                RoomType roomType = roomTypeService.getRoomTypeById(typeId);
                room.setRoomType(roomType);
                return room;
            }
        }
        return null;
    }
}