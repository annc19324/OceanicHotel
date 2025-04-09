package com.mycompany.oceanichotel.controllers.receptionist;

import com.mycompany.oceanichotel.models.Transaction;
import com.mycompany.oceanichotel.models.User;
import com.mycompany.oceanichotel.services.admin.AdminTransactionService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.sql.SQLException;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

@WebServlet("/receptionist/transactions/*")
public class ReceptionistTransactionController extends HttpServlet {

    private AdminTransactionService transactionService;
    private static final Logger LOGGER = Logger.getLogger(ReceptionistTransactionController.class.getName());

    @Override
    public void init() throws ServletException {
        transactionService = new AdminTransactionService();
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

                // Lấy tất cả giao dịch mà không lọc onsite
                List<Transaction> transactions = transactionService.getTransactions(page, search);
                int totalTransactions = transactionService.getTotalTransactions(search);
                int totalPages = (int) Math.ceil((double) totalTransactions / 10);

                request.setAttribute("transactions", transactions);
                request.setAttribute("currentPage", page);
                request.setAttribute("totalPages", totalPages);
                request.getRequestDispatcher("/WEB-INF/views/receptionist/transactions.jsp").forward(request, response);
            } else if (pathInfo.equals("/update")) {
                handleUpdate(request, response);
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Database error in doGet", e);
            throw new ServletException("Database error", e);
        } catch (NumberFormatException e) {
            LOGGER.log(Level.WARNING, "Invalid page in doGet", e);
            response.sendRedirect(request.getContextPath() + "/receptionist/transactions?error=invalid_input");
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
            response.sendRedirect(request.getContextPath() + "/receptionist/transactions?error=invalid_request");
        }
    }

    private void handleUpdate(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            String transactionIdParam = request.getParameter("transactionId");
            String status = request.getParameter("status");

            if (transactionIdParam == null || transactionIdParam.trim().isEmpty()) {
                LOGGER.log(Level.WARNING, "Transaction ID is null or empty in handleUpdate");
                response.sendRedirect(request.getContextPath() + "/receptionist/transactions?error=missing_transaction_id");
                return;
            }

            int transactionId = Integer.parseInt(transactionIdParam);
            if (status == null || !status.equals("Success")) {
                LOGGER.log(Level.WARNING, "Invalid status received: " + status);
                response.sendRedirect(request.getContextPath() + "/receptionist/transactions?error=invalid_status");
                return;
            }

            List<Transaction> transactions = transactionService.getTransactions(1, String.valueOf(transactionId));
            if (transactions.isEmpty()) {
                LOGGER.log(Level.WARNING, "Transaction not found for ID: " + transactionId);
                response.sendRedirect(request.getContextPath() + "/receptionist/transactions?error=transaction_not_found");
                return;
            }

            Transaction transaction = transactions.get(0);
            String currentStatus = transaction.getStatus();

            if (currentStatus.equals("Pending") && status.equals("Success")) {
                transactionService.updateTransactionStatus(transactionId, "Success");
                LOGGER.log(Level.INFO, "Transaction " + transactionId + " updated to Success");
            } else {
                LOGGER.log(Level.WARNING, "Invalid status transition for transaction " + transactionId + ": " + currentStatus + " to " + status);
                response.sendRedirect(request.getContextPath() + "/receptionist/transactions?error=invalid_status_transition");
                return;
            }

            response.sendRedirect(request.getContextPath() + "/receptionist/transactions?message=update_success");
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Database error in handleUpdate for transactionId: " + request.getParameter("transactionId"), e);
            throw new ServletException("Database error", e);
        } catch (NumberFormatException e) {
            LOGGER.log(Level.WARNING, "Invalid transactionId in handleUpdate: " + request.getParameter("transactionId"), e);
            response.sendRedirect(request.getContextPath() + "/receptionist/transactions?error=invalid_transaction_id");
        }
    }
}