import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:topdeck_app_flutter/model/entities/profile.dart';

/// Repository interface for authentication operations
abstract class AuthRepository {
  /// Sign up with email and password, and create a user profile
  Future<Profile> signUp({
    required String email,
    required String password,
    required String username,
    required String nome,
    required String cognome,
    required DateTime dataDiNascita,
    required String citta,
    required String provincia,
    required String stato,
    String? avatarUrl,
  });
  
  /// Sign in with email and password
  Future<AuthResponse> signIn({
    required String email,
    required String password,
  });
  
  /// Sign out the current user
  Future<void> signOut();
  
  /// Reset password for the given email
  Future<void> resetPassword({required String email});
  
  /// Update password for the current user
  Future<UserResponse> updatePassword({required String password});
  
  /// Get the current user
  User? getCurrentUser();
  
  /// Check if the user is authenticated
  bool isAuthenticated();
  
  /// Get the current session
  Session? getCurrentSession();
  
  /// Listen to auth state changes
  Stream<AuthState> onAuthStateChange();
} 