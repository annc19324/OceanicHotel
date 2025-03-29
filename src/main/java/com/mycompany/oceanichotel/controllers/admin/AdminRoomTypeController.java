package com.mycompany.oceanichotel.controllers.admin;

import com.mycompany.oceanichotel.models.RoomType;
import com.mycompany.oceanichotel.models.RoomTypeImage;
import com.mycompany.oceanichotel.services.admin.AdminRoomTypeService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.Part;
import java.io.File;
import java.io.IOException;
import java.sql.SQLException;
import java.util.List;
import java.util.logging.Logger;
import java.util.logging.Level;
import java.util.stream.Collectors;

@WebServlet("/admin/room-types/*")
@MultipartConfig(fileSizeThreshold = 1024 * 1024 * 2, maxFileSize = 1024 * 1024 * 10, maxRequestSize = 1024 * 1024 * 50)
public class AdminRoomTypeController extends HttpServlet {

    private AdminRoomTypeService roomTypeService;
    private static final Logger LOGGER = Logger.getLogger(AdminRoomTypeController.class.getName());
    private static final String UPLOAD_DIR = "assets/images/room-types";

    @Override
    public void init() throws ServletException {
        roomTypeService = new AdminRoomTypeService();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String pathInfo = request.getPathInfo();
        try {
            if (pathInfo == null || pathInfo.equals("/")) {
                List<RoomType> roomTypes = roomTypeService.getAllRoomTypes();
                request.setAttribute("roomTypes", roomTypes);
                request.getRequestDispatcher("/WEB-INF/views/admin/room_types.jsp").forward(request, response);
            } else if (pathInfo.equals("/add")) {
                request.getRequestDispatcher("/WEB-INF/views/admin/add_room_type.jsp").forward(request, response);
            } else if (pathInfo.equals("/edit")) {
                int typeId = Integer.parseInt(request.getParameter("typeId"));
                RoomType roomType = roomTypeService.getRoomTypeById(typeId);
                if (roomType != null) {
                    request.setAttribute("roomType", roomType);
                    request.getRequestDispatcher("/WEB-INF/views/admin/edit_room_type.jsp").forward(request, response);
                } else {
                    response.sendRedirect(request.getContextPath() + "/admin/room-types?error=type_not_found");
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Database error in doGet", e);
            throw new ServletException("Database error", e);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String pathInfo = request.getPathInfo();
        String language = (String) request.getSession().getAttribute("language");
        if (language == null) language = "en";

        try {
            if (pathInfo.equals("/add")) {
                RoomType roomType = new RoomType();
                roomType.setTypeName(request.getParameter("typeName"));
                roomType.setDefaultPrice(Double.parseDouble(request.getParameter("defaultPrice")));
                roomType.setMaxAdults(Integer.parseInt(request.getParameter("maxAdults")));
                roomType.setMaxChildren(Integer.parseInt(request.getParameter("maxChildren")));
                roomType.setDescription(request.getParameter("description"));

                List<Part> fileParts = request.getParts().stream()
                        .filter(part -> "images".equals(part.getName()) && part.getSize() > 0)
                        .collect(Collectors.toList());
                String uploadPath = getServletContext().getRealPath("") + File.separator + UPLOAD_DIR;
                File uploadDir = new File(uploadPath);
                if (!uploadDir.exists()) uploadDir.mkdir();

                for (int i = 0; i < fileParts.size(); i++) {
                    Part filePart = fileParts.get(i);
                    String fileName = extractFileName(filePart);
                    filePart.write(uploadPath + File.separator + fileName);
                    RoomTypeImage image = new RoomTypeImage();
                    image.setImageUrl(fileName);
                    image.setPrimary(i == 0); // Hình đầu tiên là chính
                    roomType.addImage(image);
                }

                roomTypeService.addRoomType(roomType);
                response.sendRedirect(request.getContextPath() + "/admin/room-types?message=add_success");
            } else if (pathInfo.equals("/update")) {
                int typeId = Integer.parseInt(request.getParameter("typeId"));
                RoomType roomType = new RoomType();
                roomType.setTypeId(typeId);
                roomType.setTypeName(request.getParameter("typeName"));
                roomType.setDefaultPrice(Double.parseDouble(request.getParameter("defaultPrice")));
                roomType.setMaxAdults(Integer.parseInt(request.getParameter("maxAdults")));
                roomType.setMaxChildren(Integer.parseInt(request.getParameter("maxChildren")));
                roomType.setDescription(request.getParameter("description"));

                List<Part> fileParts = request.getParts().stream()
                        .filter(part -> "images".equals(part.getName()) && part.getSize() > 0)
                        .collect(Collectors.toList());
                String uploadPath = getServletContext().getRealPath("") + File.separator + UPLOAD_DIR;
                File uploadDir = new File(uploadPath);
                if (!uploadDir.exists()) uploadDir.mkdir();

                if (!fileParts.isEmpty()) {
                    RoomType existingRoomType = roomTypeService.getRoomTypeById(typeId);
                    roomType.setImages(existingRoomType.getImages());
                    for (int i = 0; i < fileParts.size(); i++) {
                        Part filePart = fileParts.get(i);
                        String fileName = extractFileName(filePart);
                        filePart.write(uploadPath + File.separator + fileName);
                        RoomTypeImage image = new RoomTypeImage();
                        image.setImageUrl(fileName);
                        image.setPrimary(i == 0 && roomType.getImages().isEmpty());
                        roomTypeService.addRoomTypeImage(typeId, image);
                    }
                }

                roomTypeService.updateRoomType(roomType);
                response.sendRedirect(request.getContextPath() + "/admin/room-types?message=update_success");
            } else if (pathInfo.equals("/delete")) {
                int typeId = Integer.parseInt(request.getParameter("typeId"));
                roomTypeService.deleteRoomType(typeId);
                response.sendRedirect(request.getContextPath() + "/admin/room-types?message=delete_success");
            } else if (pathInfo.equals("/delete-image")) {
                int imageId = Integer.parseInt(request.getParameter("imageId"));
                roomTypeService.deleteRoomTypeImage(imageId);
                response.sendRedirect(request.getContextPath() + "/admin/room-types/edit?typeId=" + request.getParameter("typeId"));
            } else if (pathInfo.equals("/set-primary")) {
                int typeId = Integer.parseInt(request.getParameter("typeId"));
                int imageId = Integer.parseInt(request.getParameter("imageId"));
                roomTypeService.setPrimaryImage(typeId, imageId);
                response.sendRedirect(request.getContextPath() + "/admin/room-types/edit?typeId=" + typeId);
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Database error in doPost", e);
            request.setAttribute("error", language.equals("vi") ? "Lỗi cơ sở dữ liệu!" : "Database error!");
            request.getRequestDispatcher("/WEB-INF/views/admin/edit_room_type.jsp").forward(request, response);
        }
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