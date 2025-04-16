package com.mycompany.oceanichotel.models;
/*
 * Copyright (c) 2025 annc19324
 * All rights reserved.
 *
 * This code is the property of annc19324.
 * Unauthorized copying or distribution is prohibited.
 */
import java.sql.Timestamp;

public class BookingHistory {

    private int historyId;
    private int bookingId;
    private int changedBy;
    private String oldStatus;
    private String newStatus;
    private Timestamp changedAt;

    public BookingHistory() {
    }

    public BookingHistory(int bookingId, int changedBy, String oldStatus, String newStatus) {
        this.bookingId = bookingId;
        this.changedBy = changedBy;
        this.oldStatus = oldStatus;
        this.newStatus = newStatus;
    }

    // Getters và Setters
    public int getHistoryId() {
        return historyId;
    }

    public void setHistoryId(int historyId) {
        this.historyId = historyId;
    }

    public int getBookingId() {
        return bookingId;
    }

    public void setBookingId(int bookingId) {
        this.bookingId = bookingId;
    }

    public int getChangedBy() {
        return changedBy;
    }

    public void setChangedBy(int changedBy) {
        this.changedBy = changedBy;
    }

    public String getOldStatus() {
        return oldStatus;
    }

    public void setOldStatus(String oldStatus) {
        if (oldStatus == null) {
            this.oldStatus = null;
        } else if (oldStatus.equals("Pending") || oldStatus.equals("Confirmed") || oldStatus.equals("Cancelled") || oldStatus.equals("Success")) {
            this.oldStatus = oldStatus;
        } else {
            throw new IllegalArgumentException("Old status must be 'Pending', 'Confirmed', 'Cancelled', or 'Success'");
        }
    }

    public String getNewStatus() {
        return newStatus;
    }

    public void setNewStatus(String newStatus) {
        if (newStatus != null && (newStatus.equals("Pending") || newStatus.equals("Confirmed") || newStatus.equals("Cancelled") || newStatus.equals("Success"))) {
            this.newStatus = newStatus;
        } else {
            throw new IllegalArgumentException("New status must be 'Pending', 'Confirmed', 'Cancelled', or 'Success'");
        }
    }

    public Timestamp getChangedAt() {
        return changedAt;
    }

    public void setChangedAt(Timestamp changedAt) {
        this.changedAt = changedAt;
    }
}