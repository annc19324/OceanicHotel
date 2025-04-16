package com.mycompany.oceanichotel.services.admin;
/*
 * Copyright (c) 2025 annc19324
 * All rights reserved.
 *
 * This code is the property of annc19324.
 * Unauthorized copying or distribution is prohibited.
 */
import com.mycompany.oceanichotel.utils.DatabaseUtil;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;
import java.util.logging.Logger;
import java.util.logging.Level;

public class AdminSettingsService {

    private static final Logger LOGGER = Logger.getLogger(AdminSettingsService.class.getName());

    public void updateSettings(String defaultLanguage, String defaultTheme) throws SQLException {
        String query = "MERGE INTO Settings AS target " +
                       "USING (VALUES ('default_language', ?), ('default_theme', ?)) AS source (setting_key, setting_value) " +
                       "ON target.setting_key = source.setting_key " +
                       "WHEN MATCHED THEN UPDATE SET setting_value = source.setting_value " +
                       "WHEN NOT MATCHED THEN INSERT (setting_key, setting_value) VALUES (source.setting_key, source.setting_value);";
        try (Connection conn = DatabaseUtil.getConnection(); PreparedStatement stmt = conn.prepareStatement(query)) {
            stmt.setString(1, defaultLanguage);
            stmt.setString(2, defaultTheme);
            stmt.executeUpdate();
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error updating settings", e);
            throw e;
        }
    }
}