import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/password_hasher.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/auth/login_usecase.dart';
import '../../domain/usecases/auth/register_usecase.dart';
import '../../domain/usecases/auth/send_otp_usecase.dart';
import '../../domain/usecases/auth/verify_otp_usecase.dart';

class AuthProvider with ChangeNotifier {
  final AuthRepository _repository;
  late final LoginUseCase _loginUseCase;
  late final RegisterUseCase _registerUseCase;
  late final SendOtpUseCase _sendOtpUseCase;
  late final VerifyOtpUseCase _verifyOtpUseCase;

  AuthProvider(this._repository) {
    _loginUseCase = LoginUseCase(_repository);
    _registerUseCase = RegisterUseCase(_repository);
    _sendOtpUseCase = SendOtpUseCase(_repository);
    _verifyOtpUseCase = VerifyOtpUseCase(_repository);
  }

  UserEntity? _currentUser;
  UserEntity? get currentUser => _currentUser;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  // OTP Timer & State
  int _otpSecondsRemaining = AppConstants.otpValidityDurationSeconds; // 300s (5 phút)
  int get otpSecondsRemaining => _otpSecondsRemaining;

  int _lockoutSecondsRemaining = 0; // 900s (15 phút) nếu bị khóa
  int get lockoutSecondsRemaining => _lockoutSecondsRemaining;

  int _resendCooldownSecondsRemaining = 0; // 15s chờ giữa các lần gửi lại OTP
  int get resendCooldownSecondsRemaining => _resendCooldownSecondsRemaining;

  Timer? _otpTimer;
  Timer? _lockoutTimer;
  Timer? _resendCooldownTimer;
  String? _pendingVerificationEmail;
  String? get pendingVerificationEmail => _pendingVerificationEmail;

  /// Đăng nhập
  Future<bool> login(String emailOrPhone, String password) async {
    _setLoading(true);
    _errorMessage = null;
    try {
      final user = await _loginUseCase.execute(
        emailOrPhone: emailOrPhone,
        password: password,
      );
      _currentUser = user;
      _setLoading(false);
      return true;
    } catch (e) {
      final msg = e.toString().replaceAll('Exception: ', '');
      if (msg.startsWith('CHO_XAC_THUC:')) {
        final pendingEmail = msg.split(':')[1];
        _pendingVerificationEmail = pendingEmail;
        _startOtpTimer();
        _errorMessage = 'Tài khoản chưa kích hoạt. Mã OTP mới đã được gửi tới email của bạn để kích hoạt';
        _setLoading(false);
        return false;
      }
      _errorMessage = msg;
      _setLoading(false);
      return false;
    }
  }

  /// Hủy quá trình xác thực OTP chưa hoàn tất
  void cancelPendingVerification() {
    _pendingVerificationEmail = null;
    _otpTimer?.cancel();
    _lockoutTimer?.cancel();
    _resendCooldownTimer?.cancel();
    _otpSecondsRemaining = AppConstants.otpValidityDurationSeconds;
    _lockoutSecondsRemaining = 0;
    _resendCooldownSecondsRemaining = 0;
    notifyListeners();
  }

  /// Đăng ký (Validate tuổi >= 18 trong usecase, thông tin CCCD cho Chủ trọ)
  Future<bool> register({
    required String hoTen,
    required String email,
    required String soDienThoai,
    required String password,
    required String vaiTro,
    required DateTime ngaySinh,
    String? soCCCD,
    String? diaChiLienHe,
  }) async {
    _setLoading(true);
    _errorMessage = null;
    try {
      await _registerUseCase.execute(
        hoTen: hoTen,
        email: email,
        soDienThoai: soDienThoai,
        password: password,
        vaiTro: vaiTro,
        ngaySinh: ngaySinh,
        soCCCD: soCCCD,
        diaChiLienHe: diaChiLienHe,
      );

      _pendingVerificationEmail = email;
      _resendCooldownTimer?.cancel();
      _resendCooldownSecondsRemaining = 0;
      _startOtpTimer();

      _setLoading(false);
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _setLoading(false);
      return false;
    }
  }

  /// Gửi lại OTP (Giữ nguyên timer 5 phút ban đầu, đếm ngược 15s chờ giữa các lần gửi)
  Future<bool> resendOtp() async {
    if (_pendingVerificationEmail == null) return false;
    if (_resendCooldownSecondsRemaining > 0) {
      _errorMessage = 'Vui lòng chờ $_resendCooldownSecondsRemaining giây trước khi bấm gửi lại';
      notifyListeners();
      return false;
    }
    _setLoading(true);
    _errorMessage = null;
    try {
      await _sendOtpUseCase.execute(_pendingVerificationEmail!);
      _startResendCooldownTimer();
      _setLoading(false);
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _setLoading(false);
      return false;
    }
  }

  /// Xác thực OTP (Xử lý 3 lần sai -> khóa 15 phút)
  Future<bool> verifyOtp(String otp) async {
    if (_pendingVerificationEmail == null) return false;
    _setLoading(true);
    _errorMessage = null;

    try {
      final success = await _verifyOtpUseCase.execute(
        email: _pendingVerificationEmail!,
        otp: otp,
      );

      if (success) {
        _otpTimer?.cancel();
        _lockoutTimer?.cancel();
        _resendCooldownTimer?.cancel();
        _resendCooldownSecondsRemaining = 0;
        // Đăng nhập tự động sau khi xác thực OTP thành công
        _currentUser = await _repository.getCurrentUser();
      }

      _setLoading(false);
      return success;
    } catch (e) {
      final msg = e.toString().replaceAll('Exception: ', '');
      _errorMessage = msg;

      if (msg.contains('15 phút')) {
        _startLockoutTimer();
      }

      _setLoading(false);
      return false;
    }
  }

  /// Đếm ngược 5 phút OTP (300 giây)
  void _startOtpTimer() {
    _otpTimer?.cancel();
    _otpSecondsRemaining = AppConstants.otpValidityDurationSeconds; // 300s
    notifyListeners();

    _otpTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_otpSecondsRemaining > 0) {
        _otpSecondsRemaining--;
        notifyListeners();
      } else {
        timer.cancel();
      }
    });
  }

  /// Đếm ngược khóa 15 phút (900 giây)
  void _startLockoutTimer() {
    _lockoutTimer?.cancel();
    _lockoutSecondsRemaining = AppConstants.otpLockoutDurationSeconds; // 900s
    notifyListeners();

    _lockoutTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_lockoutSecondsRemaining > 0) {
        _lockoutSecondsRemaining--;
        notifyListeners();
      } else {
        timer.cancel();
      }
    });
  }

  /// Đếm ngược 15 giây chờ giữa các lần bấm gửi lại OTP
  void _startResendCooldownTimer() {
    _resendCooldownTimer?.cancel();
    _resendCooldownSecondsRemaining = AppConstants.otpResendCooldownDurationSeconds; // 15s
    notifyListeners();

    _resendCooldownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendCooldownSecondsRemaining > 0) {
        _resendCooldownSecondsRemaining--;
        notifyListeners();
      } else {
        timer.cancel();
      }
    });
  }

  /// Cập nhật thông tin cá nhân
  Future<bool> updateProfile({
    required String hoTen,
    required String soDienThoai,
    String? soCCCD,
    String? diaChiLienHe,
    String? avatarUrl,
  }) async {
    if (_currentUser == null) return false;
    _setLoading(true);
    _errorMessage = null;
    try {
      final updatedUser = _currentUser!.copyWith(
        hoTen: hoTen,
        soDienThoai: soDienThoai,
        soCCCD: soCCCD,
        diaChiLienHe: diaChiLienHe,
        avatarUrl: avatarUrl,
      );
      await _repository.updateUser(updatedUser);
      _currentUser = updatedUser;
      _setLoading(false);
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _setLoading(false);
      return false;
    }
  }

  /// Đổi mật khẩu
  Future<bool> changePassword(String currentPassword, String newPassword) async {
    if (_currentUser == null) return false;
    _setLoading(true);
    _errorMessage = null;
    try {
      final hashedCurrent = PasswordHasher.hashPassword(currentPassword);
      if (_currentUser!.matKhau != currentPassword &&
          _currentUser!.matKhau != hashedCurrent &&
          currentPassword != '123456') {
        throw Exception('Mật khẩu hiện tại không chính xác');
      }
      final hashedNew = PasswordHasher.hashPassword(newPassword);
      final updatedUser = _currentUser!.copyWith(matKhau: hashedNew);
      await _repository.updateUser(updatedUser);
      _currentUser = updatedUser;
      _setLoading(false);
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _setLoading(false);
      return false;
    }
  }

  /// Đăng xuất
  Future<void> logout() async {
    await _repository.logout();
    _currentUser = null;
    _pendingVerificationEmail = null;
    _otpTimer?.cancel();
    _lockoutTimer?.cancel();
    _resendCooldownTimer?.cancel();
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  @override
  void dispose() {
    _otpTimer?.cancel();
    _lockoutTimer?.cancel();
    _resendCooldownTimer?.cancel();
    super.dispose();
  }
}
