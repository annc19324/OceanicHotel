package com.mycompany.oceanichotel.services.admin;

import com.mycompany.oceanichotel.models.LoginHistory;
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
import org.mindrot.jbcrypt.BCrypt;

public class AdminUserService {

    private static final int PAGE_SIZE = 10;
    private static final Logger LOGGER = Logger.getLogger(AdminUserService.class.getName());

    public List<User> getUsers(int page, String search) throws SQLException {
        if (page < 1) {
            LOGGER.log(Level.WARNING, "Invalid page number: {0}, defaulting to 1", page);
            page = 1;
        }
        List<User> users = new ArrayList<>();
        String query = "SELECT * FROM Users WHERE 1=1";
        if (search != null && !search.trim().isEmpty()) {
            query += " AND (username LIKE ? OR email LIKE ?)";
        }
        query += " ORDER BY user_id OFFSET ? ROWS FETCH NEXT ? ROWS ONLY";

        try (Connection conn = DatabaseUtil.getConnection(); PreparedStatement stmt = conn.prepareStatement(query)) {
            int paramIndex = 1;
            if (search != null && !search.trim().isEmpty()) {
                stmt.setString(paramIndex++, "%" + search + "%");
                stmt.setString(paramIndex++, "%" + search + "%");
            }
            stmt.setInt(paramIndex++, (page - 1) * PAGE_SIZE);
            stmt.setInt(paramIndex, PAGE_SIZE);

            ResultSet rs = stmt.executeQuery();
            while (rs.next()) {
                User user = new User();
                user.setUserId(rs.getInt("user_id"));
                user.setUsername(rs.getString("username"));
                user.setPassword(rs.getString("password"));
                user.setEmail(rs.getString("email"));
                user.setRole(rs.getString("role"));
                user.setAvatar(rs.getString("avatar"));
                user.setActive(rs.getBoolean("is_active"));
                user.setCreatedAt(rs.getTimestamp("created_at"));
                users.add(user);
            }
        }
        return users;
    }

    public int getTotalUsers(String search) throws SQLException {
        String query = "SELECT COUNT(*) FROM Users WHERE 1=1";
        if (search != null && !search.trim().isEmpty()) {
            query += " AND (username LIKE ? OR email LIKE ?)";
        }

        try (Connection conn = DatabaseUtil.getConnection(); PreparedStatement stmt = conn.prepareStatement(query)) {
            if (search != null && !search.trim().isEmpty()) {
                stmt.setString(1, "%" + search + "%");
                stmt.setString(2, "%" + search + "%");
            }
            ResultSet rs = stmt.executeQuery();
            if (rs.next()) {
                return rs.getInt(1);
            }
        }
        return 0;
    }

    public User getUserById(int userId) throws SQLException {
        if (userId <= 0) {
            LOGGER.log(Level.WARNING, "Invalid userId in getUserById: {0}", userId);
            return null;
        }
        String query = "SELECT * FROM Users WHERE user_id = ?";
        try (Connection conn = DatabaseUtil.getConnection(); PreparedStatement stmt = conn.prepareStatement(query)) {
            stmt.setInt(1, userId);
            ResultSet rs = stmt.executeQuery();
            if (rs.next()) {
                User user = new User();
                user.setUserId(rs.getInt("user_id"));
                user.setUsername(rs.getString("username"));
                user.setPassword(rs.getString("password"));
                user.setEmail(rs.getString("email"));
                user.setRole(rs.getString("role"));
                user.setAvatar(rs.getString("avatar"));
                user.setActive(rs.getBoolean("is_active"));
                user.setCreatedAt(rs.getTimestamp("created_at"));
                return user;
            }
        }
        return null;
    }

    public void addUser(User user) throws SQLException {
        if (user == null || user.getUsername() == null || user.getPassword() == null) {
            LOGGER.log(Level.SEVERE, "Invalid user data in addUser");
            throw new SQLException("User data cannot be null");
        }
        String query = "INSERT INTO Users (username, password, email, role, is_active, created_at) VALUES (?, ?, ?, ?, ?, GETDATE())";
        String hashedPassword = BCrypt.hashpw(user.getPassword(), BCrypt.gensalt());

        try (Connection conn = DatabaseUtil.getConnection(); PreparedStatement stmt = conn.prepareStatement(query)) {
            stmt.setString(1, user.getUsername());
            stmt.setString(2, hashedPassword);
            stmt.setString(3, user.getEmail());
            stmt.setString(4, user.getRole());
            stmt.setBoolean(5, user.isActive());
            stmt.executeUpdate();
        }
    }

    public void updateUser(User user) throws SQLException {
        if (user == null || user.getUserId() <= 0) {
            LOGGER.log(Level.SEVERE, "Invalid user data in updateUser: {0}", user != null ? user.getUserId() : "null");
            throw new SQLException("User ID cannot be null or negative");
        }
        String query = "UPDATE Users SET username = ?, email = ?, role = ?, is_active = ? WHERE user_id = ?";
        try (Connection conn = DatabaseUtil.getConnection(); PreparedStatement stmt = conn.prepareStatement(query)) {
            stmt.setString(1, user.getUsername());
            stmt.setString(2, user.getEmail());
            stmt.setString(3, user.getRole());
            stmt.setBoolean(4, user.isActive());
            stmt.setInt(5, user.getUserId());
            stmt.executeUpdate();
        }
    }

    public void deleteUser(int userId) throws SQLException {
        if (userId <= 0) {
            LOGGER.log(Level.WARNING, "Invalid userId in deleteUser: {0}", userId);
            throw new SQLException("User ID must be positive");
        }
        String query = "DELETE FROM Users WHERE user_id = ?";
        try (Connection conn = DatabaseUtil.getConnection(); PreparedStatement stmt = conn.prepareStatement(query)) {
            stmt.setInt(1, userId);
            int rowsAffected = stmt.executeUpdate();
            if (rowsAffected == 0) {
                LOGGER.log(Level.WARNING, "No user found with userId: {0}", userId);
            }
        }
    }

    public List<LoginHistory> getLoginHistory(int userId) throws SQLException {
        if (userId <= 0) {
            LOGGER.log(Level.WARNING, "Invalid userId in getLoginHistory: {0}", userId);
            return new ArrayList<>();
        }
        List<LoginHistory> history = new ArrayList<>();
        String query = "SELECT * FROM Login_History WHERE user_id = ? ORDER BY login_time DESC";
        try (Connection conn = DatabaseUtil.getConnection(); PreparedStatement stmt = conn.prepareStatement(query)) {
            stmt.setInt(1, userId);
            ResultSet rs = stmt.executeQuery();
            while (rs.next()) {
                LoginHistory login = new LoginHistory();
                login.setId(rs.getInt("id"));
                login.setUserId(rs.getInt("user_id"));
                login.setLoginTime(rs.getTimestamp("login_time"));
                login.setIpAddress(rs.getString("ip_address"));
                login.setBrowser(rs.getString("browser"));
                history.add(login);
            }
        }
        return history;
    }

    public boolean verifyPassword(int userId, String password) throws SQLException {
        if (userId <= 0 || password == null) {
            LOGGER.log(Level.WARNING, "Invalid input in verifyPassword: userId={0}, password={1}", new Object[]{userId, password});
            return false;
        }
        String query = "SELECT password FROM Users WHERE user_id = ?";
        try (Connection conn = DatabaseUtil.getConnection(); PreparedStatement stmt = conn.prepareStatement(query)) {
            stmt.setInt(1, userId);
            ResultSet rs = stmt.executeQuery();
            if (rs.next()) {
                String storedPassword = rs.getString("password");
                return BCrypt.checkpw(password, storedPassword); // Sử dụng BCrypt để kiểm tra
            }
        }
        return false;
    }
}