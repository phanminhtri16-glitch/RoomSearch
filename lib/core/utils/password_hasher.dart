import 'dart:convert';
import 'package:crypto/crypto.dart';

class PasswordHasher {
  /// Mã hóa SHA-256 cho mật khẩu trước khi lưu
  static String hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }
}
