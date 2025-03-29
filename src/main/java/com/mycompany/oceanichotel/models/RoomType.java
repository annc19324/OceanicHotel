package com.mycompany.oceanichotel.models;

import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.List;

public class RoomType {
    private int typeId;
    private String typeName;
    private double defaultPrice;
    private int maxAdults;
    private int maxChildren;
    private String description;
    private Timestamp createdAt;
    private List<RoomTypeImage> images = new ArrayList<>();

    // Getters và Setters
    public int getTypeId() { return typeId; }
    public void setTypeId(int typeId) { this.typeId = typeId; }
    public String getTypeName() { return typeName; }
    public void setTypeName(String typeName) { this.typeName = typeName; }
    public double getDefaultPrice() { return defaultPrice; }
    public void setDefaultPrice(double defaultPrice) { this.defaultPrice = defaultPrice; }
    public int getMaxAdults() { return maxAdults; }
    public void setMaxAdults(int maxAdults) { this.maxAdults = maxAdults; }
    public int getMaxChildren() { return maxChildren; }
    public void setMaxChildren(int maxChildren) { this.maxChildren = maxChildren; }
    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }
    public Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }
    public List<RoomTypeImage> getImages() { return images; }
    public void setImages(List<RoomTypeImage> images) { this.images = images; }
    public void addImage(RoomTypeImage image) { this.images.add(image); }

    // Lấy hình ảnh chính
    public RoomTypeImage getPrimaryImage() {
        return images.stream().filter(RoomTypeImage::isPrimary).findFirst().orElse(null);
    }
}