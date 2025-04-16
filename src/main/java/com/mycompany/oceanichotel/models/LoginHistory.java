package com.mycompany.oceanichotel.models;
/*
 * Copyright (c) 2025 annc19324
 * All rights reserved.
 *
 * This code is the property of annc19324.
 * Unauthorized copying or distribution is prohibited.
 */
import java.sql.Timestamp;

public class LoginHistory {
    private int loginId;
    private int userId;
    private Timestamp loginTime;
    private String ipAddress;

    // Getters and Setters
    public int getLoginId() { return loginId; }
    public void setLoginId(int loginId) { this.loginId = loginId; }
    public int getUserId() { return userId; }
    public void setUserId(int userId) { this.userId = userId; }
    public Timestamp getLoginTime() { return loginTime; }
    public void setLoginTime(Timestamp loginTime) { this.loginTime = loginTime; }
    public String getIpAddress() { return ipAddress; }
    public void setIpAddress(String ipAddress) { this.ipAddress = ipAddress; }
}