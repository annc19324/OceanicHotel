package com.mycompany.oceanichotel.models;
/*
 * Copyright (c) 2025 annc19324
 * All rights reserved.
 *
 * This code is the property of annc19324.
 * Unauthorized copying or distribution is prohibited.
 */
import java.math.BigDecimal;
import java.sql.Timestamp;

public class Transaction {
    private int transactionId;
    private int bookingId;
    private int userId;
    private BigDecimal amount;
    private String status;
    private String paymentMethod;
    private Timestamp createdAt;
    private Integer receptionistId;
    // Thông tin khách hàng
    private String userFullName;
    private String userEmail;
    // Thông tin phòng
    private String roomNumber;
    private String roomTypeName;

    // Getters and Setters cho các thuộc tính mới
    public String getUserFullName() { return userFullName; }
    public void setUserFullName(String userFullName) { this.userFullName = userFullName; }
    public String getUserEmail() { return userEmail; }
    public void setUserEmail(String userEmail) { this.userEmail = userEmail; }
    public String getRoomNumber() { return roomNumber; }
    public void setRoomNumber(String roomNumber) { this.roomNumber = roomNumber; }
    public String getRoomTypeName() { return roomTypeName; }
    public void setRoomTypeName(String roomTypeName) { this.roomTypeName = roomTypeName; }

    // Các getters/setters hiện có
    public int getTransactionId() { return transactionId; }
    public void setTransactionId(int transactionId) { this.transactionId = transactionId; }
    public int getBookingId() { return bookingId; }
    public void setBookingId(int bookingId) { this.bookingId = bookingId; }
    public int getUserId() { return userId; }
    public void setUserId(int userId) { this.userId = userId; }
    public BigDecimal getAmount() { return amount; }
    public void setAmount(BigDecimal amount) { this.amount = amount; }
    public String getStatus() { return status; }
    public void setStatus(String status) {
        if (status != null && (status.equals("Success") || status.equals("Failed") || status.equals("Pending") || status.equals("Refunded"))) {
            this.status = status;
        } else {
            throw new IllegalArgumentException("Status must be 'Success', 'Failed', 'Pending', or 'Refunded'");
        }
    }
    public String getPaymentMethod() { return paymentMethod; }
    public void setPaymentMethod(String paymentMethod) {
        if (paymentMethod != null && (paymentMethod.equals("Cash") || paymentMethod.equals("Card") || paymentMethod.equals("Online"))) {
            this.paymentMethod = paymentMethod;
        } else {
            throw new IllegalArgumentException("Payment method must be 'Cash', 'Card', or 'Online'");
        }
    }
    public Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }
    public Integer getReceptionistId() { return receptionistId; }
    public void setReceptionistId(Integer receptionistId) { this.receptionistId = receptionistId; }
}