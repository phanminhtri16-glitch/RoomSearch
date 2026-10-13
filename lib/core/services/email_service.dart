import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import '../constants/app_constants.dart';

class EmailService {
  /// Gửi mã OTP xác thực đăng ký tài khoản tới địa chỉ Gmail của người dùng
  static Future<bool> sendOtpEmail({
    required String recipientEmail,
    required String otpCode,
  }) async {
    final senderEmail = AppConstants.gmailSenderEmail;
    final appPassword = AppConstants.gmailAppPassword.replaceAll(' ', '');

    // 1. Kiểm tra cấu hình Mật khẩu ứng dụng Gmail
    if (appPassword.isEmpty || appPassword.contains('xxxx')) {
      debugPrint('==================================================');
      debugPrint('⚠️ [EmailService] Chưa cấu hình gmailAppPassword trong AppConstants.');
      debugPrint('👉 Mã OTP khởi tạo cho $recipientEmail là: [ $otpCode ]');
      debugPrint('==================================================');
      return false;
    }

    // 2. Xử lý cho Nền tảng Web (Chrome browser)
    // Nền tảng Web chặn kết nối TCP Socket trực tiếp (`dart:io Socket constructor unsupported`)
    if (kIsWeb) {
      return _sendOtpEmailWeb(recipientEmail: recipientEmail, otpCode: otpCode);
    }

    // 3. Xử lý cho Nền tảng Native (Android / iOS / Windows Desktop / macOS / Linux)
    try {
      final smtpServer = gmail(senderEmail, appPassword);

      final message = Message()
        ..from = Address(senderEmail, AppConstants.appName)
        ..recipients.add(recipientEmail)
        ..subject = '[$otpCode] Mã xác thực OTP đăng ký tài khoản - ${AppConstants.appName}'
        ..html = _buildOtpHtmlTemplate(otpCode);

      final sendReport = await send(message, smtpServer);
      debugPrint('✅ [EmailService Native] Đã gửi mã OTP [$otpCode] thành công tới Gmail: $recipientEmail. Details: $sendReport');
      return true;
    } catch (e) {
      debugPrint('❌ [EmailService Error] Gửi mail qua Gmail SMTP thất bại: $e');
      debugPrint('==================================================');
      debugPrint('👉 [Fallback Console OTP] Mã OTP tạo cho $recipientEmail là: [ $otpCode ]');
      debugPrint('==================================================');
      return false;
    }
  }

  /// Gửi email trên nền tảng Web thông qua HTTP REST API (EmailJS hoặc REST Endpoint)
  static Future<bool> _sendOtpEmailWeb({
    required String recipientEmail,
    required String otpCode,
  }) async {
    debugPrint('🌐 [EmailService Web] Đang chạy trên Trình duyệt Web (kIsWeb).');

    // Thử gửi qua EmailJS HTTPS REST API nếu đã được cấu hình
    if (AppConstants.emailjsServiceId.isNotEmpty &&
        AppConstants.emailjsTemplateId.isNotEmpty &&
        AppConstants.emailjsPublicKey.isNotEmpty) {
      try {
        final url = Uri.parse('https://api.emailjs.com/api/v1.0/email/send');
        final response = await http.post(
          url,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'service_id': AppConstants.emailjsServiceId,
            'template_id': AppConstants.emailjsTemplateId,
            'user_id': AppConstants.emailjsPublicKey,
            'template_params': {
              'to_email': recipientEmail,
              'otp_code': otpCode,
              'app_name': AppConstants.appName,
            }
          }),
        );

        if (response.statusCode == 200) {
          debugPrint('✅ [EmailService Web] Đã gửi OTP [$otpCode] tới Gmail: $recipientEmail qua EmailJS REST API.');
          return true;
        } else {
          debugPrint('⚠️ [EmailService Web] EmailJS REST API trả về mã lỗi: ${response.statusCode} - ${response.body}');
        }
      } catch (e) {
        debugPrint('❌ [EmailService Web Error] Lỗi kết nối HTTP REST API: $e');
      }
    }

    // In log mã OTP ra console cho Web khi chạy chế độ Web không có REST API key
    debugPrint('==================================================');
    debugPrint('👉 [Web Console OTP] Mã OTP tạo cho $recipientEmail là: [ $otpCode ]');
    debugPrint('==================================================');
    return false;
  }

  /// Mẫu định dạng Email HTML đẹp mắt gửi mã OTP
  static String _buildOtpHtmlTemplate(String otpCode) {
    return '''
<!DOCTYPE html>
<html lang="vi">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Mã xác thực OTP</title>
</head>
<body style="margin: 0; padding: 0; font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; background-color: #f4f6f9;">
  <table role="presentation" style="width: 100%; border-collapse: collapse;">
    <tr>
      <td align="center" style="padding: 40px 0;">
        <table role="presentation" style="width: 100%; max-width: 520px; border-collapse: collapse; background-color: #ffffff; border-radius: 12px; box-shadow: 0 4px 15px rgba(0, 0, 0, 0.08); overflow: hidden;">
          <!-- Header -->
          <tr>
            <td style="background-color: #1a73e8; padding: 25px 30px; text-align: center;">
              <h1 style="color: #ffffff; margin: 0; font-size: 24px; font-weight: 700; letter-spacing: 1px;">
                ${AppConstants.appName}
              </h1>
            </td>
          </tr>
          <!-- Content -->
          <tr>
            <td style="padding: 30px 30px 20px 30px;">
              <h2 style="color: #202124; margin-top: 0; font-size: 18px; font-weight: 600;">
                Xác thực đăng ký tài khoản
              </h2>
              <p style="color: #5f6368; font-size: 14px; line-height: 1.6; margin-bottom: 20px;">
                Xin chào,<br>
                Cảm ơn bạn đã đăng ký tài khoản tại <strong>${AppConstants.appName}</strong>. Dưới đây là mã xác thực OTP của bạn:
              </p>
              
              <!-- OTP Box -->
              <div style="background-color: #f0f4fe; border: 2px dashed #1a73e8; border-radius: 10px; padding: 18px; text-align: center; margin: 25px 0;">
                <span style="font-size: 34px; font-weight: 800; color: #1a73e8; letter-spacing: 8px; font-family: monospace;">
                  $otpCode
                </span>
              </div>

              <p style="color: #d93025; font-size: 13px; line-height: 1.5; margin-top: 15px; font-weight: 500;">
                ⏱ Mã OTP này có hiệu lực trong <strong>5 phút</strong>. Vui lòng không chia sẻ mã này với bất kỳ ai để bảo vệ tài khoản của bạn.
              </p>
            </td>
          </tr>
          <!-- Footer -->
          <tr>
            <td style="background-color: #f8f9fa; padding: 20px 30px; text-align: center; border-top: 1px solid #e8eaed;">
              <p style="color: #80868b; font-size: 12px; margin: 0; line-height: 1.5;">
                Đây là email tự động từ hệ thống ${AppConstants.appName}. Vui lòng không phản hồi email này.
              </p>
            </td>
          </tr>
        </table>
      </td>
    </tr>
  </table>
</body>
</html>
''';
  }
}
