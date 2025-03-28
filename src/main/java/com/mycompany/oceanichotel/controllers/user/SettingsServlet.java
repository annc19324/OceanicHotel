package com.mycompany.oceanichotel.controllers.user;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import jakarta.servlet.annotation.WebServlet;

import java.io.IOException;

@WebServlet("/settings")
public class SettingsServlet extends HttpServlet {
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession();
        
        String language = request.getParameter("language");
        if (language != null && (language.equals("en") || language.equals("vi"))) {
            session.setAttribute("language", language);
        }

        String theme = request.getParameter("theme");
        if (theme != null && (theme.equals("light") || theme.equals("dark"))) {
            session.setAttribute("theme", theme);
        }

        String referer = request.getHeader("Referer");
        response.sendRedirect(referer != null ? referer : request.getContextPath() + "/admin/users");
    }
}