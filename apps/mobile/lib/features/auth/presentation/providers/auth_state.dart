import '../../data/models/app_user.dart';

class AuthState {
  const AuthState({required this.isAuthenticated, this.user, this.message});

  const AuthState.unauthenticated({String? message})
    : this(isAuthenticated: false, message: message);

  const AuthState.authenticated(AppUser user)
    : this(isAuthenticated: true, user: user);

  final bool isAuthenticated;
  final AppUser? user;
  final String? message;

  AuthState copyWith({
    bool? isAuthenticated,
    AppUser? user,
    String? message,
    bool clearMessage = false,
  }) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      user: user ?? this.user,
      message: clearMessage ? null : message ?? this.message,
    );
  }
}
