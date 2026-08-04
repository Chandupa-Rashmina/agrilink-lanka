import 'package:dio/dio.dart';

import '../../../core/network/api_client.dart';
import '../../../core/storage/token_storage.dart';

class AuthService {
  const AuthService({
    required ApiClient apiClient,
    required TokenStorage tokenStorage,
  }) : _apiClient = apiClient,
       _tokenStorage = tokenStorage;

  final ApiClient _apiClient;
  final TokenStorage _tokenStorage;

  Future<void> login({required String email, required String password}) async {
    final response = await _apiClient.dio.post<Map<String, dynamic>>(
      '/login',
      data: {
        'email': email,
        'password': password,
        'device_name': 'agrilink-android',
      },
    );

    final data = response.data?['data'];

    if (data is! Map<String, dynamic>) {
      throw const FormatException('Invalid login response.');
    }

    final token = data['token'];

    if (token is! String || token.isEmpty) {
      throw const FormatException('Authentication token was not returned.');
    }

    await _tokenStorage.saveToken(token);
  }

  Future<void> logout() async {
    try {
      await _apiClient.dio.post<void>('/logout');
    } on DioException {
      // Remove the local token even if the server cannot be reached.
    } finally {
      await _tokenStorage.deleteToken();
    }
  }

  Future<bool> hasToken() async {
    final token = await _tokenStorage.readToken();

    return token != null && token.isNotEmpty;
  }
}
