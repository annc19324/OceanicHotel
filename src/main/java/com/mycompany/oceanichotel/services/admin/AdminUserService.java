package com.mycompany.oceanichotel.services.admin;

import com.mycompany.oceanichotel.models.User;
import com.mycompany.oceanichotel.utils.DatabaseUtil;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import java.util.logging.Logger;
import java.util.logging.Level;

public class AdminUserService {

    private static final int PAGE_SIZE = 10;
    private static final Logger LOGGER = Logger.getLogger(AdminUserService.class.getName());

    public boolean isUsernameExists(String username, Integer excludeUserId) throws SQLException {
        String query = "SELECT COUNT(*) FROM Users WHERE username = ? AND (user_id != ? OR ? IS NULL)";
        try (Connection conn = DatabaseUtil.getConnection(); PreparedStatement stmt = conn.prepareStatement(query)) {
            stmt.setString(1, username);
            stmt.setObject(2, excludeUserId, java.sql.Types.INTEGER);
            stmt.setObject(3, excludeUserId, java.sql.Types.INTEGER);
            ResultSet rs = stmt.executeQuery();
            if (rs.next()) {
                return rs.getInt(1) > 0;
            }
        }
        return false;
    }

    public boolean isEmailExists(String email, Integer excludeUserId) throws SQLException {
        String query = "SELECT COUNT(*) FROM Users WHERE email = ? AND (user_id != ? OR ? IS NULL)";
        try (Connection conn = DatabaseUtil.getConnection(); PreparedStatement stmt = conn.prepareStatement(query)) {
            stmt.setString(1, email);
            stmt.setObject(2, excludeUserId, java.sql.Types.INTEGER);
            stmt.setObject(3, excludeUserId, java.sql.Types.INTEGER);
            ResultSet rs = stmt.executeQuery();
            if (rs.next()) {
                return rs.getInt(1) > 0;
            }
        }
        return false;
    }

    public List<User> getUsers(int page, String search) throws SQLException {
        if (page < 1) {
            LOGGER.log(Level.WARNING, "Invalid page number: {0}, defaulting to 1", page);
            page = 1;
        }
        List<User> users = new ArrayList<>();
        String query = "SELECT * FROM Users WHERE 1=1";
        if (search != null && !search.trim().isEmpty()) {
            query += " AND username LIKE ?";
        }
        query += " ORDER BY user_id OFFSET ? ROWS FETCH NEXT ? ROWS ONLY";

        try (Connection conn = DatabaseUtil.getConnection(); PreparedStatement stmt = conn.prepareStatement(query)) {
            int paramIndex = 1;
            if (search != null && !search.trim().isEmpty()) {
                stmt.setString(paramIndex++, "%" + search + "%");
            }
            stmt.setInt(paramIndex++, (page - 1) * PAGE_SIZE);
            stmt.setInt(paramIndex, PAGE_SIZE);

            ResultSet rs = stmt.executeQuery();
            while (rs.next()) {
                User user = new User();
                user.setUserId(rs.getInt("user_id"));
                user.setUsername(rs.getString("username"));
                user.setEmail(rs.getString("email"));
                user.setPassword(rs.getString("password")); // Lưu ý: Trong thực tế, mật khẩu nên được mã hóa
                user.setRole(rs.getString("role"));
                user.setCreatedAt(rs.getTimestamp("created_at"));
                users.add(user);
            }
        }
        return users;
    }

    public int getTotalUsers(String search) throws SQLException {
        String query = "SELECT COUNT(*) FROM Users WHERE 1=1";
        if (search != null && !search.trim().isEmpty()) {
            query += " AND username LIKE ?";
        }
        try (Connection conn = DatabaseUtil.getConnection(); PreparedStatement stmt = conn.prepareStatement(query)) {
            if (search != null && !search.trim().isEmpty()) {
                stmt.setString(1, "%" + search + "%");
            }
            ResultSet rs = stmt.executeQuery();
            if (rs.next()) {
                return rs.getInt(1);
            }
        }
        return 0;
    }

    public User getUserById(int userId) throws SQLException {
        String query = "SELECT * FROM Users WHERE user_id = ?";
        try (Connection conn = DatabaseUtil.getConnection(); PreparedStatement stmt = conn.prepareStatement(query)) {
            stmt.setInt(1, userId);
            ResultSet rs = stmt.executeQuery();
            if (rs.next()) {
                User user = new User();
                user.setUserId(rs.getInt("user_id"));
                user.setUsername(rs.getString("username"));
                user.setEmail(rs.getString("email"));
                user.setPassword(rs.getString("password"));
                user.setRole(rs.getString("role"));
                user.setCreatedAt(rs.getTimestamp("created_at"));
                return user;
            }
        }
        return null;
    }

    public void addUser(User user) throws SQLException {
        if (isUsernameExists(user.getUsername(), null)) {
            throw new SQLException("Username already exists: " + user.getUsername());
        }
        if (isEmailExists(user.getEmail(), null)) {
            throw new SQLException("Email already exists: " + user.getEmail());
        }
        String query = "INSERT INTO Users (username, email, password, role, created_at) VALUES (?, ?, ?, ?, GETDATE())";
        try (Connection conn = DatabaseUtil.getConnection(); PreparedStatement stmt = conn.prepareStatement(query)) {
            stmt.setString(1, user.getUsername());
            stmt.setString(2, user.getEmail());
            stmt.setString(3, user.getPassword()); // Nên mã hóa mật khẩu trong thực tế
            stmt.setString(4, user.getRole());
            stmt.executeUpdate();
        }
    }

    public void updateUser(User user) throws SQLException {
        if (isUsernameExists(user.getUsername(), user.getUserId())) {
            throw new SQLException("Username already exists: " + user.getUsername());
        }
        if (isEmailExists(user.getEmail(), user.getUserId())) {
            throw new SQLException("Email already exists: " + user.getEmail());
        }
        String query = "UPDATE Users SET username = ?, email = ?, role = ?" + 
                      (user.getPassword() != null ? ", password = ?" : "") + 
                      " WHERE user_id = ?";
        try (Connection conn = DatabaseUtil.getConnection(); PreparedStatement stmt = conn.prepareStatement(query)) {
            stmt.setString(1, user.getUsername());
            stmt.setString(2, user.getEmail());
            stmt.setString(3, user.getRole());
            int paramIndex = 4;
            if (user.getPassword() != null) {
                stmt.setString(paramIndex++, user.getPassword());
            }
            stmt.setInt(paramIndex, user.getUserId());
            stmt.executeUpdate();
        }
    }

    public void deleteUser(int userId) throws SQLException {
        String query = "DELETE FROM Users WHERE user_id = ?";
        try (Connection conn = DatabaseUtil.getConnection(); PreparedStatement stmt = conn.prepareStatement(query)) {
            stmt.setInt(1, userId);
            stmt.executeUpdate();
        }
    }
}