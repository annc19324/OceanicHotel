package com.mycompany.oceanichotel.services.admin;

import com.mycompany.oceanichotel.models.User;
import com.mycompany.oceanichotel.utils.DatabaseUtil;
import com.mycompany.oceanichotel.utils.SecurityUtil;
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

    public boolean isCccdExists(String cccd, Integer excludeUserId) throws SQLException {
        if (cccd == null || cccd.trim().isEmpty()) {
            return false;
        }
        String query = "SELECT COUNT(*) FROM Users WHERE cccd = ? AND (user_id != ? OR ? IS NULL)";
        try (Connection conn = DatabaseUtil.getConnection(); PreparedStatement stmt = conn.prepareStatement(query)) {
            stmt.setString(1, cccd);
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
                user.setPassword(rs.getString("password"));
                user.setRole(rs.getString("role"));
                user.setCccd(rs.getString("cccd"));
                user.setFullName(rs.getString("full_name"));
                user.setPhoneNumber(rs.getString("phone_number"));
                user.setDateOfBirth(rs.getDate("date_of_birth"));
                user.setGender(rs.getString("gender"));
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
                user.setCccd(rs.getString("cccd"));
                user.setFullName(rs.getString("full_name"));
                user.setPhoneNumber(rs.getString("phone_number"));
                user.setDateOfBirth(rs.getDate("date_of_birth"));
                user.setGender(rs.getString("gender"));
                user.setAvatar(rs.getString("avatar"));
                user.setActive(rs.getBoolean("is_active"));
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
        if (isCccdExists(user.getCccd(), null)) {
            throw new SQLException("CCCD already exists: " + user.getCccd());
        }
        if (user.getDateOfBirth() == null) {
            throw new SQLException("Date of birth is required!");
        }

        String query = "INSERT INTO Users (username, email, password, role, full_name, cccd, phone_number, date_of_birth, gender, created_at) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, GETDATE())";
        String hashedPassword = SecurityUtil.hashPassword(user.getPassword());
        try (Connection conn = DatabaseUtil.getConnection(); PreparedStatement stmt = conn.prepareStatement(query)) {
            stmt.setString(1, user.getUsername());
            stmt.setString(2, user.getEmail());
            stmt.setString(3, hashedPassword);
            stmt.setString(4, user.getRole());
            stmt.setString(5, user.getFullName());
            stmt.setString(6, user.getCccd());
            stmt.setString(7, user.getPhoneNumber());
            stmt.setDate(8, new java.sql.Date(user.getDateOfBirth().getTime()));
            stmt.setString(9, user.getGender());
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
        if (isCccdExists(user.getCccd(), user.getUserId())) {
            throw new SQLException("CCCD already exists: " + user.getCccd());
        }
        if (user.getDateOfBirth() == null) {
            throw new SQLException("Date of birth is required!");
        }

        String query = "UPDATE Users SET username = ?, email = ?, role = ?, full_name = ?, cccd = ?, phone_number = ?, date_of_birth = ?, gender = ?, is_active = ?" +
                      (user.getPassword() != null && !user.getPassword().trim().isEmpty() ? ", password = ?" : "") +
                      " WHERE user_id = ?";
        try (Connection conn = DatabaseUtil.getConnection(); PreparedStatement stmt = conn.prepareStatement(query)) {
            int paramIndex = 1;
            stmt.setString(paramIndex++, user.getUsername());
            stmt.setString(paramIndex++, user.getEmail());
            stmt.setString(paramIndex++, user.getRole());
            stmt.setString(paramIndex++, user.getFullName());
            stmt.setString(paramIndex++, user.getCccd());
            stmt.setString(paramIndex++, user.getPhoneNumber());
            stmt.setDate(paramIndex++, new java.sql.Date(user.getDateOfBirth().getTime()));
            stmt.setString(paramIndex++, user.getGender());
            stmt.setBoolean(paramIndex++, user.isActive());
            if (user.getPassword() != null && !user.getPassword().trim().isEmpty()) {
                stmt.setString(paramIndex++, SecurityUtil.hashPassword(user.getPassword()));
            }
            stmt.setInt(paramIndex, user.getUserId());
            stmt.executeUpdate();
        }
    }

    public void deleteUser(int userId) throws SQLException {
        Connection conn = null;
        try {
            conn = DatabaseUtil.getConnection();
            conn.setAutoCommit(false);

            String deleteLoginHistoryQuery = "DELETE FROM Login_History WHERE user_id = ?";
            try (PreparedStatement stmtLogin = conn.prepareStatement(deleteLoginHistoryQuery)) {
                stmtLogin.setInt(1, userId);
                stmtLogin.executeUpdate();
            }

            String deleteUserQuery = "DELETE FROM Users WHERE user_id = ?";
            try (PreparedStatement stmtUser = conn.prepareStatement(deleteUserQuery)) {
                stmtUser.setInt(1, userId);
                stmtUser.executeUpdate();
            }

            conn.commit();
        } catch (SQLException e) {
            if (conn != null) {
                try {
                    conn.rollback();
                } catch (SQLException rollbackEx) {
                    LOGGER.log(Level.SEVERE, "Rollback failed", rollbackEx);
                }
            }
            throw e;
        } finally {
            if (conn != null) {
                try {
                    conn.setAutoCommit(true);
                    conn.close();
                } catch (SQLException closeEx) {
                    LOGGER.log(Level.SEVERE, "Failed to close connection", closeEx);
                }
            }
        }
    }
}