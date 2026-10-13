import '../entities/user_entity.dart';

abstract class AuthRepository {
  Future<UserEntity?> login({
    required String emailOrPhone,
    required String password,
  });

  Future<UserEntity> register({
    required String hoTen,
    required String email,
    required String soDienThoai,
    required String password,
    required String vaiTro,
    required DateTime ngaySinh,
    String? soCCCD,
    String? diaChiLienHe,
  });

  Future<String> sendOtp(String email);

  Future<bool> verifyOtp({
    required String email,
    required String otp,
  });

  Future<UserEntity?> getCurrentUser();

  Future<void> updateUser(UserEntity user);

  Future<void> logout();
}
