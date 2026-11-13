import '../../../core/api_client.dart';

class AuthRepository {
  AuthRepository(this._api);

  final ApiClient _api;

  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
  }) {
    return _api.register(name: name, email: email, password: password);
  }

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) {
    return _api.login(email: email, password: password);
  }

  Future<Map<String, dynamic>> loginWithGoogle(String idToken) {
    return _api.loginWithGoogle(idToken);
  }

  Future<void> verifyEmail({
    String? userId,
    String? email,
    required String code,
  }) {
    return _api.verifyEmail(userId: userId, email: email, code: code);
  }

  Future<void> resendVerification(String email) {
    return _api.resendVerification(email);
  }

  Future<void> requestPasswordReset(String email) {
    return _api.requestPasswordReset(email);
  }

  Future<void> resetPassword({
    required String email,
    required String code,
    required String newPassword,
  }) {
    return _api.resetPassword(
      email: email,
      code: code,
      newPassword: newPassword,
    );
  }
}
