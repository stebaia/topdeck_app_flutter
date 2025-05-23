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