package com.mycompany.oceanichotel.controllers.receptionist;

import com.mycompany.oceanichotel.models.Booking;
import com.mycompany.oceanichotel.models.Transaction;
import com.mycompany.oceanichotel.models.User;
import com.mycompany.oceanichotel.models.Room;
import com.mycompany.oceanichotel.services.admin.AdminBookingService;
import com.mycompany.oceanichotel.services.admin.AdminRoomService;
import com.mycompany.oceanichotel.services.admin.AdminTransactionService;
import com.mycompany.oceanichotel.utils.DatabaseUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.sql.Timestamp;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

@WebServlet("/receptionist/bookings/*")
public class ReceptionistBookingController extends HttpServlet {

    private AdminBookingService bookingService;
    private AdminTransactionService transactionService;
    private AdminRoomService roomService;
    private static final Logger LOGGER = Logger.getLogger(ReceptionistBookingController.class.getName());
    private static final SimpleDateFormat DATE_FORMAT = new SimpleDateFormat("yyyy-MM-dd");

    @Override
    public void init() throws ServletException {
        bookingService = new AdminBookingService();
        transactionService = new AdminTransactionService();
        roomService = new AdminRoomService();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String pathInfo = request.getPathInfo();
        User user = (User) request.getSession().getAttribute("user");
        if (user == null || !"receptionist".equals(user.getRole())) {
            response.sendRedirect(request.getContextPath() + "/login?error=unauthorized");
            return;
        }

        try {
            if (pathInfo == null || pathInfo.equals("/")) {
                int page = request.getParameter("page") != null ? Integer.parseInt(request.getParameter("page")) : 1;
                String search = request.getParameter("search");

                List<Booking> bookings = bookingService.getBookings(page, search);
                int totalBookings = bookingService.getTotalBookings(search);
                int totalPages = (int) Math.ceil((double) totalBookings / 10);

                request.setAttribute("bookings", bookings);
                request.setAttribute("currentPage", page);
                request.setAttribute("totalPages", totalPages);
                request.getRequestDispatcher("/WEB-INF/views/receptionist/bookings.jsp").forward(request, response);
            } else if (pathInfo.equals("/add")) {
                List<Room> availableRooms = roomService.getRooms(1, null, "true", null); // Lấy phòng trống
                request.setAttribute("availableRooms", availableRooms);
                request.getRequestDispatcher("/WEB-INF/views/receptionist/add_booking.jsp").forward(request, response);
            } else if (pathInfo.equals("/checkin") || pathInfo.equals("/checkout") || pathInfo.equals("/update")) {
                handleAction(request, response, pathInfo);
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Database error in doGet", e);
            throw new ServletException("Database error", e);
        } catch (NumberFormatException e) {
            LOGGER.log(Level.WARNING, "Invalid page or bookingId in doGet: " + request.getParameter("page"), e);
            response.sendRedirect(request.getContextPath() + "/receptionist/bookings?error=invalid_input");
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String pathInfo = request.getPathInfo();
        if (pathInfo != null && (pathInfo.equals("/update") || pathInfo.equals("/checkin") || pathInfo.equals("/checkout") || pathInfo.equals("/add"))) {
            if (pathInfo.equals("/add")) {
                handleAddBooking(request, response);
            } else {
                handleAction(request, response, pathInfo);
            }
        } else {
            LOGGER.log(Level.WARNING, "Invalid pathInfo in doPost: " + pathInfo);
            response.sendRedirect(request.getContextPath() + "/receptionist/bookings?error=invalid_request");
        }
    }

    private void handleAction(HttpServletRequest request, HttpServletResponse response, String pathInfo)
            throws ServletException, IOException {
        try {
            String bookingIdParam = request.getParameter("bookingId");
            if (bookingIdParam == null || bookingIdParam.trim().isEmpty()) {
                LOGGER.log(Level.WARNING, "Booking ID is null or empty in handleAction");
                response.sendRedirect(request.getContextPath() + "/receptionist/bookings?error=missing_booking_id");
                return;
            }

            int bookingId = Integer.parseInt(bookingIdParam);
            User user = (User) request.getSession().getAttribute("user");
            if (user == null) {
                response.sendRedirect(request.getContextPath() + "/login?error=session_expired");
                return;
            }

            List<Booking> bookings = bookingService.getBookings(1, String.valueOf(bookingId));
            if (bookings.isEmpty()) {
                LOGGER.log(Level.WARNING, "Booking not found for ID: " + bookingId);
                response.sendRedirect(request.getContextPath() + "/receptionist/bookings?error=booking_not_found");
                return;
            }

            Booking booking = bookings.get(0);
            String currentStatus = booking.getStatus();

            if (pathInfo.equals("/update")) {
                String status = request.getParameter("status");
                if (status == null || (!status.equals("Confirmed") && !status.equals("Cancelled"))) {
                    LOGGER.log(Level.WARNING, "Invalid status received: " + status);
                    response.sendRedirect(request.getContextPath() + "/receptionist/bookings?error=invalid_status");
                    return;
                }

                if (currentStatus.equals("Cancelled") && status.equals("Confirmed")) {
                    LOGGER.log(Level.WARNING, "Cannot change status from Cancelled to Confirmed for booking: " + bookingId);
                    response.sendRedirect(request.getContextPath() + "/receptionist/bookings?error=invalid_status_transition");
                    return;
                }

                bookingService.updateBookingStatus(bookingId, status, user.getUserId());

                if (status.equals("Confirmed") && !currentStatus.equals("Confirmed")) {
                    Transaction transaction = new Transaction();
                    transaction.setBookingId(bookingId);
                    transaction.setUserId(booking.getUserId());
                    transaction.setAmount(booking.getTotalPrice());
                    transaction.setStatus("Pending");
                    transaction.setPaymentMethod("Cash");
                    transaction.setCreatedAt(new Timestamp(System.currentTimeMillis()));
                    transaction.setReceptionistId(user.getUserId());
                    transaction.setUserFullName(booking.getUserFullName());
                    transaction.setUserEmail(booking.getUserEmail());
                    transaction.setRoomNumber(booking.getRoomNumber());
                    transaction.setRoomTypeName(booking.getRoomTypeName());

                    transactionService.createTransaction(transaction);
                    LOGGER.log(Level.INFO, "Pending transaction created for booking: " + bookingId);
                } else if (status.equals("Cancelled") && !currentStatus.equals("Cancelled")) {
                    bookingService.updateRoomAvailability(booking.getRoomId(), true);
                    LOGGER.log(Level.INFO, "Room " + booking.getRoomId() + " set to Available for booking: " + bookingId);
                }
            } else if (pathInfo.equals("/checkin")) {
                if (!currentStatus.equals("Confirmed")) {
                    LOGGER.log(Level.WARNING, "Cannot check-in for booking " + bookingId + " with status: " + currentStatus);
                    response.sendRedirect(request.getContextPath() + "/receptionist/bookings?error=invalid_checkin_status");
                    return;
                }
                bookingService.updateRoomAvailability(booking.getRoomId(), false);
                LOGGER.log(Level.INFO, "Checked-in for booking: " + bookingId);
            } else if (pathInfo.equals("/checkout")) {
                if (!currentStatus.equals("Confirmed")) {
                    LOGGER.log(Level.WARNING, "Cannot check-out for booking " + bookingId + " with status: " + currentStatus);
                    response.sendRedirect(request.getContextPath() + "/receptionist/bookings?error=invalid_checkout_status");
                    return;
                }
                bookingService.updateBookingStatus(bookingId, "Cancelled", user.getUserId());
                bookingService.updateRoomAvailability(booking.getRoomId(), true);
                LOGGER.log(Level.INFO, "Checked-out for booking: " + bookingId);
            }

            response.sendRedirect(request.getContextPath() + "/receptionist/bookings?message=update_success");
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Database error in handleAction for bookingId: " + request.getParameter("bookingId"), e);
            throw new ServletException("Database error", e);
        } catch (NumberFormatException e) {
            LOGGER.log(Level.WARNING, "Invalid bookingId in handleAction: " + request.getParameter("bookingId"), e);
            response.sendRedirect(request.getContextPath() + "/receptionist/bookings?error=invalid_booking_id");
        }
    }

    private void handleAddBooking(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            User user = (User) request.getSession().getAttribute("user");
            if (user == null) {
                response.sendRedirect(request.getContextPath() + "/login?error=session_expired");
                return;
            }

            // Lấy thông tin từ form
            String fullName = request.getParameter("full_name");
            String email = request.getParameter("email");
            String cccd = request.getParameter("cccd");
            String phoneNumber = request.getParameter("phone_number");
            int roomId = Integer.parseInt(request.getParameter("room_id"));
            Date checkInDate = DATE_FORMAT.parse(request.getParameter("check_in_date"));
            Date checkOutDate = DATE_FORMAT.parse(request.getParameter("check_out_date"));
            int numAdults = Integer.parseInt(request.getParameter("num_adults"));
            int numChildren = Integer.parseInt(request.getParameter("num_children"));
            String paymentMethod = request.getParameter("payment_method");
            boolean paid = "true".equals(request.getParameter("paid"));

            // Kiểm tra ngày hợp lệ
            Date today = new Date();
            today.setHours(0);
            today.setMinutes(0);
            today.setSeconds(0);
            if (checkInDate.before(today)) {
                response.sendRedirect(request.getContextPath() + "/receptionist/bookings/add?error=invalid_checkin_date");
                return;
            }
            if (checkOutDate.before(checkInDate) || checkOutDate.equals(checkInDate)) {
                response.sendRedirect(request.getContextPath() + "/receptionist/bookings/add?error=invalid_checkout_date");
                return;
            }

            // Kiểm tra phòng có còn trống không
            Room room = roomService.getRoomById(roomId);
            if (!room.isAvailable()) {
                response.sendRedirect(request.getContextPath() + "/receptionist/bookings/add?error=room_unavailable");
                return;
            }

            // Tạo khách hàng mới (kiểm tra xem đã tồn tại qua cccd chưa)
            int userId;
            String queryCheckUser = "SELECT user_id FROM Users WHERE cccd = ?";
            try (Connection conn = DatabaseUtil.getConnection(); PreparedStatement stmt = conn.prepareStatement(queryCheckUser)) {
                stmt.setString(1, cccd);
                ResultSet rs = stmt.executeQuery();
                if (rs.next()) {
                    userId = rs.getInt("user_id");
                } else {
                    String queryUser = "INSERT INTO Users (username, password, email, role, cccd, full_name, phone_number) " +
                                      "VALUES (?, ?, ?, 'user', ?, ?, ?)";
                    try (PreparedStatement stmtUser = conn.prepareStatement(queryUser, Statement.RETURN_GENERATED_KEYS)) {
                        String username = email.split("@")[0];
                        stmtUser.setString(1, username);
                        stmtUser.setString(2, "default_password"); // Nên mã hóa mật khẩu trong thực tế
                        stmtUser.setString(3, email);
                        stmtUser.setString(4, cccd);
                        stmtUser.setString(5, fullName);
                        stmtUser.setString(6, phoneNumber);
                        stmtUser.executeUpdate();

                        ResultSet rsUser = stmtUser.getGeneratedKeys();
                        userId = rsUser.next() ? rsUser.getInt(1) : -1;
                        if (userId == -1) throw new SQLException("Failed to create user");
                    }
                }

                // Tạo đặt phòng
                BigDecimal totalPrice = room.getPricePerNight()
                        .multiply(BigDecimal.valueOf((checkOutDate.getTime() - checkInDate.getTime()) / (1000 * 60 * 60 * 24)));

                String queryBooking = "INSERT INTO Bookings (user_id, room_id, check_in_date, check_out_date, total_price, status, num_adults, num_children, booking_method, receptionist_id, created_at) " +
                                     "VALUES (?, ?, ?, ?, ?, 'Confirmed', ?, ?, 'Onsite', ?, GETDATE())";
                try (PreparedStatement stmtBooking = conn.prepareStatement(queryBooking, Statement.RETURN_GENERATED_KEYS)) {
                    stmtBooking.setInt(1, userId);
                    stmtBooking.setInt(2, roomId);
                    stmtBooking.setDate(3, new java.sql.Date(checkInDate.getTime()));
                    stmtBooking.setDate(4, new java.sql.Date(checkOutDate.getTime()));
                    stmtBooking.setBigDecimal(5, totalPrice);
                    stmtBooking.setInt(6, numAdults);
                    stmtBooking.setInt(7, numChildren);
                    stmtBooking.setInt(8, user.getUserId());
                    stmtBooking.executeUpdate();

                    ResultSet rsBooking = stmtBooking.getGeneratedKeys();
                    int bookingId = rsBooking.next() ? rsBooking.getInt(1) : -1;
                    if (bookingId == -1) throw new SQLException("Failed to create booking");

                    // Đặt phòng không còn trống
                    bookingService.updateRoomAvailability(roomId, false);

                    // Tạo giao dịch (Pending nếu không tích Paid, Success nếu tích Paid)
                    Transaction transaction = new Transaction();
                    transaction.setBookingId(bookingId);
                    transaction.setUserId(userId);
                    transaction.setAmount(totalPrice);
                    transaction.setStatus(paid ? "Success" : "Pending");
                    transaction.setPaymentMethod(paymentMethod);
                    transaction.setCreatedAt(new Timestamp(System.currentTimeMillis()));
                    transaction.setReceptionistId(user.getUserId());
                    transaction.setUserFullName(fullName);
                    transaction.setUserEmail(email);
                    transaction.setRoomNumber(room.getRoomNumber());
                    transaction.setRoomTypeName(room.getRoomType().getTypeName());

                    transactionService.createTransaction(transaction);
                    LOGGER.log(Level.INFO, "Transaction created for onsite booking: " + bookingId + " with status: " + (paid ? "Success" : "Pending"));
                }
            }
            response.sendRedirect(request.getContextPath() + "/receptionist/bookings?message=add_success");
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error adding booking", e);
            response.sendRedirect(request.getContextPath() + "/receptionist/bookings/add?error=add_failed");
        }
    }
}