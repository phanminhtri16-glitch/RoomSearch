import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';
import '../models/user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDatasource _remoteDatasource;

  AuthRepositoryImpl({AuthRemoteDatasource? remoteDatasource})
      : _remoteDatasource = remoteDatasource ?? AuthRemoteDatasource();

  @override
  Future<UserEntity?> login({
    required String emailOrPhone,
    required String password,
  }) async {
    final userModel = await _remoteDatasource.login(
      emailOrPhone: emailOrPhone,
      password: password,
    );
    if (userModel != null) {
      await _saveUserSession(userModel.maTK, userModel.email);
    }
    return userModel;
  }

  @override
  Future<UserEntity> register({
    required String hoTen,
    required String email,
    required String soDienThoai,
    required String password,
    required String vaiTro,
    required DateTime ngaySinh,
    String? soCCCD,
    String? diaChiLienHe,
  }) async {
    final userModel = await _remoteDatasource.register(
      hoTen: hoTen,
      email: email,
      soDienThoai: soDienThoai,
      password: password,
      vaiTro: vaiTro,
      ngaySinh: ngaySinh,
      soCCCD: soCCCD,
      diaChiLienHe: diaChiLienHe,
    );
    return userModel;
  }

  @override
  Future<String> sendOtp(String email) async {
    return await _remoteDatasource.sendOtp(email);
  }

  @override
  Future<bool> verifyOtp({
    required String email,
    required String otp,
  }) async {
    return await _remoteDatasource.verifyOtp(email: email, otp: otp);
  }

  @override
  Future<UserEntity?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString('user_email');
    if (email == null || email.isEmpty) return null;

    try {
      final user = await _remoteDatasource.login(
        emailOrPhone: email,
        password: '', // We can load by query if needed
      );
      return user;
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> updateUser(UserEntity user) async {
    final userModel = UserModel(
      maTK: user.maTK,
      hoTen: user.hoTen,
      email: user.email,
      soDienThoai: user.soDienThoai,
      matKhau: user.matKhau,
      vaiTro: user.vaiTro,
      trangThai: user.trangThai,
      ngayDangKy: user.ngayDangKy,
      ngaySinh: user.ngaySinh,
      soCCCD: user.soCCCD,
      diaChiLienHe: user.diaChiLienHe,
      diemUyTinhTrungBinh: user.diemUyTinhTrungBinh,
      soLanNhapSaiOTP: user.soLanNhapSaiOTP,
      thoiGianMoKhoaOTP: user.thoiGianMoKhoaOTP,
      currentOtp: user.currentOtp,
      otpExpiryTime: user.otpExpiryTime,
    );
    await _remoteDatasource.updateUser(userModel);
  }

  @override
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_id');
    await prefs.remove('user_email');
  }

  Future<void> _saveUserSession(String userId, String email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_id', userId);
    await prefs.setString('user_email', email);
  }
}
