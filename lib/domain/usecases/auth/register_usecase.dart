import '../../entities/user_entity.dart';
import '../../repositories/auth_repository.dart';

class RegisterUseCase {
  final AuthRepository _repository;

  RegisterUseCase(this._repository);

  Future<UserEntity> execute({
    required String hoTen,
    required String email,
    required String soDienThoai,
    required String password,
    required String vaiTro,
    required DateTime ngaySinh,
    String? soCCCD,
    String? diaChiLienHe,
  }) {
    return _repository.register(
      hoTen: hoTen,
      email: email,
      soDienThoai: soDienThoai,
      password: password,
      vaiTro: vaiTro,
      ngaySinh: ngaySinh,
      soCCCD: soCCCD,
      diaChiLienHe: diaChiLienHe,
    );
  }
}
