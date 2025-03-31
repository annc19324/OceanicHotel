package com.mycompany.oceanichotel.models;

import java.util.Date;

public class Booking {
    
    private int bookingId;
    private int userId;
    private int roomId;
    private Date checkInDate;
    private Date checkOutDate;
    private int adults;
    private int children;
    private double totalPrice;
    private String status;
    private int nights;
    private boolean canCancel;
    private Room room;  // Thêm thuộc tính room
    private boolean hasPendingTransaction; // Thêm thuộc tính này
    private Date createdAt; // Thêm thuộc tính này

    // Getters and Setters
    public int getBookingId() { return bookingId; }
    public void setBookingId(int bookingId) { this.bookingId = bookingId; }
    public int getUserId() { return userId; }
    public void setUserId(int userId) { this.userId = userId; }
    public int getRoomId() { return roomId; }
    public void setRoomId(int roomId) { this.roomId = roomId; }
    public Date getCheckInDate() { return checkInDate; }
    public void setCheckInDate(Date checkInDate) { this.checkInDate = checkInDate; }
    public Date getCheckOutDate() { return checkOutDate; }
    public void setCheckOutDate(Date checkOutDate) { this.checkOutDate = checkOutDate; }
    public int getAdults() { return adults; }
    public void setAdults(int adults) { this.adults = adults; }
    public int getChildren() { return children; }
    public void setChildren(int children) { this.children = children; }
    public double getTotalPrice() { return totalPrice; }
    public void setTotalPrice(double totalPrice) { this.totalPrice = totalPrice; }
    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }
    public int getNights() { return nights; }
    public void setNights(int nights) { this.nights = nights; }
    public boolean isCanCancel() { return canCancel; }
    public void setCanCancel(boolean canCancel) { this.canCancel = canCancel; }
    public Room getRoom() { return room; }  // Thêm getter cho room
    public void setRoom(Room room) { this.room = room; }  // Thêm setter cho room
    public boolean isHasPendingTransaction() { return hasPendingTransaction; }
    public void setHasPendingTransaction(boolean hasPendingTransaction) { this.hasPendingTransaction = hasPendingTransaction; }
    // Getters and Setters
    public Date getCreatedAt() { return createdAt; }
    public void setCreatedAt(Date createdAt) { this.createdAt = createdAt; }
}