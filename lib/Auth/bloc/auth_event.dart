part of 'auth_bloc.dart';

@immutable
sealed class AuthEvent {}

class RegisterUserEvent extends AuthEvent {
  final String email;
  final String password;

  RegisterUserEvent(this.email, this.password);
}

class loginevent extends AuthEvent {
  final String email;
  final String password;

  loginevent(this.email, this.password);
}

class logoutevent extends AuthEvent {}

class checkstatus extends AuthEvent {}
