package com.mycompany.oceanichotel.services.user;

import com.mycompany.oceanichotel.models.Room;
import com.mycompany.oceanichotel.models.RoomType;
import com.mycompany.oceanichotel.services.admin.AdminRoomTypeService;
import com.mycompany.oceanichotel.utils.DatabaseUtil;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

public class UserRoomService {
    private AdminRoomTypeService roomTypeService;

    public UserRoomService() {
        this.roomTypeService = new AdminRoomTypeService();
    }

    public List<RoomType> getAllRoomTypes() throws SQLException {
        return roomTypeService.getAllRoomTypes();
    }

    public List<Room> getAvailableRoomsByType(String typeId) throws SQLException {
        List<Room> rooms = new ArrayList<>();
        String query = "SELECT r.room_id, r.room_number, r.type_id, r.price_per_night, r.max_adults, r.max_children, r.description, r.is_available, r.created_at " +
                       "FROM Rooms r " +
                       "WHERE r.type_id = ? AND r.is_available = 1";

        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(query)) {
            stmt.setInt(1, Integer.parseInt(typeId));
            ResultSet rs = stmt.executeQuery();

            while (rs.next()) {
                Room room = new Room();
                room.setRoomId(rs.getInt("room_id"));
                room.setRoomNumber(rs.getString("room_number"));
                room.setPricePerNight(rs.getDouble("price_per_night"));
                room.setMaxAdults(rs.getInt("max_adults"));
                room.setMaxChildren(rs.getInt("max_children"));
                room.setDescription(rs.getString("description"));
                room.setAvailable(rs.getBoolean("is_available"));
                room.setCreatedAt(rs.getTimestamp("created_at"));

                RoomType roomType = roomTypeService.getRoomTypeById(rs.getInt("type_id"));
                room.setRoomType(roomType);
                rooms.add(room);
            }
        }
        return rooms;
    }

    // Giữ lại các phương thức khác nếu cần cho các chức năng khác
}