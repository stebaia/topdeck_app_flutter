import 'package:equatable/equatable.dart';

/// Base class for all authentication events
abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

/// Event to check the current authentication status
class CheckAuthStatusEvent extends AuthEvent {}

/// Event for user registration
class SignUpEvent extends AuthEvent {
  final String email;
  final String password;
  final String username;
  final String nome;
  final String cognome;
  final DateTime dataDiNascita;
  final String citta;
  final String provincia;
  final String stato;
  final String? avatarUrl;

  const SignUpEvent({
    required this.email,
    required this.password,
    required this.username,
    required this.nome,
    required this.cognome,
    required this.dataDiNascita,
    required this.citta,
    required this.provincia,
    required this.stato,
    this.avatarUrl,
  });

  @override
  List<Object?> get props => [
        email,
        password,
        username,
        nome,
        cognome,
        dataDiNascita,
        citta,
        provincia,
        stato,
        avatarUrl,
      ];
}

/// Event for user login
class SignInEvent extends AuthEvent {
  final String email;
  final String password;

  const SignInEvent({
    required this.email,
    required this.password,
  });

  @override
  List<Object> get props => [email, password];
}

/// Event for Google sign in
class SignInWithGoogleEvent extends AuthEvent {}

/// Event for native Google sign in using google_sign_in
class SignInWithGoogleNativelyEvent extends AuthEvent {}

/// Event for user logout
class SignOutEvent extends AuthEvent {}

/// Event for password reset
class ResetPasswordEvent extends AuthEvent {
  final String email;

  const ResetPasswordEvent({required this.email});

  @override
  List<Object> get props => [email];
}

/// Event for password update
class UpdatePasswordEvent extends AuthEvent {
  final String password;

  const UpdatePasswordEvent({required this.password});

  @override
  List<Object> get props => [password];
} 