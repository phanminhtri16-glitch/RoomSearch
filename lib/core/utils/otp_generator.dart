import 'dart:math';

class OtpGenerator {
  /// Sinh ngẫu nhiên mã OTP 6 chữ số (000000 - 999999)
  static String generate6DigitOtp() {
    final random = Random();
    final otp = random.nextInt(900000) + 100000; // 100000 -> 999999
    return otp.toString();
  }
}
