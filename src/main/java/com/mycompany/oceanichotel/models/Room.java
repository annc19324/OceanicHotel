package com.mycompany.oceanichotel.models;

import java.sql.Timestamp;

public class Room {
    private int roomId;
    private String roomNumber;
    private RoomType roomType;
    private double pricePerNight;
    private boolean isAvailable;
    private String description;
    private int maxAdults;
    private int maxChildren;
    private Timestamp createdAt;

    // Getters và Setters
    public int getRoomId() { return roomId; }
    public void setRoomId(int roomId) { this.roomId = roomId; }
    public String getRoomNumber() { return roomNumber; }
    public void setRoomNumber(String roomNumber) { this.roomNumber = roomNumber; }
    public RoomType getRoomType() { return roomType; }
    public void setRoomType(RoomType roomType) { this.roomType = roomType; }
    public double getPricePerNight() { return pricePerNight; }
    public void setPricePerNight(double pricePerNight) { this.pricePerNight = pricePerNight; }
    public boolean isAvailable() { return isAvailable; }
    public void setAvailable(boolean available) { isAvailable = available; }
    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }
    public int getMaxAdults() { return maxAdults; }
    public void setMaxAdults(int maxAdults) { this.maxAdults = maxAdults; }
    public int getMaxChildren() { return maxChildren; }
    public void setMaxChildren(int maxChildren) { this.maxChildren = maxChildren; }
    public Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }
    
    // Convenience method to get primary image from room type
    public RoomTypeImage getPrimaryImage() {
        if (roomType != null) {
            return roomType.getPrimaryImage();
        }
        return null;
    }
}