package com.mycompany.oceanichotel.services.admin;
/*
 * Copyright (c) 2025 annc19324
 * All rights reserved.
 *
 * This code is the property of annc19324.
 * Unauthorized copying or distribution is prohibited.
 */
import com.mycompany.oceanichotel.models.Transaction;
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

public class AdminTransactionService {

    private static final int PAGE_SIZE = 10;
    private static final Logger LOGGER = Logger.getLogger(AdminTransactionService.class.getName());

    public List<Transaction> getTransactions(int page, String search) throws SQLException {
        if (page < 1) page = 1;
        List<Transaction> transactions = new ArrayList<>();
        String query = "SELECT t.*, u.full_name, u.email, r.room_number, rt.type_name " +
                       "FROM Transactions t " +
                       "JOIN Bookings b ON t.booking_id = b.booking_id " +
                       "JOIN Users u ON t.user_id = u.user_id " +
                       "JOIN Rooms r ON b.room_id = r.room_id " +
                       "JOIN Room_Types rt ON r.type_id = rt.type_id " +
                       "WHERE 1=1";
        if (search != null && !search.trim().isEmpty()) {
            query += " AND t.transaction_id LIKE ?";
        }
        query += " ORDER BY t.created_at DESC OFFSET ? ROWS FETCH NEXT ? ROWS ONLY"; // Sắp xếp theo created_at giảm dần

        try (Connection conn = DatabaseUtil.getConnection(); PreparedStatement stmt = conn.prepareStatement(query)) {
            int paramIndex = 1;
            if (search != null && !search.trim().isEmpty()) {
                stmt.setString(paramIndex++, "%" + search + "%");
            }
            stmt.setInt(paramIndex++, (page - 1) * PAGE_SIZE);
            stmt.setInt(paramIndex, PAGE_SIZE);

            ResultSet rs = stmt.executeQuery();
            while (rs.next()) {
                Transaction transaction = new Transaction();
                transaction.setTransactionId(rs.getInt("transaction_id"));
                transaction.setBookingId(rs.getInt("booking_id"));
                transaction.setUserId(rs.getInt("user_id"));
                transaction.setAmount(rs.getBigDecimal("amount"));
                transaction.setStatus(rs.getString("status"));
                transaction.setPaymentMethod(rs.getString("payment_method"));
                transaction.setCreatedAt(rs.getTimestamp("created_at"));
                transaction.setReceptionistId(rs.getInt("receptionist_id") == 0 ? null : rs.getInt("receptionist_id"));
                transaction.setUserFullName(rs.getString("full_name"));
                transaction.setUserEmail(rs.getString("email"));
                transaction.setRoomNumber(rs.getString("room_number"));
                transaction.setRoomTypeName(rs.getString("type_name"));
                transactions.add(transaction);
            }
        }
        return transactions;
    }

    public int getTotalTransactions(String search) throws SQLException {
        String query = "SELECT COUNT(*) FROM Transactions WHERE 1=1";
        if (search != null && !search.trim().isEmpty()) {
            query += " AND transaction_id LIKE ?";
        }
        try (Connection conn = DatabaseUtil.getConnection(); PreparedStatement stmt = conn.prepareStatement(query)) {
            if (search != null && !search.trim().isEmpty()) {
                stmt.setString(1, "%" + search + "%");
            }
            ResultSet rs = stmt.executeQuery();
            if (rs.next()) return rs.getInt(1);
        }
        return 0;
    }

    public BigDecimal getTotalRevenue() throws SQLException {
        String query = "SELECT SUM(amount) FROM Transactions WHERE status = 'Success'";
        try (Connection conn = DatabaseUtil.getConnection(); PreparedStatement stmt = conn.prepareStatement(query)) {
            ResultSet rs = stmt.executeQuery();
            if (rs.next()) return rs.getBigDecimal(1) != null ? rs.getBigDecimal(1) : BigDecimal.ZERO;
        }
        return BigDecimal.ZERO;
    }

    public int getTransactionCountByStatus(String status) throws SQLException {
        String query = "SELECT COUNT(*) FROM Transactions WHERE status = ?";
        try (Connection conn = DatabaseUtil.getConnection(); PreparedStatement stmt = conn.prepareStatement(query)) {
            stmt.setString(1, status);
            ResultSet rs = stmt.executeQuery();
            if (rs.next()) return rs.getInt(1);
        }
        return 0;
    }

    public void createTransaction(Transaction transaction) throws SQLException {
        String query = "INSERT INTO Transactions (booking_id, user_id, amount, status, payment_method, created_at, receptionist_id) " +
                      "VALUES (?, ?, ?, ?, ?, ?, ?)";
        try (Connection conn = DatabaseUtil.getConnection(); PreparedStatement stmt = conn.prepareStatement(query)) {
            stmt.setInt(1, transaction.getBookingId());
            stmt.setInt(2, transaction.getUserId());
            stmt.setBigDecimal(3, transaction.getAmount());
            stmt.setString(4, transaction.getStatus());
            stmt.setString(5, transaction.getPaymentMethod());
            stmt.setTimestamp(6, transaction.getCreatedAt());
            if (transaction.getReceptionistId() != null) {
                stmt.setInt(7, transaction.getReceptionistId());
            } else {
                stmt.setNull(7, java.sql.Types.INTEGER);
            }
            stmt.executeUpdate();
            LOGGER.log(Level.INFO, "Transaction created for booking {0}", new Object[]{transaction.getBookingId()});
        }
    }

    public void updateTransactionStatus(int transactionId, String newStatus) throws SQLException {
        String query = "UPDATE Transactions SET status = ? WHERE transaction_id = ?";
        try (Connection conn = DatabaseUtil.getConnection(); PreparedStatement stmt = conn.prepareStatement(query)) {
            stmt.setString(1, newStatus);
            stmt.setInt(2, transactionId);
            int rowsAffected = stmt.executeUpdate();
            if (rowsAffected > 0) {
                LOGGER.log(Level.INFO, "Transaction {0} status updated to {1}", new Object[]{transactionId, newStatus});
            } else {
                LOGGER.log(Level.WARNING, "Transaction {0} not found for status update", new Object[]{transactionId});
            }
        }
    }
}