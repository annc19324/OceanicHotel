package com.mycompany.oceanichotel.services.user;

import com.mycompany.oceanichotel.models.Booking;
import com.mycompany.oceanichotel.models.Room;
import com.mycompany.oceanichotel.models.RoomType;
import com.mycompany.oceanichotel.utils.DatabaseUtil;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;
import java.util.concurrent.TimeUnit;

public class UserBookingService {
    public List<Booking> getUserBookings(int userId) throws SQLException {
        List<Booking> bookings = new ArrayList<>();
        String query = "SELECT b.*, r.room_number, rt.type_name " +
                      "FROM Bookings b " +
                      "JOIN Rooms r ON b.room_id = r.room_id " +
                      "JOIN Room_Types rt ON r.type_id = rt.type_id " +
                      "WHERE b.user_id = ?";
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(query)) {
            stmt.setInt(1, userId);
            ResultSet rs = stmt.executeQuery();
            while (rs.next()) {
                Booking booking = new Booking();
                booking.setBookingId(rs.getInt("booking_id"));
                booking.setUserId(rs.getInt("user_id"));
                booking.setRoomId(rs.getInt("room_id"));
                booking.setCheckInDate(rs.getDate("check_in_date"));
                booking.setCheckOutDate(rs.getDate("check_out_date"));
                booking.setAdults(rs.getInt("adults"));
                booking.setChildren(rs.getInt("children"));
                booking.setTotalPrice(rs.getDouble("total_price"));
                booking.setStatus(rs.getString("status"));

                // Tính số đêm
                long diffInMillies = Math.abs(booking.getCheckOutDate().getTime() - booking.getCheckInDate().getTime());
                int nights = (int) TimeUnit.DAYS.convert(diffInMillies, TimeUnit.MILLISECONDS);
                booking.setNights(nights);

                // Kiểm tra xem có thể hủy hay không (ví dụ: trước 24 giờ so với check-in)
                long hoursUntilCheckIn = TimeUnit.HOURS.convert(booking.getCheckInDate().getTime() - new Date().getTime(), TimeUnit.MILLISECONDS);
                booking.setCanCancel(hoursUntilCheckIn > 24);

                // Gán thông tin phòng
                Room room = new Room();
                room.setRoomId(rs.getInt("room_id"));
                room.setRoomNumber(rs.getString("room_number"));
                RoomType roomType = new RoomType();
                roomType.setTypeName(rs.getString("type_name"));
                room.setRoomType(roomType);
                booking.setRoom(room);

                bookings.add(booking);
            }
        }
        return bookings;
    }

    public double calculateTotalPrice(int roomId, String checkIn, String checkOut) throws SQLException {
        String query = "SELECT price_per_night FROM Rooms WHERE room_id = ?";
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(query)) {
            stmt.setInt(1, roomId);
            ResultSet rs = stmt.executeQuery();
            if (rs.next()) {
                double pricePerNight = rs.getDouble("price_per_night");
                long diffInMillies = Math.abs(new java.text.SimpleDateFormat("yyyy-MM-dd").parse(checkOut).getTime() - new java.text.SimpleDateFormat("yyyy-MM-dd").parse(checkIn).getTime());
                long nights = TimeUnit.DAYS.convert(diffInMillies, TimeUnit.MILLISECONDS);
                return pricePerNight * nights;
            }
            return 0;
        } catch (Exception e) {
            throw new SQLException("Error calculating total price", e);
        }
    }

    public void saveBooking(Booking booking) throws SQLException {
        String query = "INSERT INTO Bookings (user_id, room_id, check_in_date, check_out_date, adults, children, total_price, status) VALUES (?, ?, ?, ?, ?, ?, ?, ?)";
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(query)) {
            stmt.setInt(1, booking.getUserId());
            stmt.setInt(2, booking.getRoomId());
            stmt.setDate(3, new java.sql.Date(booking.getCheckInDate().getTime()));
            stmt.setDate(4, new java.sql.Date(booking.getCheckOutDate().getTime()));
            stmt.setInt(5, booking.getAdults());
            stmt.setInt(6, booking.getChildren());
            stmt.setDouble(7, booking.getTotalPrice());
            stmt.setString(8, booking.getStatus());
            stmt.executeUpdate();
        }
    }
}