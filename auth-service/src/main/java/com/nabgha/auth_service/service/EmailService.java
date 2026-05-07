package com.nabgha.auth_service.service;

import jakarta.mail.MessagingException;
import jakarta.mail.internet.MimeMessage;
import lombok.RequiredArgsConstructor;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.mail.javamail.MimeMessageHelper;
import org.springframework.scheduling.annotation.Async;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class EmailService {

    private final JavaMailSender mailSender;

    @Async
    public void sendVerificationEmail(String to, String fullName, int code) {

        String subject = "Verify Your Account - AntiFoodWaste";

        String content = "<html>" +
                "<body style='font-family: Arial, sans-serif; background-color: #f4f4f4; padding: 20px;'>" +
                "  <div style='max-width: 600px; margin: auto; background: white; padding: 20px; border-radius: 10px; box-shadow: 0 2px 10px rgba(0,0,0,0.1);'>" +

                "    <h2 style='color: #2e7d32; text-align: center;'>Welcome to AntiFoodWaste!</h2>" +

                "    <p>Hello <strong>" + fullName + "</strong>,</p>" +

                "    <p>Thank you for joining us in reducing food waste. " +
                "To activate your account, please use the verification code below:</p>" +

                "    <div style='text-align: center; margin: 30px 0;'>" +
                "      <span style='font-size: 32px; font-weight: bold; letter-spacing: 5px; color: #2e7d32; background: #e8f5e9; padding: 10px 20px; border-radius: 5px; border: 2px dashed #2e7d32;'>" +
                code +
                "</span>" +
                "    </div>" +

                "    <p style='color: #666; font-size: 14px;'>" +
                "This code is valid for 15 minutes. " +
                "If you did not create an account, you can safely ignore this email." +
                "</p>" +

                "    <hr style='border: none; border-top: 1px solid #eee; margin: 20px 0;'>" +

                "    <p style='text-align: center; font-size: 12px; color: #999;'>" +
                "&copy; 2026 AntiFoodWaste - ENSET Mohammedia" +
                "</p>" +

                "  </div>" +
                "</body>" +
                "</html>";

        sendHtmlEmail(to, subject, content);
    }

    @Async
    public void sendResetPasswordEmail(String to, int code) {

        String subject = "Reset Your Password - AntiFoodWaste";

        String content = "<html>" +
                "<body style='font-family: Arial, sans-serif; background-color: #f4f4f4; padding: 20px;'>" +
                "  <div style='max-width: 600px; margin: auto; background: white; padding: 20px; border-radius: 10px; box-shadow: 0 2px 10px rgba(0,0,0,0.1);'>" +

                "    <h2 style='color: #d32f2f; text-align: center;'>Password Reset Request</h2>" +

                "    <p>We received a request to reset your AntiFoodWaste account password.</p>" +

                "    <p>Please use the security code below to continue:</p>" +

                "    <div style='text-align: center; margin: 30px 0;'>" +
                "      <span style='font-size: 32px; font-weight: bold; letter-spacing: 5px; color: #d32f2f; background: #ffebee; padding: 10px 20px; border-radius: 5px; border: 2px dashed #d32f2f;'>" +
                code +
                "</span>" +
                "    </div>" +

                "    <p style='color: #666; font-size: 14px;'>" +
                "If you did not request a password reset, please secure your account immediately." +
                "</p>" +

                "    <hr style='border: none; border-top: 1px solid #eee; margin: 20px 0;'>" +

                "    <p style='text-align: center; font-size: 12px; color: #999;'>" +
                "&copy; 2026 AntiFoodWaste - ENSET Mohammedia" +
                "</p>" +

                "  </div>" +
                "</body>" +
                "</html>";

        sendHtmlEmail(to, subject, content);
    }

    private void sendHtmlEmail(String to, String subject, String htmlBody) {
        try {

            MimeMessage message = mailSender.createMimeMessage();

            MimeMessageHelper helper =
                    new MimeMessageHelper(message, true, "UTF-8");

            helper.setTo(to);
            helper.setSubject(subject);
            helper.setText(htmlBody, true);

            mailSender.send(message);

        } catch (MessagingException e) {
            System.err.println("Error while sending email: " + e.getMessage());
        }
    }
}