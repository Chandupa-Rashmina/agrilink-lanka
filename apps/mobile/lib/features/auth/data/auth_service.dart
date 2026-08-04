import 'package:dio/dio.dart';

import '../../../core/network/api_client.dart';
import '../../../core/storage/token_storage.dart';
import 'models/app_user.dart';

class AuthService {
  const AuthService({required this._apiClient, required this._tokenStorage});

  final ApiClient _apiClient;
  final TokenStorage _tokenStorage;

  Future<AppUser> login({
    required String email,
    required String password,
  }) async {
    final response = await _apiClient.dio.post<Map<String, dynamic>>(
      '/login',
      data: {
        'email': email,
        'password': password,
        'device_name': 'agrilink-android',
      },
    );

    return _saveSession(response.data);
  }

  Future<AppUser> register({
    required String name,
    required String email,
    required String phone,
    required String district,
    required String password,
  }) async {
    final response = await _apiClient.dio.post<Map<String, dynamic>>(
      '/register',
      data: {
        'name': name,
        'email': email,
        'phone': phone,
        'district': district,
        'password': password,
        'password_confirmation': password,
        'device_name': 'agrilink-android',
      },
    );

    return _saveSession(response.data);
  }

  Future<AppUser> fetchProfile() async {
    final response = await _apiClient.dio.get<Map<String, dynamic>>('/me');
    final data = response.data?['data'];

    if (data is! Map) {
      throw const FormatException('Invalid profile response.');
    }

    return AppUser.fromJson(Map<String, dynamic>.from(data));
  }

  Future<AppUser> updateProfile({
    required String name,
    required String email,
    required String phone,
    required String district,
  }) async {
    final response = await _apiClient.dio.put<Map<String, dynamic>>(
      '/profile',
      data: {
        'name': name,
        'email': email,
        'phone': phone,
        'district': district,
      },
    );

    final data = response.data?['data'];

    if (data is! Map) {
      throw const FormatException('Invalid profile response.');
    }

    return AppUser.fromJson(Map<String, dynamic>.from(data));
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

  Future<AppUser> _saveSession(Map<String, dynamic>? responseData) async {
    final data = responseData?['data'];

    if (data is! Map) {
      throw const FormatException('Invalid authentication response.');
    }

    final normalized = Map<String, dynamic>.from(data);
    final token = normalized['token'];
    final user = normalized['user'];

    if (token is! String || token.isEmpty || user is! Map) {
      throw const FormatException('Authentication data was not returned.');
    }

    await _tokenStorage.saveToken(token);

    return AppUser.fromJson(Map<String, dynamic>.from(user));
  }
}
