package com.mycompany.oceanichotel.models;

import java.sql.Timestamp;

public class Room {
    private int roomId;
    private String roomNumber;
    private String roomType;
    private double pricePerNight;
    private boolean isAvailable;
    private String description;
    private String imageUrl;       // Đường dẫn đến hình ảnh phòng
    private int maxAdults;         // Số người lớn tối đa
    private int maxChildren;       // Số trẻ em tối đa
    private Timestamp createdAt;

    // Constructors
    public Room() {
    }

    public Room(int roomId, String roomNumber, String roomType, double pricePerNight, 
                boolean isAvailable, String description, String imageUrl, int maxAdults, 
                int maxChildren, Timestamp createdAt) {
        this.roomId = roomId;
        this.roomNumber = roomNumber;
        this.roomType = roomType;
        this.pricePerNight = pricePerNight;
        this.isAvailable = isAvailable;
        this.description = description;
        this.imageUrl = imageUrl;
        this.maxAdults = maxAdults;
        this.maxChildren = maxChildren;
        this.createdAt = createdAt;
    }

    // Getters and Setters
    public int getRoomId() { return roomId; }
    public void setRoomId(int roomId) { this.roomId = roomId; }

    public String getRoomNumber() { return roomNumber; }
    public void setRoomNumber(String roomNumber) { this.roomNumber = roomNumber; }

    public String getRoomType() { return roomType; }
    public void setRoomType(String roomType) { this.roomType = roomType; }

    public double getPricePerNight() { return pricePerNight; }
    public void setPricePerNight(double pricePerNight) { this.pricePerNight = pricePerNight; }

    public boolean isAvailable() { return isAvailable; }
    public void setAvailable(boolean available) { this.isAvailable = available; }

    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }

    public String getImageUrl() { return imageUrl; }
    public void setImageUrl(String imageUrl) { this.imageUrl = imageUrl; }

    public int getMaxAdults() { return maxAdults; }
    public void setMaxAdults(int maxAdults) { this.maxAdults = maxAdults; }

    public int getMaxChildren() { return maxChildren; }
    public void setMaxChildren(int maxChildren) { this.maxChildren = maxChildren; }

    public Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }

    @Override
    public String toString() {
        return "Room{" +
                "roomId=" + roomId +
                ", roomNumber='" + roomNumber + '\'' +
                ", roomType='" + roomType + '\'' +
                ", pricePerNight=" + pricePerNight +
                ", isAvailable=" + isAvailable +
                ", description='" + description + '\'' +
                ", imageUrl='" + imageUrl + '\'' +
                ", maxAdults=" + maxAdults +
                ", maxChildren=" + maxChildren +
                ", createdAt=" + createdAt +
                '}';
    }
}