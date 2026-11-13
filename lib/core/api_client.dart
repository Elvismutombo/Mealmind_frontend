import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:image_picker/image_picker.dart';

class ApiException implements Exception {
  const ApiException(this.message, this.statusCode);

  final String message;
  final int statusCode;

  @override
  String toString() => message;
}

class ApiClient {
  ApiClient({Dio? dio})
    : _dio =
          dio ?? Dio(BaseOptions(connectTimeout: const Duration(seconds: 15))),
      _storage = const FlutterSecureStorage();

  static const baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.139.131.26:5000/api',
  );

  final Dio _dio;
  final FlutterSecureStorage _storage;
  String? _accessToken;
  String? _refreshToken;
  Future<bool>? _refreshing;

  Future<bool> get hasSession async {
    _accessToken = await _storage.read(key: 'accessToken');
    _refreshToken = await _storage.read(key: 'refreshToken');
    return _accessToken != null && _refreshToken != null;
  }

  Future<void> saveSession(Map<String, dynamic> data) async {
    _accessToken = data['accessToken'] as String?;
    _refreshToken = data['refreshToken'] as String?;

    if (_accessToken == null || _refreshToken == null) {
      throw const ApiException('Réponse de connexion invalide', 500);
    }
    await _storage.write(key: 'accessToken', value: _accessToken);
    await _storage.write(key: 'refreshToken', value: _refreshToken);
  }

  Future<void> clearSession() async {
    _accessToken = null;
    _refreshToken = null;
    await _storage.deleteAll();
  }

  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
  }) async => _post('/auth/register', {
    'name': name,
    'email': email,
    'password': password,
  });

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final result = await _post('/auth/login', {
      'email': email,
      'password': password,
    });
    await saveSession(_asMap(result['data']));
    return _asMap(result['data']);
  }

  Future<Map<String, dynamic>> loginWithGoogle(String idToken) async {
    final result = await _post('/auth/google', {'idToken': idToken});
    await saveSession(_asMap(result['data']));
    return _asMap(result['data']);
  }

  Future<void> verifyEmail({
    String? userId,
    String? email,
    required String code,
  }) async {
    final body = <String, String>{'code': code};
    if (userId != null) body['userId'] = userId;
    if (email != null) body['email'] = email;
    await _post('/auth/verify-email', body);
  }

  Future<void> resendVerification(String email) async {
    await _post('/auth/resend-verification', {'email': email});
  }

  Future<void> requestPasswordReset(String email) async {
    await _post('/auth/forgot-password', {'email': email});
  }

  Future<void> resetPassword({
    required String email,
    required String code,
    required String newPassword,
  }) async {
    await _post('/auth/reset-password', {
      'email': email,
      'code': code,
      'newPassword': newPassword,
    });
  }

  Future<void> logout() async {
    try {
      await _request(
        'POST',
        '/auth/logout',
        body: {'refreshToken': _refreshToken},
        authenticated: false,
      );
    } finally {
      await clearSession();
    }
  }

  Future<Map<String, dynamic>> profile() async =>
      _asMap((await _request('GET', '/users/profile'))['data']);

  Future<Map<String, dynamic>> updateProfile(String name) async => _asMap(
    (await _request('PATCH', '/users/profile', body: {'name': name}))['data'],
  );

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    await _request(
      'PATCH',
      '/users/change-password',
      body: {'currentPassword': currentPassword, 'newPassword': newPassword},
    );
  }

  Future<Map<String, dynamic>> uploadAvatar(XFile image) async {
    final bytes = await image.readAsBytes();
    final extension = image.name.split('.').last.toLowerCase();
    if (!{'jpg', 'jpeg', 'png', 'webp'}.contains(extension)) {
      throw const ApiException('Format accepté : JPEG, PNG ou WEBP', 400);
    }
    // DioMediaType : dio >= 5.8. Avec une version plus ancienne, utiliser
    // MediaType de package:http_parser à la place.
    final mimeType = switch (extension) {
      'png' => DioMediaType('image', 'png'),
      'webp' => DioMediaType('image', 'webp'),
      _ => DioMediaType('image', 'jpeg'),
    };

    for (var attempt = 0; attempt < 2; attempt++) {
      // Un FormData ne peut être envoyé qu'une fois : on le recrée à chaque essai.
      final form = FormData.fromMap({
        'avatar': MultipartFile.fromBytes(
          bytes,
          filename: image.name,
          contentType: mimeType,
        ),
      });

      final Response<String> response;
      try {
        response = await _dio.post<String>(
          '$baseUrl/users/avatar',
          data: form,
          options: _options(
            'POST',
            headers: {
              if (_accessToken != null) 'Authorization': 'Bearer $_accessToken',
            },
            timeout: const Duration(seconds: 45),
            sendTimeout: const Duration(seconds: 45),
          ),
        );
      } on DioException catch (error) {
        throw ApiException(
          'Serveur inaccessible : ${error.message ?? error}',
          0,
        );
      }

      final statusCode = response.statusCode ?? 0;
      if (statusCode == 401 && attempt == 0 && await _refreshSession()) {
        continue;
      }
      final decoded = _decode(response.data);
      if (statusCode < 200 || statusCode >= 300) {
        throw ApiException(
          decoded['message'] as String? ?? 'Échec de l’envoi de la photo',
          statusCode,
        );
      }
      return _asMap(decoded['data']);
    }

    throw const ApiException('Session expirée', 401);
  }

  Future<List<Map<String, dynamic>>> recipes({
    bool favorites = false,
    String search = '',
  }) async {
    final response = await _request(
      'GET',
      '/recipes/',
      query: {
        if (favorites) 'favorites': 'true',
        if (search.trim().isNotEmpty) 'search': search.trim(),
      },
    );
    return _asList(_asMap(response['data'])['recipes']);
  }

  Future<Map<String, dynamic>> generateRecipe({
    required List<String> ingredients,
    required String preferences,
    required int servings,
  }) async {
    final response = await _request(
      'POST',
      '/recipes/generate',
      body: {
        'ingredients': ingredients,
        'preferences': preferences,
        'servings': servings,
      },
      timeoutOverride: const Duration(seconds: 120),
    );
    return _asMap(_asMap(response['data'])['recipe']);
  }

  Future<void> setFavorite(String recipeId, bool isFavorite) async {
    await _request(
      'PATCH',
      '/recipes/$recipeId/favorite',
      body: {'isFavorite': isFavorite},
    );
  }

  Future<void> deleteRecipe(String recipeId) async {
    await _request('DELETE', '/recipes/$recipeId');
  }

  Future<Map<String, dynamic>> shoppingList() async => _asMap(
    _asMap((await _request('GET', '/shopping-lists'))['data'])['list'],
  );

  Future<Map<String, dynamic>> addShoppingItem(
    String name,
    String quantity,
  ) async {
    final response = await _request(
      'POST',
      '/shopping-lists/items',
      body: {'name': name, 'quantity': quantity},
    );
    return _asMap(_asMap(response['data'])['list']);
  }

  Future<Map<String, dynamic>> updateShoppingItem(
    String id,
    Map<String, dynamic> changes,
  ) async {
    final response = await _request(
      'PATCH',
      '/shopping-lists/items/$id',
      body: changes,
    );
    return _asMap(_asMap(response['data'])['list']);
  }

  Future<void> deleteShoppingItem(String id) async {
    await _request('DELETE', '/shopping-lists/items/$id');
  }

  Future<Map<String, dynamic>> quota() async =>
      _asMap(_asMap((await _request('GET', '/quotas/me'))['data'])['quota']);

  Future<Map<String, dynamic>> subscription() async => _asMap(
    _asMap(
      (await _request('GET', '/subscriptions/me'))['data'],
    )['subscription'],
  );

  Future<Map<String, dynamic>> _post(
    String path,
    Map<String, dynamic> body,
  ) async => _request('POST', path, body: body, authenticated: false);

  /// Options communes : on garde la main sur les codes HTTP (validateStatus
  /// toujours vrai) et on décode le JSON nous-mêmes (ResponseType.plain),
  /// pour conserver exactement le comportement de la version `http`.
  Options _options(
    String method, {
    Map<String, String>? headers,
    required Duration timeout,
    Duration? sendTimeout,
  }) => Options(
    method: method,
    headers: headers,
    responseType: ResponseType.plain,
    validateStatus: (_) => true,
    receiveTimeout: timeout,
    sendTimeout: sendTimeout,
  );

  Duration _timeoutFor(String method) => switch (method) {
    'GET' || 'PATCH' || 'DELETE' => const Duration(seconds: 25),
    'POST' => const Duration(seconds: 40),
    _ => throw const ApiException('Méthode HTTP non prise en charge', 500),
  };

  Future<Map<String, dynamic>> _request(
    String method,
    String path, {
    Map<String, dynamic>? body,
    Map<String, dynamic>? query,
    bool authenticated = true,
    bool retryAfterRefresh = true,
    Duration? timeoutOverride,
  }) async {
    final headers = <String, String>{};
    if (authenticated && _accessToken != null) {
      headers['Authorization'] = 'Bearer $_accessToken';
    }

    final Response<String> response;
    try {
      response = await _dio.request<String>(
        '$baseUrl$path',
        data: body,
        queryParameters: query,
        options: _options(
          method,
          headers: headers,
          timeout: timeoutOverride ?? _timeoutFor(method),
        ),
      );
    } on DioException catch (error) {
      throw ApiException('Serveur inaccessible : ${error.message ?? error}', 0);
    }

    final statusCode = response.statusCode ?? 0;
    if (statusCode == 401 &&
        authenticated &&
        retryAfterRefresh &&
        await _refreshSession()) {
      return _request(
        method,
        path,
        body: body,
        query: query,
        authenticated: true,
        retryAfterRefresh: false,
        timeoutOverride: timeoutOverride,
      );
    }

    final decoded = _decode(response.data);
    if (statusCode < 200 || statusCode >= 300) {
      final message = decoded['message'] as String? ?? 'Erreur du serveur';
      throw ApiException(message, statusCode);
    }
    return decoded;
  }

  Future<bool> _refreshSession() {
    final pendingRefresh = _refreshing;
    if (pendingRefresh != null) return pendingRefresh;

    final refresh = _performRefresh();
    _refreshing = refresh;
    return refresh.whenComplete(() {
      if (identical(_refreshing, refresh)) _refreshing = null;
    });
  }

  Future<bool> _performRefresh() async {
    if (_refreshToken == null) return false;

    final Response<String> response;
    try {
      response = await _dio.post<String>(
        '$baseUrl/auth/refresh',
        data: {'refreshToken': _refreshToken},
        options: _options('POST', timeout: const Duration(seconds: 20)),
      );
    } on DioException catch (error) {
      throw ApiException('Serveur inaccessible : ${error.message ?? error}', 0);
    }

    final statusCode = response.statusCode ?? 0;
    final decoded = _decode(response.data);
    if (statusCode < 200 || statusCode >= 300) {
      await clearSession();
      return false;
    }
    final data = _asMap(decoded['data']);
    _accessToken = data['accessToken'] as String?;
    _refreshToken = data['refreshToken'] as String?;
    if (_accessToken == null || _refreshToken == null) {
      throw const ApiException('Réponse de renouvellement invalide', 502);
    }
    await _storage.write(key: 'accessToken', value: _accessToken);
    await _storage.write(key: 'refreshToken', value: _refreshToken);
    return true;
  }

  Map<String, dynamic> _decode(String? body) {
    try {
      final value = jsonDecode(body ?? '');
      if (value is Map<String, dynamic>) return value;
      throw const FormatException('Réponse JSON inattendue');
    } on FormatException {
      throw const ApiException('Réponse invalide du serveur', 502);
    }
  }

  Map<String, dynamic> _asMap(Object? value) =>
      value is Map<String, dynamic> ? value : <String, dynamic>{};

  List<Map<String, dynamic>> _asList(Object? value) => value is List
      ? value.whereType<Map<String, dynamic>>().toList()
      : <Map<String, dynamic>>[];
}
