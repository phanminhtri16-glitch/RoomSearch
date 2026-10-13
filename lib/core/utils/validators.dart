import '../constants/app_constants.dart';

class Validators {

  /// Kiểm tra độ tuổi người dùng có đủ từ 18 tuổi trở lên hay không
  static bool isAtLeast18YearsOld(DateTime birthDate) {
    final today = DateTime.now();
    int age = today.year - birthDate.year;
    if (today.month < birthDate.month ||
        (today.month == birthDate.month && today.day < birthDate.day)) {
      age--;
    }
    return age >= AppConstants.minUserAge;
  }

  /// Validation Email
  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Vui lòng nhập địa chỉ Email';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Địa chỉ Email không hợp lệ';
    }
    return null;
  }

  /// Validation Số điện thoại Việt Nam
  static String? validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Vui lòng nhập số điện thoại';
    }
    final phoneRegex = RegExp(r'^(0[3|5|7|8|9])+([0-9]{8})$');
    if (!phoneRegex.hasMatch(value.trim())) {
      return 'Số điện thoại không hợp lệ (10 chữ số, đầu số VN)';
    }
    return null;
  }

  /// Validation Mật khẩu
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Vui lòng nhập mật khẩu';
    }
    if (value.length < 6) {
      return 'Mật khẩu phải chứa ít nhất 6 ký tự';
    }
    return null;
  }

  /// Validation Ngày sinh người dùng (>= 18 tuổi)
  static String? validateBirthDate(DateTime? birthDate) {
    if (birthDate == null) {
      return 'Vui lòng chọn ngày sinh';
    }
    if (!isAtLeast18YearsOld(birthDate)) {
      return 'Bạn phải từ 18 tuổi trở lên để đăng ký tài khoản';
    }
    return null;
  }

  /// Validation Họ tên
  static String? validateFullName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Vui lòng nhập họ và tên';
    }
    if (value.trim().length < 2) {
      return 'Họ tên tối thiểu 2 ký tự';
    }
    return null;
  }
}
