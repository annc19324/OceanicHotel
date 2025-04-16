package com.mycompany.oceanichotel.controllers.user;
/*
 * Copyright (c) 2025 annc19324
 * All rights reserved.
 *
 * This code is the property of annc19324.
 * Unauthorized copying or distribution is prohibited.
 */
import com.mycompany.oceanichotel.models.User;
import com.mycompany.oceanichotel.services.user.UserService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import jakarta.servlet.http.Part;
import java.io.File;
import java.io.IOException;
import java.sql.SQLException;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.logging.Level;
import java.util.logging.Logger;

@WebServlet("/user/profile")
@MultipartConfig(fileSizeThreshold = 1024 * 1024 * 2, // 2MB
        maxFileSize = 1024 * 1024 * 10, // 10MB
        maxRequestSize = 1024 * 1024 * 50) // 50MB
public class UserProfileController extends HttpServlet {

    private UserService userService;
    private static final Logger LOGGER = Logger.getLogger(UserProfileController.class.getName());
    private static final String UPLOAD_DIR = "assets/images"; // Thay đổi để lưu trực tiếp vào /assets/images

    @Override
    public void init() throws ServletException {
        userService = new UserService();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }
        // Lấy thông tin user từ session và chuyển tới JSP
        request.getRequestDispatcher("/WEB-INF/views/user/profile.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        User user = (User) session.getAttribute("user");
        String language = (String) session.getAttribute("language");
        if (language == null) language = "en";

        // Lấy dữ liệu từ form
        String fullName = request.getParameter("fullName");
        String email = request.getParameter("email");
        String phoneNumber = request.getParameter("phoneNumber");
        String cccd = request.getParameter("cccd");
        String dateOfBirthStr = request.getParameter("dateOfBirth");
        String gender = request.getParameter("gender");

        try {
            // Cập nhật thông tin user
            user.setFullName(fullName);
            user.setEmail(email);
            user.setPhoneNumber(phoneNumber);
            user.setCccd(cccd);

            if (dateOfBirthStr != null && !dateOfBirthStr.isEmpty()) {
                SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
                Date dateOfBirth = sdf.parse(dateOfBirthStr);
                user.setDateOfBirth(dateOfBirth);
            } else {
                user.setDateOfBirth(null);
            }

            user.setGender(gender);

            // Xử lý upload avatar
            Part filePart = request.getPart("avatar");
            if (filePart != null && filePart.getSize() > 0) {
                String fileName = user.getUserId() + "_" + System.currentTimeMillis() + "_" + extractFileName(filePart);
                String uploadPath = getServletContext().getRealPath("") + File.separator + UPLOAD_DIR;
                File uploadDir = new File(uploadPath);
                if (!uploadDir.exists()) uploadDir.mkdirs();
                filePart.write(uploadPath + File.separator + fileName);
                user.setAvatar(fileName); // Lưu tên file mới vào user
            }

            // Cập nhật vào database
            userService.updateUser(user);
            session.setAttribute("user", user); // Cập nhật session
            request.setAttribute("message", language.equals("vi") ? "Cập nhật thành công!" : "Updated successfully!");
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error updating user profile for user {0}", String.valueOf(user.getUserId()));
            LOGGER.log(Level.SEVERE, "Exception details: ", e);
            request.setAttribute("message", e.getMessage());
            request.setAttribute("error", true);
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Unexpected error updating user profile", e);
            request.setAttribute("message", language.equals("vi") ? "Lỗi không xác định khi cập nhật!" : "Unknown error updating profile!");
            request.setAttribute("error", true);
        }
        request.getRequestDispatcher("/WEB-INF/views/user/profile.jsp").forward(request, response);
    }

    private String extractFileName(Part part) {
        String contentDisp = part.getHeader("content-disposition");
        String[] items = contentDisp.split(";");
        for (String s : items) {
            if (s.trim().startsWith("filename")) {
                return s.substring(s.indexOf("=") + 2, s.length() - 1);
            }
        }
        return "";
    }
}