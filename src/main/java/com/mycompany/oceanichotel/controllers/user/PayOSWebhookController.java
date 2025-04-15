package com.mycompany.oceanichotel.controllers.user;

import com.mycompany.oceanichotel.services.user.UserBookingService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.json.JSONObject;

import java.io.BufferedReader;
import java.io.IOException;
import java.sql.SQLException;
import java.util.logging.Logger;
import java.util.logging.Level;

@WebServlet("/user/payos-webhook")
public class PayOSWebhookController extends HttpServlet {
    private UserBookingService userBookingService;
    private static final Logger LOGGER = Logger.getLogger(PayOSWebhookController.class.getName());

    @Override
    public void init() throws ServletException {
        userBookingService = new UserBookingService();
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        StringBuilder json = new StringBuilder();
        try (BufferedReader reader = request.getReader()) {
            String line;
            while ((line = reader.readLine()) != null) {
                json.append(line);
            }
        }

        LOGGER.info("Received webhook data: " + json);

        try {
            JSONObject jsonObject = new JSONObject(json.toString());
            JSONObject data = jsonObject.getJSONObject("data");
            int bookingId = data.getInt("orderCode");
            String status = data.getString("status");

            LOGGER.info("Processing webhook for booking ID=" + bookingId + " with status=" + status);

            int userId = userBookingService.getUserIdByBookingId(bookingId);
            if (userId == -1) {
                LOGGER.warning("Booking not found for ID=" + bookingId);
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                response.getWriter().write("{\"error\": -1, \"message\": \"Booking not found\"}");
                return;
            }

            if ("PAID".equals(status)) {
                userBookingService.confirmPayOSPayment(bookingId, userId);
                LOGGER.info("PayOS payment confirmed for booking ID=" + bookingId + ", user ID=" + userId);
            } else if ("CANCELLED".equals(status)) {
                userBookingService.cancelBooking(bookingId, userId);
                LOGGER.info("PayOS payment cancelled for booking ID=" + bookingId + ", user ID=" + userId);
            } else {
                LOGGER.warning("Unknown status received: " + status);
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                response.getWriter().write("{\"error\": -1, \"message\": \"Unknown status: " + status + "\"}");
                return;
            }

            response.setStatus(HttpServletResponse.SC_OK);
            response.getWriter().write("{\"error\": 0, \"message\": \"Webhook processed successfully\"}");
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error processing PayOS webhook: " + e.getMessage(), e);
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            response.getWriter().write("{\"error\": -1, \"message\": \"Database error: " + e.getMessage() + "\"}");
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Invalid webhook data: " + json, e);
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            response.getWriter().write("{\"error\": -1, \"message\": \"Invalid webhook data: " + e.getMessage() + "\"}");
        }
    }
}