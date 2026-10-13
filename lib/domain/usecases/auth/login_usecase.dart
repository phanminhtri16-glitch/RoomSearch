import '../../entities/user_entity.dart';
import '../../repositories/auth_repository.dart';

class LoginUseCase {
  final AuthRepository _repository;

  LoginUseCase(this._repository);

  Future<UserEntity?> execute({
    required String emailOrPhone,
    required String password,
  }) {
    return _repository.login(
      emailOrPhone: emailOrPhone,
      password: password,
    );
  }
}
