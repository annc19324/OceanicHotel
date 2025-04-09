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
import java.math.BigDecimal;
import java.net.URLEncoder;
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
    private static final String UPLOAD_DIR = "assets/images";

    @Override
    public void init() throws ServletException {
        roomTypeService = new AdminRoomTypeService();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String pathInfo = request.getPathInfo();
        try {
            if (pathInfo == null || pathInfo.equals("/")) {
                List<RoomType> roomTypes = roomTypeService.getAllRoomTypes();
                request.setAttribute("roomTypes", roomTypes);
                request.getRequestDispatcher("/WEB-INF/views/admin/room_types.jsp").forward(request, response);
            } else if (pathInfo.equals("/add")) {
                request.getRequestDispatcher("/WEB-INF/views/admin/add_room_type.jsp").forward(request, response);
            } else if (pathInfo.equals("/edit")) {
                String typeIdStr = request.getParameter("typeId");
                if (typeIdStr == null || typeIdStr.trim().isEmpty()) {
                    response.sendRedirect(request.getContextPath() + "/admin/room-types?error=invalid_type_id");
                    return;
                }
                int typeId = Integer.parseInt(typeIdStr);
                RoomType roomType = roomTypeService.getRoomTypeById(typeId);
                if (roomType != null) {
                    request.setAttribute("roomType", roomType);
                    request.getRequestDispatcher("/WEB-INF/views/admin/edit_room_type.jsp").forward(request, response);
                } else {
                    response.sendRedirect(request.getContextPath() + "/admin/room-types?error=type_not_found");
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Lỗi cơ sở dữ liệu trong doGet", e);
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Database error: " + e.getMessage());
        } catch (NumberFormatException e) {
            LOGGER.log(Level.WARNING, "typeId không hợp lệ", e);
            response.sendRedirect(request.getContextPath() + "/admin/room-types?error=invalid_type_id");
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String pathInfo = request.getPathInfo();
        String language = (String) request.getSession().getAttribute("language");
        if (language == null) {
            language = "en";
        }

        try {
            if (pathInfo.equals("/add")) {
                RoomType roomType = new RoomType();
                roomType.setTypeName(request.getParameter("typeName"));
                roomType.setDefaultPrice(new BigDecimal(request.getParameter("defaultPrice")));
                roomType.setMaxAdults(Integer.parseInt(request.getParameter("maxAdults")));
                roomType.setMaxChildren(Integer.parseInt(request.getParameter("maxChildren")));
                roomType.setDescription(request.getParameter("description"));

                List<Part> fileParts = request.getParts().stream()
                        .filter(part -> "images".equals(part.getName()) && part.getSize() > 0)
                        .collect(Collectors.toList());
                String uploadPath = getServletContext().getRealPath("") + File.separator + UPLOAD_DIR;
                File uploadDir = new File(uploadPath);
                if (!uploadDir.exists()) {
                    uploadDir.mkdirs();
                }

                for (int i = 0; i < fileParts.size(); i++) {
                    Part filePart = fileParts.get(i);
                    String fileName = generateUniqueFileName(extractFileName(filePart));
                    File file = new File(uploadPath + File.separator + fileName);
                    filePart.write(file.getAbsolutePath());
                    RoomTypeImage image = new RoomTypeImage();
                    image.setImageUrl(fileName);
                    image.setIsPrimary(i == 0);
                    roomType.addImage(image);
                }

                roomTypeService.addRoomType(roomType);
                response.sendRedirect(request.getContextPath() + "/admin/room-types?message=add_success");
            } else if (pathInfo.equals("/upload-images")) {
                String typeIdStr = request.getParameter("typeId");
                if (typeIdStr == null || typeIdStr.trim().isEmpty()) {
                    request.setAttribute("error", language.equals("vi") ? "Không tìm thấy ID loại phòng!" : "Room type ID not found!");
                    forwardToEditPage(request, response, -1);
                    return;
                }
                int typeId = Integer.parseInt(typeIdStr);
                RoomType existingRoomType = roomTypeService.getRoomTypeById(typeId);
                if (existingRoomType == null) {
                    response.sendRedirect(request.getContextPath() + "/admin/room-types?error=type_not_found");
                    return;
                }

                List<Part> fileParts = request.getParts().stream()
                        .filter(part -> "images".equals(part.getName()) && part.getSize() > 0)
                        .collect(Collectors.toList());
                if (fileParts.isEmpty()) {
                    request.setAttribute("error", language.equals("vi") ? "Vui lòng chọn ít nhất một ảnh!" : "Please select at least one image!");
                    forwardToEditPage(request, response, typeId);
                    return;
                }

                String uploadPath = getServletContext().getRealPath("") + File.separator + UPLOAD_DIR;
                File uploadDir = new File(uploadPath);
                if (!uploadDir.exists()) {
                    uploadDir.mkdirs();
                }

                boolean isFirstImage = existingRoomType.getImages().isEmpty();
                for (int i = 0; i < fileParts.size(); i++) {
                    Part filePart = fileParts.get(i);
                    String fileName = generateUniqueFileName(extractFileName(filePart));
                    File file = new File(uploadPath + File.separator + fileName);
                    filePart.write(file.getAbsolutePath());
                    RoomTypeImage image = new RoomTypeImage();
                    image.setImageUrl(fileName);
                    image.setIsPrimary(isFirstImage && i == 0);
                    roomTypeService.addRoomTypeImage(typeId, image);
                }
                response.sendRedirect(request.getContextPath() + "/admin/room-types/edit?typeId=" + typeId + "&message=image_upload_success");
            } else if (pathInfo.equals("/update")) {
                int typeId = Integer.parseInt(request.getParameter("typeId"));
                RoomType roomType = new RoomType();
                roomType.setTypeId(typeId);
                roomType.setTypeName(request.getParameter("typeName"));
                roomType.setDefaultPrice(new BigDecimal(request.getParameter("defaultPrice")));
                roomType.setMaxAdults(Integer.parseInt(request.getParameter("maxAdults")));
                roomType.setMaxChildren(Integer.parseInt(request.getParameter("maxChildren")));
                roomType.setDescription(request.getParameter("description"));

                roomTypeService.updateRoomType(roomType);
                response.sendRedirect(request.getContextPath() + "/admin/room-types?message=update_success");
            } else if (pathInfo.equals("/delete")) {
                int typeId = Integer.parseInt(request.getParameter("typeId"));
                try {
                    RoomType roomType = roomTypeService.getRoomTypeById(typeId);
                    if (roomType != null) {
                        roomTypeService.deleteRoomType(typeId); // Có thể ném SQLException
                        response.sendRedirect(request.getContextPath() + "/admin/room-types?message=delete_success");
                    } else {
                        response.sendRedirect(request.getContextPath() + "/admin/room-types?error=type_not_found");
                    }
                } catch (SQLException e) {
                    LOGGER.log(Level.WARNING, "Failed to delete room type", e);
                    String errorMsg = language.equals("vi")
                            ? "Không thể xóa loại phòng vì đang được sử dụng bởi " + e.getMessage().split("by ")[1]
                            : e.getMessage();
                    response.sendRedirect(request.getContextPath() + "/admin/room-types?error=" + URLEncoder.encode(errorMsg, "UTF-8"));
                }
            } else if (pathInfo.equals("/delete-image")) {
                String imageIdStr = request.getParameter("imageId");
                String typeIdStr = request.getParameter("typeId");
                if (imageIdStr == null || typeIdStr == null || imageIdStr.trim().isEmpty() || typeIdStr.trim().isEmpty()) {
                    request.setAttribute("error", language.equals("vi") ? "Tham số không hợp lệ!" : "Invalid parameters!");
                    forwardToEditPage(request, response, Integer.parseInt(typeIdStr != null ? typeIdStr : "-1"));
                    return;
                }
                int imageId = Integer.parseInt(imageIdStr);
                int typeId = Integer.parseInt(typeIdStr);
                RoomTypeImage image = roomTypeService.getImageById(imageId);
                if (image != null && image.getTypeId() == typeId) {
                    File imageFile = new File(getServletContext().getRealPath("") + File.separator + UPLOAD_DIR + File.separator + image.getImageUrl());
                    if (imageFile.exists() && !imageFile.delete()) {
                        LOGGER.warning("Không thể xóa file ảnh: " + imageFile.getAbsolutePath());
                    }
                    roomTypeService.deleteRoomTypeImage(imageId);
                    response.sendRedirect(request.getContextPath() + "/admin/room-types/edit?typeId=" + typeId + "&message=image_deleted");
                } else {
                    request.setAttribute("error", language.equals("vi") ? "Không tìm thấy ảnh để xóa!" : "Image not found!");
                    forwardToEditPage(request, response, typeId);
                }
            } else if (pathInfo.equals("/set-primary")) {
                String imageIdStr = request.getParameter("imageId");
                String typeIdStr = request.getParameter("typeId");
                if (imageIdStr == null || typeIdStr == null || imageIdStr.trim().isEmpty() || typeIdStr.trim().isEmpty()) {
                    request.setAttribute("error", language.equals("vi") ? "Tham số không hợp lệ!" : "Invalid parameters!");
                    forwardToEditPage(request, response, Integer.parseInt(typeIdStr != null ? typeIdStr : "-1"));
                    return;
                }
                int imageId = Integer.parseInt(imageIdStr);
                int typeId = Integer.parseInt(typeIdStr);
                RoomTypeImage image = roomTypeService.getImageById(imageId);
                if (image != null && image.getTypeId() == typeId) {
                    roomTypeService.setPrimaryImage(typeId, imageId);
                    response.sendRedirect(request.getContextPath() + "/admin/room-types/edit?typeId=" + typeId + "&message=primary_set");
                } else {
                    request.setAttribute("error", language.equals("vi") ? "Không tìm thấy ảnh để đặt làm chính!" : "Image not found for setting as primary!");
                    forwardToEditPage(request, response, typeId);
                }
            } else {
                response.sendError(HttpServletResponse.SC_NOT_FOUND, "Invalid action");
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Lỗi cơ sở dữ liệu trong doPost", e);
            request.setAttribute("error", language.equals("vi") ? "Lỗi cơ sở dữ liệu: " + e.getMessage() : "Database error: " + e.getMessage());
            forwardToEditPage(request, response, Integer.parseInt(request.getParameter("typeId") != null ? request.getParameter("typeId") : "-1"));
        } catch (NumberFormatException e) {
            LOGGER.log(Level.WARNING, "Tham số không hợp lệ", e);
            request.setAttribute("error", language.equals("vi") ? "Tham số không hợp lệ!" : "Invalid parameters!");
            forwardToEditPage(request, response, Integer.parseInt(request.getParameter("typeId") != null ? request.getParameter("typeId") : "-1"));
        } catch (IOException e) {
            LOGGER.log(Level.SEVERE, "Lỗi khi xử lý file", e);
            request.setAttribute("error", language.equals("vi") ? "Lỗi khi xử lý file: " + e.getMessage() : "File processing error: " + e.getMessage());
            forwardToEditPage(request, response, Integer.parseInt(request.getParameter("typeId") != null ? request.getParameter("typeId") : "-1"));
        }
    }

    private void forwardToEditPage(HttpServletRequest request, HttpServletResponse response, int typeId) throws ServletException, IOException {
        if (typeId == -1) {
            response.sendRedirect(request.getContextPath() + "/admin/room-types?error=invalid_type_id");
            return;
        }
        try {
            RoomType roomType = roomTypeService.getRoomTypeById(typeId);
            if (roomType != null) {
                request.setAttribute("roomType", roomType);
                request.getRequestDispatcher("/WEB-INF/views/admin/edit_room_type.jsp").forward(request, response);
            } else {
                response.sendRedirect(request.getContextPath() + "/admin/room-types?error=type_not_found");
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Lỗi khi lấy RoomType với typeId=" + typeId, e);
            response.sendRedirect(request.getContextPath() + "/admin/room-types?error=database_error");
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

    private String generateUniqueFileName(String originalFileName) {
        String extension = originalFileName.substring(originalFileName.lastIndexOf("."));
        String baseName = originalFileName.substring(0, originalFileName.lastIndexOf("."));
        return baseName + "_" + System.currentTimeMillis() + extension;
    }
}
