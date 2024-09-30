part of 'auth_bloc.dart';

abstract class AuthEvent {}

class EmailFieldTextChangeEvent extends AuthEvent {
  final String email;

  EmailFieldTextChangeEvent(this.email);
}

class PasswordFieldTextChangeEvent extends AuthEvent {
  final String password;

  PasswordFieldTextChangeEvent(this.password);
}

class VerifyCredentialEvent extends AuthEvent {
  final String email;
  final String password;

  VerifyCredentialEvent(this.email, this.password);
}

class VisiblePasswordFieldEvent extends AuthEvent {}

class InVisiblePasswordFieldEvent extends AuthEvent {}

class CreateFirebaseUserEvent extends AuthEvent {
  final String name;
  final String email;
  final String password;

  CreateFirebaseUserEvent({
    required this.name,
    required this.email,
    required this.password,
  });
}

class GoogleSignInEvent extends AuthEvent {
  GoogleSignInEvent();
}
