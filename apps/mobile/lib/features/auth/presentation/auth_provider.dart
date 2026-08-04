import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../data/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  AuthProvider(this._authService);

  final AuthService _authService;

  bool _isAuthenticated = false;
  bool _isLoading = true;
  String? _errorMessage;

  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> initialize() async {
    _isAuthenticated = await _authService.hasToken();
    _isLoading = false;
    notifyListeners();
  }

  Future<bool> login({required String email, required String password}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _authService.login(email: email, password: password);

      _isAuthenticated = true;
      return true;
    } on DioException catch (error) {
      _errorMessage = _extractMessage(error);
      return false;
    } on FormatException catch (error) {
      _errorMessage = error.message;
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    await _authService.logout();

    _isAuthenticated = false;
    _isLoading = false;
    notifyListeners();
  }

  void expireSession() {
    if (!_isAuthenticated && !_isLoading) {
      return;
    }

    _isAuthenticated = false;
    _isLoading = false;
    _errorMessage = 'Your session expired. Please sign in again.';
    notifyListeners();
  }

  String _extractMessage(DioException error) {
    final responseData = error.response?.data;

    if (responseData is Map<String, dynamic>) {
      final message = responseData['message'];

      if (message is String && message.isNotEmpty) {
        return message;
      }

      final errors = responseData['errors'];

      if (errors is Map<String, dynamic>) {
        final emailErrors = errors['email'];

        if (emailErrors is List && emailErrors.isNotEmpty) {
          return emailErrors.first.toString();
        }
      }
    }

    return 'Unable to connect to the server.';
  }
}
