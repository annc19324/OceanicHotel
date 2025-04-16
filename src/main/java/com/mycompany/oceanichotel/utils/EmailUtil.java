package com.mycompany.oceanichotel.utils;
/*
 * Copyright (c) 2025 annc19324
 * All rights reserved.
 *
 * This code is the property of annc19324.
 * Unauthorized copying or distribution is prohibited.
 */
import jakarta.mail.*;
import jakarta.mail.internet.InternetAddress;
import jakarta.mail.internet.MimeMessage;
import java.util.Properties;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class EmailUtil {
    private static final String FROM_EMAIL = "oceanichotel0@gmail.com"; // Email của bạn
    private static final String PASSWORD = "isdi qbwx jase jpvq"; // App Password 16 ký tự
    private static final Logger logger = LoggerFactory.getLogger(EmailUtil.class);

    public static void sendEmail(String toEmail, String subject, String resetToken, String language) throws MessagingException {
        Properties props = new Properties();
        props.put("mail.smtp.auth", "true");
        props.put("mail.smtp.starttls.enable", "true");
        props.put("mail.smtp.host", "smtp.gmail.com");
        props.put("mail.smtp.port", "587");

        logger.debug("Creating email session with host=smtp.gmail.com, port=587, auth=true, starttls=true");
        Session session = Session.getInstance(props, new Authenticator() {
            @Override
            protected PasswordAuthentication getPasswordAuthentication() {
                logger.debug("Authenticating with email={} and password", FROM_EMAIL);
                return new PasswordAuthentication(FROM_EMAIL, PASSWORD);
            }
        });

        try {
            Message message = new MimeMessage(session);
            message.setFrom(new InternetAddress(FROM_EMAIL));
            message.setRecipients(Message.RecipientType.TO, InternetAddress.parse(toEmail));
            message.setSubject(subject);

            // Nội dung HTML chuyên nghiệp
            String htmlBody = "<html>" +
                    "<body style='font-family: Arial, sans-serif; padding: 20px;'>" +
                    "<h2 style='color: #007bff;'>" + (language.equals("vi") ? "Khách sạn Oceanic" : "Oceanic Hotel") + "</h2>" +
                    "<p>" + (language.equals("vi") ? "Chào bạn," : "Hello,") + "</p>" +
                    "<p>" + (language.equals("vi") ? "Chúng tôi nhận được yêu cầu đặt lại mật khẩu cho tài khoản của bạn. Đây là mã xác nhận của bạn:" : 
                            "We received a request to reset the password for your account. Here is your verification code:") + "</p>" +
                    "<h3 style='color: #333; background: #f0f0f0; padding: 10px; display: inline-block;'>" + resetToken + "</h3>" +
                    "<p>" + (language.equals("vi") ? "Mã này có hiệu lực trong 2 phút. Vui lòng nhập mã vào trang quên mật khẩu để tiếp tục." : 
                            "This code is valid for 2 minutes. Please enter it on the forgot password page to proceed.") + "</p>" +
                    "<p style='color: #666; font-size: 12px;'>" + (language.equals("vi") ? "Nếu bạn không yêu cầu đặt lại mật khẩu, vui lòng bỏ qua email này." : 
                            "If you did not request a password reset, please ignore this email.") + "</p>" +
                    "<p>" + (language.equals("vi") ? "Để đảm bảo email vào hộp thư chính, hãy thêm " : "To ensure emails go to your inbox, please add ") +
                    "<strong>" + FROM_EMAIL + "</strong>" + (language.equals("vi") ? " vào danh bạ của bạn." : " to your contacts.") + "</p>" +
                    "<p>" + (language.equals("vi") ? "Trân trọng," : "Best regards,") + "<br>" + 
                    (language.equals("vi") ? "Đội ngũ Oceanic Hotel" : "Oceanic Hotel Team") + "</p>" +
                    "</body></html>";

            message.setContent(htmlBody, "text/html; charset=UTF-8");

            logger.debug("Sending email to {} with subject: {}", toEmail, subject);
            Transport.send(message);
            logger.info("Email sent successfully to {}", toEmail);
        } catch (MessagingException e) {
            logger.error("Failed to send email to {}: {}", toEmail, e.getMessage(), e);
            throw e;
        }
    }
}