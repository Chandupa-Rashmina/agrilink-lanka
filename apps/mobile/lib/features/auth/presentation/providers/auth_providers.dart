import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/auth_service.dart';
import '../../data/models/app_user.dart';
import 'auth_state.dart';

final authServiceProvider = Provider<AuthService>((ref) {
  throw StateError('AuthService has not been configured.');
});

final authControllerProvider = AsyncNotifierProvider<AuthController, AuthState>(
  AuthController.new,
);

class AuthController extends AsyncNotifier<AuthState> {
  AuthService get _service => ref.read(authServiceProvider);

  @override
  Future<AuthState> build() async {
    final hasToken = await _service.hasToken();

    if (!hasToken) {
      return const AuthState.unauthenticated();
    }

    try {
      final user = await _service.fetchProfile();
      return AuthState.authenticated(user);
    } catch (_) {
      await _service.logout();
      return const AuthState.unauthenticated();
    }
  }

  Future<bool> login({required String email, required String password}) {
    return _authenticate(
      () => _service.login(email: email, password: password),
    );
  }

  Future<bool> register({
    required String name,
    required String email,
    required String phone,
    required String district,
    required String password,
  }) {
    return _authenticate(
      () => _service.register(
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
    final previous = state.valueOrNull ?? const AuthState.unauthenticated();
    state = const AsyncLoading();

    try {
      final user = await _service.updateProfile(
        name: name,
        email: email,
        phone: phone,
        district: district,
      );
      state = AsyncData(AuthState.authenticated(user));
      return true;
    } on DioException catch (error) {
      state = AsyncData(previous.copyWith(message: _message(error)));
      return false;
    }
  }

  Future<void> logout() async {
    state = const AsyncLoading();
    await _service.logout();
    state = const AsyncData(AuthState.unauthenticated());
  }

  Future<void> expireSession() async {
    state = const AsyncData(
      AuthState.unauthenticated(
        message: 'Your session expired. Please sign in again.',
      ),
    );
  }

  Future<bool> _authenticate(Future<AppUser> Function() action) async {
    state = const AsyncLoading();

    try {
      final user = await action();
      state = AsyncData(AuthState.authenticated(user));
      return true;
    } on DioException catch (error) {
      state = AsyncData(AuthState.unauthenticated(message: _message(error)));
      return false;
    }
  }

  String _message(DioException error) {
    final data = error.response?.data;

    if (data is Map && data['message'] is String) {
      return data['message'] as String;
    }

    if (data is Map && data['errors'] is Map) {
      final errors = data['errors'] as Map;
      for (final value in errors.values) {
        if (value is List && value.isNotEmpty) {
          return value.first.toString();
        }
      }
    }

    return 'Unable to connect to AgriLink Lanka.';
  }
}
