import '../../repositories/auth_repository.dart';

class SendOtpUseCase {
  final AuthRepository _repository;

  SendOtpUseCase(this._repository);

  Future<String> execute(String email) {
    return _repository.sendOtp(email);
  }
}
