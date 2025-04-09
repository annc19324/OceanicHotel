package com.mycompany.oceanichotel.models;

import java.math.BigDecimal;
import java.sql.Timestamp;
import java.util.Date;

public class Booking {
    // Các thuộc tính hiện có
    private int bookingId;
    private int userId;
    private int roomId;
    private Date checkInDate;
    private Date checkOutDate;
    private int numAdults;
    private int numChildren;
    private BigDecimal totalPrice;
    private Integer discountId;
    private BigDecimal discountedPrice;
    private String status;
    private String bookingMethod;
    private Integer receptionistId;
    private int nights;
    private boolean canCancel;
    private Room room;
    private boolean hasPendingTransaction;
    private Timestamp createdAt;
    private String userFullName;
    private String userEmail;
    // Thuộc tính mới
    private String roomNumber;
    private String roomTypeName;

    // Getters và Setters cho các thuộc tính mới
    public String getRoomNumber() { return roomNumber; }
    public void setRoomNumber(String roomNumber) { this.roomNumber = roomNumber; }
    public String getRoomTypeName() { return roomTypeName; }
    public void setRoomTypeName(String roomTypeName) { this.roomTypeName = roomTypeName; }

    // Các getters/setters hiện có giữ nguyên...
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
    public int getNumAdults() { return numAdults; }
    public void setNumAdults(int numAdults) { this.numAdults = numAdults; }
    public int getNumChildren() { return numChildren; }
    public void setNumChildren(int numChildren) { this.numChildren = numChildren; }
    public BigDecimal getTotalPrice() { return totalPrice; }
    public void setTotalPrice(BigDecimal totalPrice) { this.totalPrice = totalPrice; }
    public Integer getDiscountId() { return discountId; }
    public void setDiscountId(Integer discountId) { this.discountId = discountId; }
    public BigDecimal getDiscountedPrice() { return discountedPrice; }
    public void setDiscountedPrice(BigDecimal discountedPrice) { this.discountedPrice = discountedPrice; }
    public String getStatus() { return status; }
    public void setStatus(String status) {
        if (status != null && (status.equals("Pending") || status.equals("Confirmed") || status.equals("Cancelled"))) {
            this.status = status;
        } else {
            throw new IllegalArgumentException("Status must be 'Pending', 'Confirmed', or 'Cancelled'");
        }
    }
    public String getBookingMethod() { return bookingMethod; }
    public void setBookingMethod(String bookingMethod) {
        if (bookingMethod != null && (bookingMethod.equals("Online") || bookingMethod.equals("Onsite"))) {
            this.bookingMethod = bookingMethod;
        } else {
            throw new IllegalArgumentException("Booking method must be 'Online' or 'Onsite'");
        }
    }
    public Integer getReceptionistId() { return receptionistId; }
    public void setReceptionistId(Integer receptionistId) { this.receptionistId = receptionistId; }
    public int getNights() { return nights; }
    public void setNights(int nights) { this.nights = nights; }
    public boolean isCanCancel() { return canCancel; }
    public void setCanCancel(boolean canCancel) { this.canCancel = canCancel; }
    public Room getRoom() { return room; }
    public void setRoom(Room room) { this.room = room; }
    public boolean isHasPendingTransaction() { return hasPendingTransaction; }
    public void setHasPendingTransaction(boolean hasPendingTransaction) { this.hasPendingTransaction = hasPendingTransaction; }
    public Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }
    public String getUserFullName() { return userFullName; }
    public void setUserFullName(String userFullName) { this.userFullName = userFullName; }
    public String getUserEmail() { return userEmail; }
    public void setUserEmail(String userEmail) { this.userEmail = userEmail; }
}