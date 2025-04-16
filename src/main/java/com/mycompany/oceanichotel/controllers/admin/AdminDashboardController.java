/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.mycompany.oceanichotel.controllers.admin;
/*
 * Copyright (c) 2025 annc19324
 * All rights reserved.
 *
 * This code is the property of annc19324.
 * Unauthorized copying or distribution is prohibited.
 */
import com.mycompany.oceanichotel.models.User;
import com.mycompany.oceanichotel.utils.DatabaseUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.time.LocalDate;

/**
 *
 * @author annc1
 */
@WebServlet("/admin/dashboard")
public class AdminDashboardController extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session != null && session.getAttribute("user") != null) {
            User user = (User) session.getAttribute("user");
            if ("admin".equals(user.getRole())) {
                try {
                    // Lấy dữ liệu tổng quan
                    int checkInToday = getCheckInToday();
                    int checkOutToday = getCheckOutToday();
                    int totalInHotel = getTotalInHotel();
                    int availableRooms = getAvailableRooms();
                    int occupiedRooms = getOccupiedRooms();

                    // Đặt dữ liệu vào request
                    request.setAttribute("checkInToday", checkInToday);
                    request.setAttribute("checkOutToday", checkOutToday);
                    request.setAttribute("totalInHotel", totalInHotel);
                    request.setAttribute("availableRooms", availableRooms);
                    request.setAttribute("occupiedRooms", occupiedRooms);
                    request.setAttribute("username", user.getUsername());

                    request.getRequestDispatcher("/WEB-INF/views/admin/dashboard.jsp").forward(request, response);
                    return;
                } catch (SQLException e) {
                    throw new ServletException("Database error", e);
                }
            }
        }
        response.sendRedirect(request.getContextPath() + "/login");
    }
    
    private int getCheckInToday() throws SQLException {
        String query = "SELECT COUNT(*) FROM Bookings WHERE check_in_date = ? AND status = 'Confirmed'";
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(query)) {
            stmt.setDate(1, java.sql.Date.valueOf(LocalDate.now()));
            ResultSet rs = stmt.executeQuery();
            if (rs.next()) {
                return rs.getInt(1);
            }
        }
        return 0;
    }

    private int getCheckOutToday() throws SQLException {
        String query = "SELECT COUNT(*) FROM Bookings WHERE check_out_date = ? AND status = 'Confirmed'";
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(query)) {
            stmt.setDate(1, java.sql.Date.valueOf(LocalDate.now()));
            ResultSet rs = stmt.executeQuery();
            if (rs.next()) {
                return rs.getInt(1);
            }
        }
        return 0;
    }
    
    private int getTotalInHotel() throws SQLException {
        String query = "SELECT COUNT(*) FROM Bookings WHERE check_in_date <= ? AND check_out_date >= ? AND status = 'Confirmed'";
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(query)) {
            LocalDate today = LocalDate.now();
            stmt.setDate(1, java.sql.Date.valueOf(today));
            stmt.setDate(2, java.sql.Date.valueOf(today));
            ResultSet rs = stmt.executeQuery();
            if (rs.next()) {
                return rs.getInt(1);
            }
        }
        return 0;
    }

    private int getAvailableRooms() throws SQLException {
        String query = "SELECT COUNT(*) FROM Rooms WHERE is_available = 1";
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(query)) {
            ResultSet rs = stmt.executeQuery();
            if (rs.next()) {
                return rs.getInt(1);
            }
        }
        return 0;
    }

    private int getOccupiedRooms() throws SQLException {
        String query = "SELECT COUNT(*) FROM Rooms WHERE is_available = 0";
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(query)) {
            ResultSet rs = stmt.executeQuery();
            if (rs.next()) {
                return rs.getInt(1);
            }
        }
        return 0;
    }
}
