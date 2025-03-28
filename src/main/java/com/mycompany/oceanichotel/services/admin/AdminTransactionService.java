package com.mycompany.oceanichotel.services.admin;

import com.mycompany.oceanichotel.models.Transaction;
import com.mycompany.oceanichotel.utils.DatabaseUtil;
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
        String query = "SELECT * FROM Transactions WHERE 1=1";
        if (search != null && !search.trim().isEmpty()) {
            query += " AND transaction_id LIKE ?";
        }
        query += " ORDER BY transaction_id OFFSET ? ROWS FETCH NEXT ? ROWS ONLY";

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
                transaction.setAmount(rs.getDouble("amount"));
                transaction.setStatus(rs.getString("status"));
                transaction.setCreatedAt(rs.getTimestamp("created_at"));
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

    public double getTotalRevenue() throws SQLException {
        String query = "SELECT SUM(amount) FROM Transactions WHERE status = 'Success'";
        try (Connection conn = DatabaseUtil.getConnection(); PreparedStatement stmt = conn.prepareStatement(query)) {
            ResultSet rs = stmt.executeQuery();
            if (rs.next()) return rs.getDouble(1);
        }
        return 0;
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
}