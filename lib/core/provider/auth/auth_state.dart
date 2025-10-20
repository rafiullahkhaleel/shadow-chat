import 'package:firebase_auth/firebase_auth.dart';
class AuthState {
  final User? user;
  final bool isLoading;

  AuthState({this.user, this.isLoading = false});

  AuthState copyWith({User? user, bool? isLoading}) {
    return AuthState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}
