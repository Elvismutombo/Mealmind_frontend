import '../../core/api_client.dart';

abstract interface class AppSessionRepository {
  Future<Map<String, dynamic>?> restoreSession();
}

class ApiAppSessionRepository implements AppSessionRepository {
  ApiAppSessionRepository(this._api);

  final ApiClient _api;

  @override
  Future<Map<String, dynamic>?> restoreSession() async {
    if (!await _api.hasSession) return null;

    try {
      return await _api.profile();
    } on ApiException catch (error) {
      if (error.statusCode == 401) {
        await _api.clearSession();
        return null;
      }

      rethrow;
    }
  }
}
