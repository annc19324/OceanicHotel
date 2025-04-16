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
import java.util.ArrayList;
import java.util.List;

public class RoomType {
    private int typeId;
    private String typeName;
    private BigDecimal defaultPrice;
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
    public BigDecimal getDefaultPrice() { return defaultPrice; }
    public void setDefaultPrice(BigDecimal defaultPrice) { this.defaultPrice = defaultPrice; }
    public int getMaxAdults() { return maxAdults; }
    public void setMaxAdults(int maxAdults) {
        if (maxAdults > 0) this.maxAdults = maxAdults;
        else throw new IllegalArgumentException("maxAdults must be greater than 0");
    }
    public int getMaxChildren() { return maxChildren; }
    public void setMaxChildren(int maxChildren) {
        if (maxChildren >= 0) this.maxChildren = maxChildren;
        else throw new IllegalArgumentException("maxChildren must be non-negative");
    }
    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }
    public Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }
    public List<RoomTypeImage> getImages() { return images; }
    public void setImages(List<RoomTypeImage> images) { this.images = images; }
    public void addImage(RoomTypeImage image) { this.images.add(image); }

    public RoomTypeImage getPrimaryImage() {
        return images.stream().filter(RoomTypeImage::isPrimary).findFirst().orElse(null);
    }
}