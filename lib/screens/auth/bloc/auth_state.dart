part of 'auth_bloc.dart';

abstract class AuthState {}

class AuthInitialState extends AuthState {}

class AuthEmailFieldValidationState extends AuthState {
  final bool isValid;

  AuthEmailFieldValidationState(this.isValid);
}

class AuthPasswordFieldValidationState extends AuthState {
  final bool isValid;

  AuthPasswordFieldValidationState(this.isValid);
}

class AuthLoadingState extends AuthState {}

class VisiblePasswordFieldState extends AuthState {}

class InVisiblePasswordFieldState extends AuthState {}

class FirebaseLoginInvalidUserState extends AuthState {}

class FirebaseAlreadyLoggedInUserState extends AuthState {}

class FirebaseLoginInvalidPasswordState extends AuthState {}

class FirebaseLoginFailedState extends AuthState {
  final String? errorMessage;

  FirebaseLoginFailedState(this.errorMessage);
}

class FirebaseLoginSuccessHomeState extends AuthState {}
