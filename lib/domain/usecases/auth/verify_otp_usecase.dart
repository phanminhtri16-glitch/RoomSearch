import '../../repositories/auth_repository.dart';

class VerifyOtpUseCase {
  final AuthRepository _repository;

  VerifyOtpUseCase(this._repository);

  Future<bool> execute({
    required String email,
    required String otp,
  }) {
    return _repository.verifyOtp(email: email, otp: otp);
  }
}
