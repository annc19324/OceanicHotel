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
        System.out.println("SettingsServlet: Received POST request");
        
        HttpSession session = request.getSession();
        
        String language = request.getParameter("language");
        if (language != null && (language.equals("en") || language.equals("vi"))) {
            session.setAttribute("language", language);
            System.out.println("Language set to: " + language);
        }

        String theme = request.getParameter("theme");
        if (theme != null && (theme.equals("light") || theme.equals("dark"))) {
            session.setAttribute("theme", theme);
            System.out.println("Theme set to: " + theme);
        }

        String referer = request.getHeader("Referer");
        System.out.println("Redirecting to: " + (referer != null ? referer : request.getContextPath() + "/login"));
        response.sendRedirect(referer != null ? referer : request.getContextPath() + "/login");
    }
}