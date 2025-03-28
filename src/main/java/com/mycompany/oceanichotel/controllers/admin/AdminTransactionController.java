package com.mycompany.oceanichotel.controllers.admin;

import com.mycompany.oceanichotel.models.Transaction;
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
                double totalRevenue = transactionService.getTotalRevenue();
                int successfulTransactions = transactionService.getTransactionCountByStatus("Success");
                int failedTransactions = transactionService.getTransactionCountByStatus("Failed");

                request.setAttribute("transactions", transactions);
                request.setAttribute("currentPage", page);
                request.setAttribute("totalPages", (int) Math.ceil((double) totalTransactions / 10));
                request.setAttribute("totalRevenue", totalRevenue);
                request.setAttribute("successfulTransactions", successfulTransactions);
                request.setAttribute("failedTransactions", failedTransactions);
                request.getRequestDispatcher("/WEB-INF/views/admin/transactions.jsp").forward(request, response);
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Database error in doGet", e);
            throw new ServletException("Database error", e);
        } catch (NumberFormatException e) {
            LOGGER.log(Level.WARNING, "Invalid page in doGet", e);
            response.sendRedirect(request.getContextPath() + "/admin/transactions?error=invalid_input");
        }
    }
}