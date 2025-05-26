import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:topdeck_app_flutter/network/supabase_config.dart';
import 'package:flutter/foundation.dart' show kIsWeb, debugPrint;
import 'package:google_sign_in/google_sign_in.dart';

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

  /// Sign in with Google
  Future<bool> signInWithGoogle() async {
    try {
      final response = await client.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: kIsWeb ? null : 'io.supabase.topdeck://login-callback/',
      );
      return response;
    } catch (e) {
      debugPrint('Google sign in error: $e');
      return false;
    }
  }

  /// Sign in with Google natively (using google_sign_in package)
  Future<AuthResponse> signInWithGoogleNatively() async {
    try {
      // TODO: Sostituisci con i tuoi Client ID
      // Per ottenere questi ID:
      // 1. Vai su https://console.cloud.google.com/
      // 2. Crea un nuovo progetto o seleziona un progetto esistente
      // 3. Vai su "API e servizi" > "Credenziali"
      // 4. Crea credenziali OAuth 2.0 per:
      //    - "ID client OAuth 2.0 per app iOS" (per il clientId iOS)
      //    - "ID client OAuth 2.0 per applicazione Web" (per il serverClientId/webClientId)

      // iOS Client ID (lascia come null se stai sviluppando solo per Android)
      const iosClientId =
          '506643079134-kh27d5i5va1g7emrj59gfe0pp0usduh8.apps.googleusercontent.com'; // 'YOUR_IOS_CLIENT_ID.apps.googleusercontent.com';

      // Web Client ID (necessario per entrambi Android e iOS)
      const webClientId =
          '506643079134-t7lqa62b5u9cunf1i0sc8ibo0t0vk1fm.apps.googleusercontent.com';

      final GoogleSignIn googleSignIn = GoogleSignIn(
        clientId: kIsWeb ? null : iosClientId,
        serverClientId: webClientId,
      );

      // Inizia il flusso di accesso
      final googleUser = await googleSignIn.signIn();
      if (googleUser == null) {
        throw Exception('Google sign in cancelled by user');
      }

      // Ottieni l'autenticazione
      final googleAuth = await googleUser.authentication;
      final accessToken = googleAuth.accessToken;
      final idToken = googleAuth.idToken;

      if (accessToken == null) {
        throw Exception('No Access Token found');
      }
      if (idToken == null) {
        throw Exception('No ID Token found');
      }

      // Usa i token per autenticarti con Supabase
      final response = await client.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
        accessToken: accessToken,
      );

      return response;
    } catch (e) {
      debugPrint('Native Google sign in error: $e');
      rethrow;
    }
  }

  /// Sign out the current user
  Future<void> signOut() async {
    await client.auth.signOut();
  }

  /// Reset password for the given email
  Future<void> resetPassword({required String email}) async {
    await client.auth
        .resetPasswordForEmail(email, redirectTo: 'topdeck://password-reset');
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

  /// Recovery password for the given email
  Future<void> recoveryPassword(
      {required String email, required String redirectTo}) async {
    await client.auth
        .resetPasswordForEmail(email, redirectTo: 'topdeck://password-reset');
  }
}
