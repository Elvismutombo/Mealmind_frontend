import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:mobile/features/auth/data/auth_repository.dart';
import 'package:mobile/features/auth/domain/auth_mode.dart';

import '../../../../core/api_client.dart';

class AuthController extends ChangeNotifier {
  AuthController(this._repository);

  final AuthRepository _repository;

  AuthMode mode = AuthMode.login;

  bool busy = false;
  bool obscurePassword = true;

  String? error;
  String? message;
  String? pendingUserId;

  void setMode(AuthMode newMode) {
    mode = newMode;
    error = null;
    message = null;
    notifyListeners();
  }

  void togglePasswordVisibility() {
    obscurePassword = !obscurePassword;
    notifyListeners();
  }

  void clearFeedback() {
    error = null;
    message = null;
    notifyListeners();
  }

  Future<Map<String, dynamic>?> submit({
    required String name,
    required String email,
    required String password,
    required String code,
  }) async {
    if (busy) return null;

    _start();

    try {
      switch (mode) {
        case AuthMode.login:
          return await _repository.login(
            email: email.trim(),
            password: password,
          );

        case AuthMode.register:
          final response = await _repository.register(
            name: name.trim(),
            email: email.trim(),
            password: password,
          );

          final data = response['data'] as Map<String, dynamic>? ?? {};
          final user = data['user'] as Map<String, dynamic>? ?? {};

          if (data['requiresEmailVerification'] == true &&
              user['id'] is String) {
            pendingUserId = user['id'] as String;
            mode = AuthMode.verifyEmail;
            message = 'Un code de vérification a été envoyé par e-mail.';
            return null;
          }

          throw const ApiException('Réponse d’inscription invalide', 502);

        case AuthMode.verifyEmail:
          await _repository.verifyEmail(
            userId: pendingUserId,
            email: pendingUserId == null ? email.trim() : null,
            code: code.trim(),
          );

          pendingUserId = null;
          mode = AuthMode.login;
          message = 'Adresse vérifiée. Tu peux te connecter.';
          return null;

        case AuthMode.forgotPassword:
          await _repository.requestPasswordReset(email.trim());

          mode = AuthMode.resetPassword;
          message = 'Si le compte existe, un code a été envoyé.';
          return null;

        case AuthMode.resetPassword:
          await _repository.resetPassword(
            email: email.trim(),
            code: code.trim(),
            newPassword: password,
          );

          mode = AuthMode.login;
          message = 'Mot de passe modifié. Tu peux te connecter.';
          return null;
      }
    } on ApiException catch (exception) {
      if (mode == AuthMode.login && exception.statusCode == 403) {
        pendingUserId = null;
        mode = AuthMode.verifyEmail;
        error = 'Adresse non vérifiée. Saisis le code reçu ou demande-en un nouveau.';
      } else {
        error = exception.message;
      }
      return null;
    } catch (exception) {
      error = 'Une erreur est survenue : $exception';
      return null;
    } finally {
      _finish();
    }
  }

  Future<Map<String, dynamic>?> continueWithGoogle() async {
    if (busy) return null;

    const serverClientId = String.fromEnvironment('GOOGLE_SERVER_CLIENT_ID');
    const iosClientId = String.fromEnvironment('GOOGLE_IOS_CLIENT_ID');
    const webClientId = String.fromEnvironment('GOOGLE_WEB_CLIENT_ID');

    if (serverClientId.isEmpty) {
      error = 'Configure GOOGLE_SERVER_CLIENT_ID avant d’utiliser Google.';
      notifyListeners();
      return null;
    }

    _start();

    try {
      final google = GoogleSignIn.instance;

      await google.initialize(
        clientId:
            defaultTargetPlatform == TargetPlatform.iOS &&
                iosClientId.isNotEmpty
            ? iosClientId
            : kIsWeb && webClientId.isNotEmpty
            ? webClientId
            : null,
        serverClientId: serverClientId,
      );

      final account = await google.authenticate();
      final idToken = account.authentication.idToken;

      if (idToken == null || idToken.isEmpty) {
        throw const ApiException('Google n’a pas fourni de jeton valide', 401);
      }

      return await _repository.loginWithGoogle(idToken);
    } on ApiException catch (exception) {
      error = exception.message;
      return null;
    } catch (exception) {
      error = 'Connexion Google impossible : $exception';
      return null;
    } finally {
      _finish();
    }
  }

  Future<void> resendVerification(String email) async {
    if (busy) return;

    _start();

    try {
      await _repository.resendVerification(email.trim());
      message = 'Si le compte le nécessite, un nouveau code a été envoyé.';
    } on ApiException catch (exception) {
      error = exception.message;
    } catch (exception) {
      error = 'Impossible de renvoyer le code : $exception';
    } finally {
      _finish();
    }
  }

  void _start() {
    busy = true;
    error = null;
    message = null;
    notifyListeners();
  }

  void _finish() {
    busy = false;
    notifyListeners();
  }
}
