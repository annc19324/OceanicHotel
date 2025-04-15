package com.mycompany.oceanichotel.controllers.user;

import com.mycompany.oceanichotel.models.Booking;
import com.mycompany.oceanichotel.models.BookingHistory;
import com.mycompany.oceanichotel.models.User;
import com.mycompany.oceanichotel.services.user.UserBookingService;
import com.mycompany.oceanichotel.services.user.UserRoomService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.json.JSONObject;
import vn.payos.PayOS;
import vn.payos.type.CheckoutResponseData;
import vn.payos.type.ItemData;
import vn.payos.type.PaymentData;

import java.io.IOException;
import java.sql.SQLException;
import java.util.Date;
import java.util.List;
import java.util.logging.Logger;
import java.util.logging.Level;

@WebServlet("/user/bookings")
public class UserBookingsController extends HttpServlet {
    private UserBookingService userBookingService;
    private UserRoomService userRoomService;
    private static final Logger LOGGER = Logger.getLogger(UserBookingsController.class.getName());
    
    // PayOS credentials (thay bằng giá trị thực từ PayOS dashboard)
    private static final String PAYOS_CLIENT_ID = "5bc05e78-94d5-4242-a8da-81648df52502"; // Thay bằng CLIENT_ID thực
    private static final String PAYOS_API_KEY = "048b3cfd-cccc-4764-9e3d-589286c49134"; // Thay bằng API_KEY thực
    private static final String PAYOS_CHECKSUM_KEY = "2e20e21d453b033625b85fe0785d4cad78bdeca72942547a8090f47ce23f9f55"; // Thay bằng CHECKSUM_KEY thực
    private final PayOS payOS;

    public UserBookingsController() {
        this.payOS = new PayOS(PAYOS_CLIENT_ID, PAYOS_API_KEY, PAYOS_CHECKSUM_KEY);
    }

    @Override
    public void init() throws ServletException {
        userBookingService = new UserBookingService();
        userRoomService = new UserRoomService();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        User user = (User) request.getSession().getAttribute("user");
        if (user == null) {
            LOGGER.info("User not logged in, redirecting to login.");
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }
        LOGGER.info("Current user ID: " + user.getUserId());

        try {
            String status = request.getParameter("status");
            String orderCode = request.getParameter("orderCode");
            if ("PAID".equals(status) && orderCode != null) {
                try {
                    // Lấy bookingId từ orderCode
                    String bookingIdStr = orderCode.replaceFirst("^[0-9]{13}", "");
                    int bookingId = Integer.parseInt(bookingIdStr);
                    userBookingService.confirmPayOSPayment(bookingId, user.getUserId());
                    request.setAttribute("success", "vi".equals(user.getLanguage()) ? 
                        "Thanh toán PayOS thành công! Giao dịch đã được xác nhận." : 
                        "PayOS payment successful! Transaction has been confirmed.");
                } catch (NumberFormatException | SQLException e) {
                    LOGGER.log(Level.WARNING, "Error confirming PayOS payment for orderCode=" + orderCode, e);
                    request.setAttribute("error", "vi".equals(user.getLanguage()) ? 
                        "Lỗi khi xác nhận thanh toán PayOS: " + e.getMessage() : 
                        "Error confirming PayOS payment: " + e.getMessage());
                }
            } else if ("CANCELLED".equals(status)) {
                request.setAttribute("error", "vi".equals(user.getLanguage()) ? 
                    "Thanh toán PayOS bị hủy!" : 
                    "PayOS payment cancelled!");
            }

            String statusFilter = request.getParameter("statusFilter");
            String checkInFrom = request.getParameter("checkInFrom");
            String checkInTo = request.getParameter("checkInTo");
            String sortOption = request.getParameter("sortOption");

            List<Booking> bookings = userBookingService.getUserBookings(
                user.getUserId(), statusFilter, checkInFrom, checkInTo, sortOption
            );
            LOGGER.log(Level.INFO, "Retrieved {0} bookings for userId={1}", new Object[]{bookings.size(), user.getUserId()});
            request.setAttribute("bookings", bookings);

            List<BookingHistory> history = userRoomService.getBookingHistory(user.getUserId());
            LOGGER.log(Level.INFO, "Retrieved {0} history records for userId={1}", new Object[]{history.size(), user.getUserId()});
            request.setAttribute("history", history);

            request.setAttribute("statusFilter", statusFilter);
            request.setAttribute("checkInFrom", checkInFrom);
            request.setAttribute("checkInTo", checkInTo);
            request.setAttribute("sortOption", sortOption);

            request.getRequestDispatcher("/WEB-INF/views/user/bookings.jsp").forward(request, response);
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error retrieving bookings or history for userId=" + user.getUserId(), e);
            request.setAttribute("error", "Unable to load bookings or history: " + e.getMessage());
            request.getRequestDispatcher("/WEB-INF/views/user/bookings.jsp").forward(request, response);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        User user = (User) request.getSession().getAttribute("user");
        response.setContentType("application/json");
        JSONObject jsonResponse = new JSONObject();

        if (user == null) {
            LOGGER.info("User not logged in.");
            jsonResponse.put("error", "User not logged in");
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            response.getWriter().write(jsonResponse.toString());
            return;
        }

        String action = request.getParameter("action");
        int bookingId;
        try {
            bookingId = Integer.parseInt(request.getParameter("bookingId"));
        } catch (NumberFormatException e) {
            LOGGER.log(Level.WARNING, "Invalid bookingId: " + request.getParameter("bookingId"), e);
            jsonResponse.put("error", "Invalid booking ID");
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            response.getWriter().write(jsonResponse.toString());
            return;
        }

        try {
            if ("cancel".equals(action)) {
                userRoomService.cancelBooking(bookingId, user.getUserId());
                LOGGER.info("Booking ID=" + bookingId + " cancelled by userId=" + user.getUserId());
                jsonResponse.put("success", true);
                response.getWriter().write(jsonResponse.toString());
            } else if ("confirmMoMo".equals(action)) {
                userBookingService.confirmMoMoPayment(bookingId, user.getUserId());
                LOGGER.info("MoMo payment confirmed for booking ID=" + bookingId + " by userId=" + user.getUserId());
                jsonResponse.put("success", true);
                response.getWriter().write(jsonResponse.toString());
            } else if ("payTest".equals(action)) {
                userBookingService.confirmTestPayment(bookingId, user.getUserId());
                LOGGER.info("Test payment confirmed for booking ID=" + bookingId + " by userId=" + user.getUserId());
                jsonResponse.put("success", true);
                response.getWriter().write(jsonResponse.toString());
            } else if ("createPayOSLink".equals(action)) {
                String totalPrice = request.getParameter("totalPrice");
                String paymentLink = createPayOSPaymentLink(bookingId, totalPrice, request);
                jsonResponse.put("paymentLink", paymentLink);
                response.getWriter().write(jsonResponse.toString());
            } else {
                LOGGER.log(Level.WARNING, "Unknown action: " + action);
                jsonResponse.put("error", "Invalid action: " + action);
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                response.getWriter().write(jsonResponse.toString());
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error processing action '" + action + "' for booking ID=" + bookingId, e);
            jsonResponse.put("error", "Database error: " + e.getMessage());
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            response.getWriter().write(jsonResponse.toString());
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error creating PayOS link for booking ID=" + bookingId, e);
            jsonResponse.put("error", "Failed to create PayOS link: " + e.getMessage());
            response.setStatus(HttpServletResponse.SC_BAD_GATEWAY);
            response.getWriter().write(jsonResponse.toString());
        }
    }

    private String createPayOSPaymentLink(int bookingId, String totalPrice, HttpServletRequest request) throws Exception {
        int amount;
        try {
            amount = Integer.parseInt(totalPrice);
            if (amount <= 0) {
                throw new NumberFormatException("Total price must be positive");
            }
        } catch (NumberFormatException e) {
            LOGGER.log(Level.WARNING, "Invalid totalPrice: " + totalPrice, e);
            throw new Exception("Invalid total price format: " + e.getMessage());
        }

        if (bookingId <= 0) {
            LOGGER.warning("Invalid bookingId: " + bookingId);
            throw new Exception("Invalid booking ID: " + bookingId);
        }

        String baseUrl = getBaseUrl(request);
        String returnUrl = baseUrl + "/user/bookings?status=PAID&orderCode=" + bookingId;
        String cancelUrl = baseUrl + "/user/bookings?status=CANCELLED";

        ItemData item = ItemData.builder()
                .name("Thanh toán đặt phòng ID " + bookingId)
                .quantity(1)
                .price(amount)
                .build();

        // Tạo orderCode duy nhất bằng timestamp + bookingId
        String timestamp = String.valueOf(new Date().getTime());
        long orderCode = Long.parseLong(timestamp + bookingId);

        PaymentData paymentData = PaymentData.builder()
                .orderCode(orderCode)
                .amount(amount)
                .description("Đặt phòng ID " + bookingId)
                .item(item)
                .returnUrl(returnUrl)
                .cancelUrl(cancelUrl)
                .build();

        LOGGER.info("Creating PayOS payment link with payload: orderCode=" + orderCode + ", bookingId=" + bookingId);

        try {
            CheckoutResponseData responseData = payOS.createPaymentLink(paymentData);
            String checkoutUrl = responseData.getCheckoutUrl();
            LOGGER.info("PayOS checkout URL: " + checkoutUrl);
            return checkoutUrl;
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error creating PayOS payment link: " + e.getMessage(), e);
            throw new Exception("Failed to create PayOS payment link: " + e.getMessage());
        }
    }

    private String getBaseUrl(HttpServletRequest request) {
        String scheme = request.getScheme();
        String serverName = request.getServerName();
        int serverPort = request.getServerPort();
        String contextPath = request.getContextPath();

        String url = scheme + "://" + serverName;
        if ((scheme.equals("http") && serverPort != 80) || (scheme.equals("https") && serverPort != 443)) {
            url += ":" + serverPort;
        }
        url += contextPath;
        return url;
    }
}