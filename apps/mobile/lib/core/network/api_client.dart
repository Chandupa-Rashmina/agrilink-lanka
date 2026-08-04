import 'dart:async';

import 'package:dio/dio.dart';

import '../config/api_config.dart';
import '../storage/token_storage.dart';

class ApiClient {
  ApiClient({required this._tokenStorage})
    : dio = Dio(
        BaseOptions(
          baseUrl: ApiConfig.baseUrl,
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
          headers: const {'Accept': 'application/json'},
        ),
      ) {
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _tokenStorage.readToken();

          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }

          handler.next(options);
        },
        onError: (error, handler) async {
          if (error.response?.statusCode == 401 &&
              !_isPublicAuthenticationRequest(error.requestOptions.path)) {
            await _expireSession();
          }

          handler.next(error);
        },
      ),
    );
  }

  final TokenStorage _tokenStorage;
  final Dio dio;

  FutureOr<void> Function()? onUnauthorized;
  bool _isExpiringSession = false;

  bool _isPublicAuthenticationRequest(String path) {
    return path.endsWith('/login');
  }

  Future<void> _expireSession() async {
    if (_isExpiringSession) {
      return;
    }

    _isExpiringSession = true;

    try {
      await _tokenStorage.deleteToken();
      await onUnauthorized?.call();
    } finally {
      _isExpiringSession = false;
    }
  }
}
