import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../data/auth_service.dart';
import '../data/models/app_user.dart';

class AuthProvider extends ChangeNotifier {
  AuthProvider(this._authService);

  final AuthService _authService;

  bool _isLoading = false;
  bool _isAuthenticated = false;
  String? _errorMessage;
  AppUser? _user;

  bool get isLoading => _isLoading;
  bool get isAuthenticated => _isAuthenticated;
  String? get errorMessage => _errorMessage;
  AppUser? get user => _user;

  Future<void> initialize() async {
    _setLoading(true);

    try {
      _isAuthenticated = await _authService.hasToken();

      if (_isAuthenticated) {
        _user = await _authService.fetchProfile();
      }
    } catch (_) {
      _isAuthenticated = false;
      _user = null;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> login({required String email, required String password}) async {
    await _runAuthAction(
      () => _authService.login(email: email, password: password),
    );
  }

  Future<void> register({
    required String name,
    required String email,
    required String phone,
    required String district,
    required String password,
  }) async {
    await _runAuthAction(
      () => _authService.register(
        name: name,
        email: email,
        phone: phone,
        district: district,
        password: password,
      ),
    );
  }

  Future<bool> updateProfile({
    required String name,
    required String email,
    required String phone,
    required String district,
  }) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      _user = await _authService.updateProfile(
        name: name,
        email: email,
        phone: phone,
        district: district,
      );
      return true;
    } on DioException catch (error) {
      _errorMessage = _message(error);
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> logout() async {
    _setLoading(true);

    try {
      await _authService.logout();
    } finally {
      _isAuthenticated = false;
      _user = null;
      _errorMessage = null;
      _setLoading(false);
    }
  }

  void expireSession() {
    _isAuthenticated = false;
    _user = null;
    _errorMessage = 'Your session expired. Please sign in again.';
    notifyListeners();
  }

  Future<void> _runAuthAction(Future<AppUser> Function() action) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      _user = await action();
      _isAuthenticated = true;
    } on DioException catch (error) {
      _errorMessage = _message(error);
      _isAuthenticated = false;
    } finally {
      _setLoading(false);
    }
  }

  String _message(DioException error) {
    final data = error.response?.data;

    if (data is Map && data['message'] is String) {
      return data['message'] as String;
    }

    return 'Unable to connect to AgriLink Lanka.';
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
