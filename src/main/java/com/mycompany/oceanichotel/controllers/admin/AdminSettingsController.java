package com.mycompany.oceanichotel.controllers.admin;

import com.mycompany.oceanichotel.services.admin.AdminSettingsService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.sql.SQLException;
import java.util.logging.Level;
import java.util.logging.Logger;

@WebServlet("/admin/settings/*")
public class AdminSettingsController extends HttpServlet {

    private AdminSettingsService settingsService;
    private static final Logger LOGGER = Logger.getLogger(AdminSettingsController.class.getName());

    @Override
    public void init() throws ServletException {
        settingsService = new AdminSettingsService();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.getRequestDispatcher("/WEB-INF/views/admin/settings.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String pathInfo = request.getPathInfo();
        try {
            if (pathInfo.equals("/update")) {
                String defaultLanguage = request.getParameter("defaultLanguage");
                String defaultTheme = request.getParameter("defaultTheme");
                settingsService.updateSettings(defaultLanguage, defaultTheme);
                request.getSession().setAttribute("language", defaultLanguage);
                request.getSession().setAttribute("theme", defaultTheme);
                response.sendRedirect(request.getContextPath() + "/admin/settings?message=update_success");
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Database error in doPost", e);
            request.setAttribute("error", "Failed to update settings: " + e.getMessage());
            request.getRequestDispatcher("/WEB-INF/views/admin/settings.jsp").forward(request, response);
        }
    }
}