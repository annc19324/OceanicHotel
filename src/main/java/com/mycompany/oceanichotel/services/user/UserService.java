package com.mycompany.oceanichotel.services.user;

import com.mycompany.oceanichotel.models.User;
import com.mycompany.oceanichotel.utils.DatabaseUtil;
import org.mindrot.jbcrypt.BCrypt;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.Calendar;
import java.util.regex.Pattern;

public class UserService {

    // Các phương thức hiện có giữ nguyên, chỉ thêm phương thức mới
    public String getUsernameByEmail(String email) throws SQLException {
        String query = "SELECT username FROM Users WHERE email = ?";
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(query)) {
            stmt.setString(1, email);
            ResultSet rs = stmt.executeQuery();
            if (rs.next()) {
                return rs.getString("username");
            }
            return null; // Không tìm thấy email
        }
    }

    // Các phương thức khác như loginUser, isUsernameExists, resetPassword, v.v. giữ nguyên
    public User loginUser(String username, String password) throws SQLException {
        String query = "SELECT * FROM Users WHERE username = ?";
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(query)) {
            stmt.setString(1, username);
            ResultSet rs = stmt.executeQuery();

            if (rs.next()) {
                String hashedPassword = rs.getString("password");
                if (BCrypt.checkpw(password, hashedPassword)) {
                    User user = new User();
                    user.setUserId(rs.getInt("user_id"));
                    user.setUsername(rs.getString("username"));
                    user.setPassword(hashedPassword);
                    user.setEmail(rs.getString("email"));
                    user.setRole(rs.getString("role"));
                    user.setFullName(rs.getString("full_name"));
                    user.setPhoneNumber(rs.getString("phone_number"));
                    user.setCccd(rs.getString("cccd"));
                    user.setDateOfBirth(rs.getDate("date_of_birth"));
                    user.setGender(rs.getString("gender"));
                    user.setAvatar(rs.getString("avatar"));
                    user.setActive(rs.getBoolean("is_active"));
                    user.setCreatedAt(rs.getDate("created_at"));
                    user.setLanguage(rs.getString("language"));
                    user.setTheme(rs.getString("theme"));
                    return user;
                }
            }
            return null;
        }
    }

    public boolean isUsernameExists(String username) throws SQLException {
        String sql = "SELECT COUNT(*) FROM Users WHERE username = ?";
        try (Connection conn = DatabaseUtil.getConnection(); PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, username);
            ResultSet rs = stmt.executeQuery();
            return rs.next() && rs.getInt(1) > 0;
        }
    }

    public boolean isEmailExists(String email) throws SQLException {
        String sql = "SELECT COUNT(*) FROM Users WHERE email = ?";
        try (Connection conn = DatabaseUtil.getConnection(); PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, email);
            ResultSet rs = stmt.executeQuery();
            return rs.next() && rs.getInt(1) > 0;
        }
    }

    public boolean isPhoneNumberExists(String phoneNumber) throws SQLException {
        String sql = "SELECT COUNT(*) FROM Users WHERE phone_number = ?";
        try (Connection conn = DatabaseUtil.getConnection(); PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, phoneNumber);
            ResultSet rs = stmt.executeQuery();
            return rs.next() && rs.getInt(1) > 0;
        }
    }

    public boolean isCCCDExists(String cccd) throws SQLException {
        String sql = "SELECT COUNT(*) FROM Users WHERE cccd = ?";
        try (Connection conn = DatabaseUtil.getConnection(); PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, cccd);
            ResultSet rs = stmt.executeQuery();
            return rs.next() && rs.getInt(1) > 0;
        }
    }

    public void resetPassword(String email, String newPassword) throws SQLException {
        if (!isPasswordValid(newPassword)) {
            throw new SQLException("Invalid password format!");
        }
        String hashedPassword = BCrypt.hashpw(newPassword, BCrypt.gensalt());
        String sql = "UPDATE Users SET password = ? WHERE email = ?";
        try (Connection conn = DatabaseUtil.getConnection(); PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, hashedPassword);
            stmt.setString(2, email);
            int rows = stmt.executeUpdate();
            if (rows == 0) {
                throw new SQLException("Email not found!");
            }
        }
    }

    private boolean isUsernameValid(String username) {
        String usernamePattern = "^[a-zA-Z0-9]{6,}$";
        return Pattern.matches(usernamePattern, username);
    }

    private boolean isEmailValid(String email) {
        String emailPattern = "^[^\\s@]+@[^\\s@]+\\.[^\\s@]+$";
        return Pattern.matches(emailPattern, email);
    }

    private boolean isPasswordValid(String password) {
        String passwordPattern = "^(?=.*[a-z])(?=.*[A-Z])(?=.*\\d)(?=.*[@#$%^&+=!]).{8,}$";
        return Pattern.matches(passwordPattern, password);
    }

    private boolean isCCCDValid(String cccd) {
        String pattern = "^[0-9]{12}$";
        return Pattern.matches(pattern, cccd);
    }

    private boolean isPhoneNumberValid(String phoneNumber) {
        String pattern = "^[0-9]{10,15}$";
        return Pattern.matches(pattern, phoneNumber);
    }

    public void registerUser(User user, String language) throws SQLException {
        if (!isUsernameValid(user.getUsername())) {
            throw new SQLException(language.equals("vi") ? "Tên người dùng phải ít nhất 6 ký tự, chỉ chứa chữ cái và số!" : "Username must be at least 6 characters and contain only letters and numbers!");
        }
        if (isUsernameExists(user.getUsername())) {
            throw new SQLException(language.equals("vi") ? "Tên người dùng đã tồn tại!" : "Username already exists!");
        }
        if (!isEmailValid(user.getEmail())) {
            throw new SQLException(language.equals("vi") ? "Email không hợp lệ!" : "Invalid email format!");
        }
        if (isEmailExists(user.getEmail())) {
            throw new SQLException(language.equals("vi") ? "Email đã tồn tại!" : "Email already exists!");
        }
        if (!isPasswordValid(user.getPassword())) {
            throw new SQLException(language.equals("vi") ? "Mật khẩu phải có ít nhất 8 ký tự, bao gồm chữ hoa, chữ thường, số và một ký tự đặc biệt!" : "Password must be at least 8 characters with uppercase, lowercase, number, and special character!");
        }
        if (user.getFullName() == null || user.getFullName().trim().isEmpty()) {
            throw new SQLException(language.equals("vi") ? "Vui lòng nhập họ và tên!" : "Please enter full name!");
        }
        if (!isPhoneNumberValid(user.getPhoneNumber())) {
            throw new SQLException(language.equals("vi") ? "Số điện thoại phải từ 10-15 chữ số!" : "Phone number must be 10-15 digits!");
        }
        if (user.getPhoneNumber() != null && isPhoneNumberExists(user.getPhoneNumber())) {
            throw new SQLException(language.equals("vi") ? "Số điện thoại đã tồn tại!" : "Phone number already exists!");
        }
        if (user.getCccd() == null || user.getCccd().trim().isEmpty()) {
            throw new SQLException(language.equals("vi") ? "Vui lòng nhập CCCD!" : "Please enter ID Card!");
        }
        if (!isCCCDValid(user.getCccd())) {
            throw new SQLException(language.equals("vi") ? "CCCD phải là 12 chữ số!" : "ID Card must be 12 digits!");
        }
        if (isCCCDExists(user.getCccd())) {
            throw new SQLException(language.equals("vi") ? "CCCD đã tồn tại!" : "ID Card already exists!");
        }
        if (user.getDateOfBirth() == null) {
            throw new SQLException(language.equals("vi") ? "Vui lòng nhập hoặc chọn đầy đủ ngày sinh!" : "Please enter or select full date of birth!");
        }

        java.util.Date now = new java.util.Date();
        Calendar dobCal = Calendar.getInstance();
        dobCal.setTime(user.getDateOfBirth());
        Calendar nowCal = Calendar.getInstance();
        nowCal.setTime(now);

        int age = nowCal.get(Calendar.YEAR) - dobCal.get(Calendar.YEAR);
        if (nowCal.get(Calendar.DAY_OF_YEAR) < dobCal.get(Calendar.DAY_OF_YEAR)) {
            age--;
        }

        if (user.getDateOfBirth().after(now)) {
            throw new SQLException(language.equals("vi") ? "Ngày sinh không thể là ngày trong tương lai!" : "Date of birth cannot be a future date!");
        } else if (age < 16) {
            throw new SQLException(language.equals("vi") ? "Bạn cần trên 16 tuổi để tạo tài khoản!" : "You need to be over 16 to create an account!");
        }

        if (user.getGender() != null && !user.getGender().equals("Male") && !user.getGender().equals("Female") && !user.getGender().equals("Other")) {
            throw new SQLException(language.equals("vi") ? "Giới tính phải là 'Male', 'Female' hoặc 'Other'!" : "Gender must be 'Male', 'Female', or 'Other'!");
        }

        String hashedPassword = BCrypt.hashpw(user.getPassword(), BCrypt.gensalt());
        String sql = "INSERT INTO Users (username, password, email, role, full_name, phone_number, cccd, date_of_birth, gender, language, theme, avatar) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
        try (Connection conn = DatabaseUtil.getConnection(); PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, user.getUsername());
            stmt.setString(2, hashedPassword);
            stmt.setString(3, user.getEmail());
            stmt.setString(4, user.getRole());
            stmt.setString(5, user.getFullName());
            stmt.setString(6, user.getPhoneNumber());
            stmt.setString(7, user.getCccd());
            stmt.setDate(8, user.getDateOfBirth() != null ? new java.sql.Date(user.getDateOfBirth().getTime()) : null);
            stmt.setString(9, user.getGender());
            stmt.setString(10, language);
            stmt.setString(11, user.getTheme() != null ? user.getTheme() : "light");
            stmt.setString(12, user.getAvatar() != null ? user.getAvatar() : "avatar-default.jpg");
            stmt.executeUpdate();
        }
    }

    public void updateUser(User user) throws SQLException {
        if (user.getFullName() == null || user.getFullName().trim().isEmpty()) {
            throw new SQLException("Full name cannot be empty!");
        }
        if (!isEmailValid(user.getEmail())) {
            throw new SQLException("Invalid email format!");
        }
        if (user.getPhoneNumber() != null && !user.getPhoneNumber().isEmpty() && !isPhoneNumberValid(user.getPhoneNumber())) {
            throw new SQLException("Phone number must be 10-15 digits!");
        }
        if (user.getCccd() != null && !user.getCccd().isEmpty() && !isCCCDValid(user.getCccd())) {
            throw new SQLException("ID Card must be 12 digits!");
        }
        if (user.getDateOfBirth() != null) {
            java.util.Date now = new java.util.Date();
            Calendar dobCal = Calendar.getInstance();
            dobCal.setTime(user.getDateOfBirth());
            Calendar nowCal = Calendar.getInstance();
            nowCal.setTime(now);

            int age = nowCal.get(Calendar.YEAR) - dobCal.get(Calendar.YEAR);
            if (nowCal.get(Calendar.DAY_OF_YEAR) < dobCal.get(Calendar.DAY_OF_YEAR)) {
                age--;
            }

            if (user.getDateOfBirth().after(now)) {
                throw new SQLException("Date of birth cannot be a future date!");
            } else if (age < 16) {
                throw new SQLException("User must be over 16 years old!");
            }
        }
        if (user.getGender() != null && !user.getGender().equals("Male") && !user.getGender().equals("Female") && !user.getGender().equals("Other")) {
            throw new SQLException("Gender must be 'Male', 'Female', or 'Other'!");
        }

        String query = "UPDATE Users SET full_name = ?, email = ?, phone_number = ?, cccd = ?, date_of_birth = ?, gender = ?, avatar = ? WHERE user_id = ?";
        try (Connection conn = DatabaseUtil.getConnection(); PreparedStatement stmt = conn.prepareStatement(query)) {
            stmt.setString(1, user.getFullName());
            stmt.setString(2, user.getEmail());
            stmt.setString(3, user.getPhoneNumber());
            stmt.setString(4, user.getCccd());
            stmt.setDate(5, user.getDateOfBirth() != null ? new java.sql.Date(user.getDateOfBirth().getTime()) : null);
            stmt.setString(6, user.getGender());
            stmt.setString(7, user.getAvatar());
            stmt.setInt(8, user.getUserId());
            int rowsAffected = stmt.executeUpdate();
            if (rowsAffected == 0) {
                throw new SQLException("No user found with ID: " + user.getUserId());
            }
        }
    }
}