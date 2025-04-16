package com.mycompany.oceanichotel.controllers.admin;
/*
 * Copyright (c) 2025 annc19324
 * All rights reserved.
 *
 * This code is the property of annc19324.
 * Unauthorized copying or distribution is prohibited.
 */
import com.mycompany.oceanichotel.models.Transaction;
import com.mycompany.oceanichotel.services.admin.AdminTransactionService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.math.BigDecimal;
import java.sql.SQLException;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

@WebServlet("/admin/transactions/*")
public class AdminTransactionController extends HttpServlet {

    private AdminTransactionService transactionService;
    private static final Logger LOGGER = Logger.getLogger(AdminTransactionController.class.getName());

    @Override
    public void init() throws ServletException {
        transactionService = new AdminTransactionService();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String pathInfo = request.getPathInfo();
        try {
            if (pathInfo == null || pathInfo.equals("/")) {
                int page = request.getParameter("page") != null ? Integer.parseInt(request.getParameter("page")) : 1;
                String search = request.getParameter("search");

                List<Transaction> transactions = transactionService.getTransactions(page, search);
                int totalTransactions = transactionService.getTotalTransactions(search);
                BigDecimal totalRevenue = transactionService.getTotalRevenue();
                int successfulTransactions = transactionService.getTransactionCountByStatus("Success");
                int failedTransactions = transactionService.getTransactionCountByStatus("Failed");

                request.setAttribute("transactions", transactions);
                request.setAttribute("currentPage", page);
                request.setAttribute("totalPages", (int) Math.ceil((double) totalTransactions / 10));
                request.setAttribute("totalRevenue", totalRevenue);
                request.setAttribute("successfulTransactions", successfulTransactions);
                request.setAttribute("failedTransactions", failedTransactions);
                request.getRequestDispatcher("/WEB-INF/views/admin/transactions.jsp").forward(request, response);
            } else if (pathInfo.equals("/update")) {
                handleUpdate(request, response);
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Database error in doGet", e);
            throw new ServletException("Database error", e);
        } catch (NumberFormatException e) {
            LOGGER.log(Level.WARNING, "Invalid page in doGet", e);
            response.sendRedirect(request.getContextPath() + "/admin/transactions?error=invalid_input");
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String pathInfo = request.getPathInfo();
        if (pathInfo != null && pathInfo.equals("/update")) {
            handleUpdate(request, response);
        } else {
            LOGGER.log(Level.WARNING, "Invalid pathInfo in doPost: " + pathInfo);
            response.sendRedirect(request.getContextPath() + "/admin/transactions?error=invalid_request");
        }
    }

    private void handleUpdate(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            String transactionIdParam = request.getParameter("transactionId");
            String status = request.getParameter("status");

            if (transactionIdParam == null || transactionIdParam.trim().isEmpty()) {
                LOGGER.log(Level.WARNING, "Transaction ID is null or empty in handleUpdate");
                response.sendRedirect(request.getContextPath() + "/admin/transactions?error=missing_transaction_id");
                return;
            }

            int transactionId = Integer.parseInt(transactionIdParam);
            if (status == null || (!status.equals("Success") && !status.equals("Refunded"))) {
                LOGGER.log(Level.WARNING, "Invalid status received: " + status);
                response.sendRedirect(request.getContextPath() + "/admin/transactions?error=invalid_status");
                return;
            }

            List<Transaction> transactions = transactionService.getTransactions(1, String.valueOf(transactionId));
            if (transactions.isEmpty()) {
                LOGGER.log(Level.WARNING, "Transaction not found for ID: " + transactionId);
                response.sendRedirect(request.getContextPath() + "/admin/transactions?error=transaction_not_found");
                return;
            }

            Transaction transaction = transactions.get(0);
            String currentStatus = transaction.getStatus();

            if (currentStatus.equals("Pending") && status.equals("Success")) {
                transactionService.updateTransactionStatus(transactionId, "Success");
                LOGGER.log(Level.INFO, "Transaction " + transactionId + " updated to Success");
            } else if (currentStatus.equals("Success") && status.equals("Refunded")) {
                long timeDiff = System.currentTimeMillis() - transaction.getCreatedAt().getTime();
                if (timeDiff <= 24 * 60 * 60 * 1000) { // Trong vòng 24 giờ
                    transactionService.updateTransactionStatus(transactionId, "Refunded");
                    LOGGER.log(Level.INFO, "Transaction " + transactionId + " updated to Refunded");
                } else {
                    LOGGER.log(Level.WARNING, "Cannot refund transaction " + transactionId + " after 24 hours");
                    response.sendRedirect(request.getContextPath() + "/admin/transactions?error=refund_time_restriction");
                    return;
                }
            } else {
                LOGGER.log(Level.WARNING, "Invalid status transition for transaction " + transactionId + ": " + currentStatus + " to " + status);
                response.sendRedirect(request.getContextPath() + "/admin/transactions?error=invalid_status_transition");
                return;
            }

            response.sendRedirect(request.getContextPath() + "/admin/transactions?message=update_success");
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Database error in handleUpdate for transactionId: " + request.getParameter("transactionId"), e);
            throw new ServletException("Database error", e);
        } catch (NumberFormatException e) {
            LOGGER.log(Level.WARNING, "Invalid transactionId in handleUpdate: " + request.getParameter("transactionId"), e);
            response.sendRedirect(request.getContextPath() + "/admin/transactions?error=invalid_transaction_id");
        }
    }
}