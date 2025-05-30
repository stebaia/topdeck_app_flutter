import 'package:equatable/equatable.dart';
import 'package:topdeck_app_flutter/model/entities/profile.dart';

/// Base class for all authentication states
abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

/// Initial authentication state
class AuthInitialState extends AuthState {}

/// Loading authentication state
class AuthLoadingState extends AuthState {}

/// Authenticated state
class AuthenticatedState extends AuthState {
  final Profile profile;

  const AuthenticatedState({required this.profile});

  @override
  List<Object> get props => [profile];
}

/// Unauthenticated state
class UnauthenticatedState extends AuthState {}

/// Authentication error state
class AuthErrorState extends AuthState {
  final String message;

  const AuthErrorState({required this.message});

  @override
  List<Object> get props => [message];
}

/// Password reset sent state
class PasswordResetSentState extends AuthState {
  final String email;

  const PasswordResetSentState({required this.email});

  @override
  List<Object> get props => [email];
}

/// Password updated state
class PasswordUpdatedState extends AuthState {}

/// Stato per utente autenticato con Google ma senza profilo
class GoogleAuthenticatedNeedsProfileState extends AuthState {
  final String userId;
  final String email;
  final String? name;
  final String? avatarUrl;

  const GoogleAuthenticatedNeedsProfileState({
    required this.userId,
    required this.email,
    this.name,
    this.avatarUrl,
  });

  @override
  List<Object?> get props => [userId, email, name, avatarUrl];
}

class AuthPasswordResetState extends AuthState {
  const AuthPasswordResetState();
}

class TryToRecoveryPasswordState extends AuthState {
  const TryToRecoveryPasswordState();
}

/// Recovery password state
class RecoveryPasswordState extends AuthState {
  const RecoveryPasswordState();
}

class ConfirmNewPasswordState extends AuthState {
  const ConfirmNewPasswordState();
}

class ConfirmNewPasswordSuccessState extends AuthState {
  const ConfirmNewPasswordSuccessState();
}

class ConfirmNewPasswordEmptyErrorState extends AuthState {
  const ConfirmNewPasswordEmptyErrorState();
}

class ConfirmNewPasswordValidationErrorState extends AuthState {
  const ConfirmNewPasswordValidationErrorState();
}

class ConfirmNewPasswordMismatchErrorState extends AuthState {
  const ConfirmNewPasswordMismatchErrorState();
}

class ConfirmNewPasswordErrorState extends AuthState {
  final String? message;

  const ConfirmNewPasswordErrorState({this.message});

  @override
  List<Object?> get props => [message];
}
