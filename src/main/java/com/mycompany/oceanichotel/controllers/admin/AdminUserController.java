package com.mycompany.oceanichotel.controllers.admin;

import com.mycompany.oceanichotel.models.User;
import com.mycompany.oceanichotel.services.admin.AdminUserService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.sql.SQLException;
import java.util.Calendar;
import java.util.Date;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

@WebServlet("/admin/users/*")
public class AdminUserController extends HttpServlet {

    private AdminUserService userService;
    private static final Logger LOGGER = Logger.getLogger(AdminUserController.class.getName());

    @Override
    public void init() throws ServletException {
        userService = new AdminUserService();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String pathInfo = request.getPathInfo();
        try {
            if (pathInfo == null || pathInfo.equals("/")) {
                int page = request.getParameter("page") != null ? Integer.parseInt(request.getParameter("page")) : 1;
                String search = request.getParameter("search");

                List<User> users = userService.getUsers(page, search);
                int totalUsers = userService.getTotalUsers(search);
                int totalPages = (int) Math.ceil((double) totalUsers / 10);

                request.setAttribute("users", users);
                request.setAttribute("currentPage", page);
                request.setAttribute("totalPages", totalPages);
                request.getRequestDispatcher("/WEB-INF/views/admin/users.jsp").forward(request, response);
            } else if (pathInfo.equals("/add")) {
                request.getRequestDispatcher("/WEB-INF/views/admin/add_user.jsp").forward(request, response);
            } else if (pathInfo.equals("/edit")) {
                int userId = Integer.parseInt(request.getParameter("userId"));
                User user = userService.getUserById(userId);
                if (user != null) {
                    request.setAttribute("user", user);
                    request.getRequestDispatcher("/WEB-INF/views/admin/edit_user.jsp").forward(request, response);
                } else {
                    response.sendRedirect(request.getContextPath() + "/admin/users?error=user_not_found");
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Database error in doGet", e);
            throw new ServletException("Database error", e);
        } catch (NumberFormatException e) {
            LOGGER.log(Level.WARNING, "Invalid userId in doGet: " + request.getParameter("userId"), e);
            response.sendRedirect(request.getContextPath() + "/admin/users?error=invalid_user_id");
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String pathInfo = request.getPathInfo();
        String language = (String) request.getSession().getAttribute("language");
        if (language == null) {
            language = "en";
            request.getSession().setAttribute("language", language);
        }
        try {
            if (pathInfo.equals("/add")) {
                User user = new User();
                user.setUsername(request.getParameter("username"));
                user.setEmail(request.getParameter("email"));
                user.setPassword(request.getParameter("password"));
                user.setFullName(request.getParameter("full_name"));
                user.setRole(request.getParameter("role"));
                user.setCccd(request.getParameter("cccd"));
                user.setPhoneNumber(request.getParameter("phone_number"));

                String dobDay = request.getParameter("dob_day");
                String dobMonth = request.getParameter("dob_month");
                String dobYear = request.getParameter("dob_year");

                if (dobDay == null || dobMonth == null || dobYear == null || 
                    dobDay.isEmpty() || dobMonth.isEmpty() || dobYear.isEmpty()) {
                    request.setAttribute("error", language.equals("vi") ? "Vui lòng chọn đầy đủ ngày sinh!" : "Please select full date of birth!");
                    request.getRequestDispatcher("/WEB-INF/views/admin/add_user.jsp").forward(request, response);
                    return;
                }

                int day, month, year;
                try {
                    day = Integer.parseInt(dobDay);
                    month = Integer.parseInt(dobMonth);
                    year = Integer.parseInt(dobYear);
                } catch (NumberFormatException e) {
                    LOGGER.log(Level.WARNING, "Invalid date components: day=" + dobDay + ", month=" + dobMonth + ", year=" + dobYear, e);
                    request.setAttribute("error", language.equals("vi") ? "Ngày sinh không hợp lệ!" : "Invalid date of birth!");
                    request.getRequestDispatcher("/WEB-INF/views/admin/add_user.jsp").forward(request, response);
                    return;
                }

                Calendar dobCal = Calendar.getInstance();
                dobCal.setLenient(false);
                try {
                    dobCal.set(year, month - 1, day);
                    Date dob = dobCal.getTime();
                    user.setDateOfBirth(dob);
                } catch (IllegalArgumentException e) {
                    LOGGER.log(Level.WARNING, "Invalid date: " + year + "-" + month + "-" + day, e);
                    request.setAttribute("error", language.equals("vi") ? "Ngày sinh không hợp lệ (ví dụ: 31/02)!" : "Invalid date of birth (e.g., 31/02)!");
                    request.getRequestDispatcher("/WEB-INF/views/admin/add_user.jsp").forward(request, response);
                    return;
                }

                Date now = new Date();
                Calendar nowCal = Calendar.getInstance();
                nowCal.setTime(now);
                int age = nowCal.get(Calendar.YEAR) - dobCal.get(Calendar.YEAR);
                if (nowCal.get(Calendar.DAY_OF_YEAR) < dobCal.get(Calendar.DAY_OF_YEAR)) {
                    age--;
                }

                if (dobCal.getTime().after(now) || dobCal.getTime().equals(now)) {
                    request.setAttribute("error", language.equals("vi") ? "Ngày sinh không thể là hôm nay hoặc tương lai!" : "Date of birth cannot be today or future!");
                    request.getRequestDispatcher("/WEB-INF/views/admin/add_user.jsp").forward(request, response);
                    return;
                }
                if (age < 16) {
                    request.setAttribute("error", language.equals("vi") ? "Người dùng phải trên 16 tuổi!" : "User must be over 16 years old!");
                    request.getRequestDispatcher("/WEB-INF/views/admin/add_user.jsp").forward(request, response);
                    return;
                }

                user.setGender(request.getParameter("gender"));

                String fullName = request.getParameter("full_name");
                if (fullName == null || fullName.trim().isEmpty()) {
                    request.setAttribute("error", language.equals("vi") ? "Vui lòng nhập họ và tên!" : "Please enter full name!");
                    request.getRequestDispatcher("/WEB-INF/views/admin/add_user.jsp").forward(request, response);
                    return;
                }

                try {
                    userService.addUser(user);
                    response.sendRedirect(request.getContextPath() + "/admin/users?message=add_success");
                } catch (SQLException e) {
                    if (e.getMessage().contains("Username already exists")) {
                        request.setAttribute("error", language.equals("vi") ? "Tên người dùng đã tồn tại!" : "Username already exists!");
                    } else if (e.getMessage().contains("Email already exists")) {
                        request.setAttribute("error", language.equals("vi") ? "Email đã tồn tại!" : "Email already exists!");
                    } else if (e.getMessage().contains("CCCD already exists")) {
                        request.setAttribute("error", language.equals("vi") ? "CCCD đã tồn tại!" : "CCCD already exists!");
                    } else {
                        throw e;
                    }
                    request.getRequestDispatcher("/WEB-INF/views/admin/add_user.jsp").forward(request, response);
                }
            } else if (pathInfo.equals("/update")) {
                int userId = Integer.parseInt(request.getParameter("userId"));
                User user = userService.getUserById(userId);
                if (user == null) {
                    response.sendRedirect(request.getContextPath() + "/admin/users?error=user_not_found");
                    return;
                }
                user.setUsername(request.getParameter("username"));
                user.setEmail(request.getParameter("email"));
                String password = request.getParameter("password");
                if (password != null && !password.trim().isEmpty()) {
                    user.setPassword(password);
                }
                user.setFullName(request.getParameter("full_name"));
                user.setRole(request.getParameter("role"));
                user.setCccd(request.getParameter("cccd"));
                user.setPhoneNumber(request.getParameter("phone_number"));

                String dobDay = request.getParameter("dob_day");
                String dobMonth = request.getParameter("dob_month");
                String dobYear = request.getParameter("dob_year");

                if (dobDay == null || dobMonth == null || dobYear == null || 
                    dobDay.isEmpty() || dobMonth.isEmpty() || dobYear.isEmpty()) {
                    request.setAttribute("error", language.equals("vi") ? "Vui lòng chọn đầy đủ ngày sinh!" : "Please select full date of birth!");
                    request.setAttribute("user", user);
                    request.getRequestDispatcher("/WEB-INF/views/admin/edit_user.jsp").forward(request, response);
                    return;
                }

                int day, month, year;
                try {
                    day = Integer.parseInt(dobDay);
                    month = Integer.parseInt(dobMonth);
                    year = Integer.parseInt(dobYear);
                } catch (NumberFormatException e) {
                    LOGGER.log(Level.WARNING, "Invalid date components: day=" + dobDay + ", month=" + dobMonth + ", year=" + dobYear, e);
                    request.setAttribute("user", user);
                    request.setAttribute("error", language.equals("vi") ? "Ngày sinh không hợp lệ!" : "Invalid date of birth!");
                    request.getRequestDispatcher("/WEB-INF/views/admin/edit_user.jsp").forward(request, response);
                    return;
                }

                Calendar dobCal = Calendar.getInstance();
                dobCal.setLenient(false);
                try {
                    dobCal.set(year, month - 1, day);
                    Date dob = dobCal.getTime();
                    user.setDateOfBirth(dob);
                } catch (IllegalArgumentException e) {
                    LOGGER.log(Level.WARNING, "Invalid date: " + year + "-" + month + "-" + day, e);
                    request.setAttribute("user", user);
                    request.setAttribute("error", language.equals("vi") ? "Ngày sinh không hợp lệ (ví dụ: 31/02)!" : "Invalid date of birth (e.g., 31/02)!");
                    request.getRequestDispatcher("/WEB-INF/views/admin/edit_user.jsp").forward(request, response);
                    return;
                }

                Date now = new Date();
                Calendar nowCal = Calendar.getInstance();
                nowCal.setTime(now);
                int age = nowCal.get(Calendar.YEAR) - dobCal.get(Calendar.YEAR);
                if (nowCal.get(Calendar.DAY_OF_YEAR) < dobCal.get(Calendar.DAY_OF_YEAR)) {
                    age--;
                }

                if (dobCal.getTime().after(now) || dobCal.getTime().equals(now)) {
                    request.setAttribute("user", user);
                    request.setAttribute("error", language.equals("vi") ? "Ngày sinh không thể là hôm nay hoặc tương lai!" : "Date of birth cannot be today or future!");
                    request.getRequestDispatcher("/WEB-INF/views/admin/edit_user.jsp").forward(request, response);
                    return;
                }
                if (age < 16) {
                    request.setAttribute("user", user);
                    request.setAttribute("error", language.equals("vi") ? "Người dùng phải trên 16 tuổi!" : "User must be over 16 years old!");
                    request.getRequestDispatcher("/WEB-INF/views/admin/edit_user.jsp").forward(request, response);
                    return;
                }

                user.setGender(request.getParameter("gender"));
                user.setActive("1".equals(request.getParameter("is_active")));

                try {
                    userService.updateUser(user);
                    response.sendRedirect(request.getContextPath() + "/admin/users?message=update_success");
                } catch (SQLException e) {
                    request.setAttribute("user", user);
                    if (e.getMessage().contains("Username already exists")) {
                        request.setAttribute("error", language.equals("vi") ? "Tên người dùng đã tồn tại!" : "Username already exists!");
                    } else if (e.getMessage().contains("Email already exists")) {
                        request.setAttribute("error", language.equals("vi") ? "Email đã tồn tại!" : "Email already exists!");
                    } else if (e.getMessage().contains("CCCD already exists")) {
                        request.setAttribute("error", language.equals("vi") ? "CCCD đã tồn tại!" : "CCCD already exists!");
                    } else {
                        throw e;
                    }
                    request.getRequestDispatcher("/WEB-INF/views/admin/edit_user.jsp").forward(request, response);
                }
            } else if (pathInfo.equals("/delete")) {
                int userId = Integer.parseInt(request.getParameter("userId"));
                userService.deleteUser(userId);
                response.sendRedirect(request.getContextPath() + "/admin/users?message=delete_success");
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Database error in doPost", e);
            throw new ServletException("Database error", e);
        } catch (NumberFormatException e) {
            LOGGER.log(Level.WARNING, "Invalid userId in doPost: " + request.getParameter("userId"), e);
            response.sendRedirect(request.getContextPath() + "/admin/users?error=invalid_input");
        }
    }
}