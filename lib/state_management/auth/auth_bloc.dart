import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logger/logger.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import 'package:topdeck_app_flutter/repositories/auth_repository.dart';
import 'package:topdeck_app_flutter/repositories/profile_repository.dart';
import 'package:topdeck_app_flutter/state_management/auth/auth_event.dart';
import 'package:topdeck_app_flutter/state_management/auth/auth_state.dart';

/// BLoC for managing authentication state
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;
  final ProfileRepository _profileRepository;
  final Logger _logger;
  StreamSubscription? _authSubscription;

  /// Constructor
  AuthBloc({
    required AuthRepository authRepository,
    required ProfileRepository profileRepository,
    required Logger logger,
  })  : _authRepository = authRepository,
        _profileRepository = profileRepository,
        _logger = logger,
        super(AuthInitialState()) {
    on<CheckAuthStatusEvent>(_onCheckAuthStatus);
    on<SignUpEvent>(_onSignUp);
    on<SignInEvent>(_onSignIn);
    on<SignOutEvent>(_onSignOut);
    on<ResetPasswordEvent>(_onResetPassword);
    on<UpdatePasswordEvent>(_onUpdatePassword);

    // Listen to authentication state changes
    _authSubscription = _authRepository.onAuthStateChange().listen((event) {
      if (event.event == supabase.AuthChangeEvent.signedIn) {
        add(CheckAuthStatusEvent());
      } else if (event.event == supabase.AuthChangeEvent.signedOut) {
        emit(UnauthenticatedState());
      }
    });
  }

  @override
  Future<void> close() {
    _authSubscription?.cancel();
    return super.close();
  }

  /// Handle check auth status event
  Future<void> _onCheckAuthStatus(
      CheckAuthStatusEvent event, Emitter<AuthState> emit) async {
    try {
      emit(AuthLoadingState());
      
      if (_authRepository.isAuthenticated()) {
        final user = _authRepository.getCurrentUser();
        if (user != null) {
          final profile = await _profileRepository.get(user.id);
          if (profile != null) {
            emit(AuthenticatedState(profile: profile));
          } else {
            emit(UnauthenticatedState());
          }
        } else {
          emit(UnauthenticatedState());
        }
      } else {
        emit(UnauthenticatedState());
      }
    } catch (e) {
      _logger.e('Error checking auth status: $e');
      emit(AuthErrorState(message: 'Authentication check failed'));
    }
  }

  /// Handle sign up event
  Future<void> _onSignUp(SignUpEvent event, Emitter<AuthState> emit) async {
    try {
      emit(AuthLoadingState());
      
      final profile = await _authRepository.signUp(
        email: event.email,
        password: event.password,
        username: event.username,
        nome: event.nome,
        cognome: event.cognome,
        dataDiNascita: event.dataDiNascita,
        citta: event.citta,
        provincia: event.provincia,
        stato: event.stato,
        avatarUrl: event.avatarUrl,
      );
      
      emit(AuthenticatedState(profile: profile));
    } on supabase.AuthException catch (e) {
      _logger.e('Auth exception during sign up: ${e.message}');
      emit(AuthErrorState(message: e.message));
    } catch (e) {
      _logger.e('Error during sign up: $e');
      emit(AuthErrorState(message: 'Registration failed: $e'));
    }
  }

  /// Handle sign in event
  Future<void> _onSignIn(SignInEvent event, Emitter<AuthState> emit) async {
    try {
      emit(AuthLoadingState());
      
      final authResponse = await _authRepository.signIn(
        email: event.email,
        password: event.password,
      );
      
      if (authResponse.user != null) {
        final profile = await _profileRepository.get(authResponse.user!.id);
        if (profile != null) {
          emit(AuthenticatedState(profile: profile));
        } else {
          emit(AuthErrorState(message: 'Profile not found'));
        }
      } else {
        emit(UnauthenticatedState());
      }
    } on supabase.AuthException catch (e) {
      _logger.e('Auth exception during sign in: ${e.message}');
      emit(AuthErrorState(message: e.message));
    } catch (e) {
      _logger.e('Error during sign in: $e');
      emit(AuthErrorState(message: 'Login failed: $e'));
    }
  }

  /// Handle sign out event
  Future<void> _onSignOut(SignOutEvent event, Emitter<AuthState> emit) async {
    try {
      emit(AuthLoadingState());
      
      await _authRepository.signOut();
      
      emit(UnauthenticatedState());
    } catch (e) {
      _logger.e('Error during sign out: $e');
      emit(AuthErrorState(message: 'Logout failed: $e'));
    }
  }

  /// Handle reset password event
  Future<void> _onResetPassword(
      ResetPasswordEvent event, Emitter<AuthState> emit) async {
    try {
      emit(AuthLoadingState());
      
      await _authRepository.resetPassword(email: event.email);
      
      emit(PasswordResetSentState(email: event.email));
    } catch (e) {
      _logger.e('Error during password reset: $e');
      emit(AuthErrorState(message: 'Password reset failed: $e'));
    }
  }

  /// Handle update password event
  Future<void> _onUpdatePassword(
      UpdatePasswordEvent event, Emitter<AuthState> emit) async {
    try {
      emit(AuthLoadingState());
      
      await _authRepository.updatePassword(password: event.password);
      
      emit(PasswordUpdatedState());
    } catch (e) {
      _logger.e('Error during password update: $e');
      emit(AuthErrorState(message: 'Password update failed: $e'));
    }
  }
} 