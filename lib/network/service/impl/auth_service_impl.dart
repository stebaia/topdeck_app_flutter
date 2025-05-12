import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:topdeck_app_flutter/network/supabase_config.dart';

/// Authentication service for handling user authentication operations
class AuthServiceImpl {
  /// The Supabase client
  final SupabaseClient client = supabase;

  /// Sign up with email and password
  Future<AuthResponse> signUp({
    required String email,
    required String password,
    Map<String, dynamic>? data,
  }) async {
    final response = await client.auth.signUp(
      email: email,
      password: password,
      data: data,
    );
    return response;
  }

  /// Sign in with email and password
  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    final response = await client.auth.signInWithPassword(
      email: email,
      password: password,
    );
    return response;
  }

  /// Sign out the current user
  Future<void> signOut() async {
    await client.auth.signOut();
  }

  /// Reset password for the given email
  Future<void> resetPassword({required String email}) async {
    await client.auth.resetPasswordForEmail(email);
  }

  /// Update password for the current user
  Future<UserResponse> updatePassword({required String password}) async {
    final response = await client.auth.updateUser(
      UserAttributes(
        password: password,
      ),
    );
    return response;
  }

  /// Get the current user
  User? getCurrentUser() {
    return client.auth.currentUser;
  }

  /// Check if the user is authenticated
  bool isAuthenticated() {
    return client.auth.currentUser != null;
  }

  /// Get the current session
  Session? getCurrentSession() {
    return client.auth.currentSession;
  }

  /// Listen to auth state changes
  Stream<AuthState> onAuthStateChange() {
    return client.auth.onAuthStateChange;
  }
}