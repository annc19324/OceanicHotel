package com.mycompany.oceanichotel.controllers.user;
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
import java.sql.SQLException;
import java.util.logging.Level;
import java.util.logging.Logger;

@WebServlet("/user/change-language")
public class ChangeLanguageController extends HttpServlet {
    private static final Logger LOGGER = Logger.getLogger(ChangeLanguageController.class.getName());

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendError(HttpServletResponse.SC_UNAUTHORIZED, "Please login first.");
            return;
        }

        User user = (User) session.getAttribute("user");
        String language = request.getParameter("language");

        if (language != null && (language.equals("en") || language.equals("vi"))) {
            user.setLanguage(language);
            session.setAttribute("language", language);
            session.setAttribute("user", user);

            String query = "UPDATE Users SET language = ? WHERE user_id = ?";
            try (Connection conn = DatabaseUtil.getConnection();
                 PreparedStatement stmt = conn.prepareStatement(query)) {
                stmt.setString(1, language);
                stmt.setInt(2, user.getUserId());
                stmt.executeUpdate();
                LOGGER.log(Level.INFO, "Language updated for user {0} to {1}", new Object[]{user.getUsername(), language});
            } catch (SQLException e) {
                LOGGER.log(Level.SEVERE, "Error updating language in database", e);
                response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Database error.");
                return;
            }

            response.setStatus(HttpServletResponse.SC_OK);
        } else {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid language value.");
        }
    }
}