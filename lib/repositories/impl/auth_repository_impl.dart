import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:topdeck_app_flutter/model/entities/profile.dart';
import 'package:topdeck_app_flutter/network/service/impl/auth_service_impl.dart';
import 'package:topdeck_app_flutter/repositories/auth_repository.dart';
import 'package:topdeck_app_flutter/repositories/profile_repository.dart';

/// Implementation of the authentication repository
class AuthRepositoryImpl implements AuthRepository {
  /// The authentication service
  final AuthServiceImpl _authService;
  
  /// The profile repository for creating user profiles
  final ProfileRepository _profileRepository;

  /// Constructor
  AuthRepositoryImpl(this._authService, this._profileRepository);

  @override
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
  }) async {
    // Register the user with Supabase Auth
    final authResponse = await _authService.signUp(
      email: email,
      password: password,
      data: {
        'username': username,
      },
    );
    
    if (authResponse.user == null) {
      throw Exception('Registration failed: User not created');
    }
    
    // Create a profile for the user
    final profile = Profile.create(
      username: username,
      nome: nome,
      cognome: cognome,
      dataDiNascita: dataDiNascita,
      citta: citta,
      provincia: provincia,
      stato: stato,
      avatarUrl: avatarUrl,
    );
    
    // Override the UUID with the Supabase Auth user ID
    final profileWithAuthId = profile.copyWith(id: authResponse.user!.id);
    
    // Save the profile in the profiles table
    return await _profileRepository.create(profileWithAuthId);
  }

  @override
  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    return await _authService.signIn(
      email: email,
      password: password,
    );
  }

  @override
  Future<void> signOut() async {
    await _authService.signOut();
  }

  @override
  Future<void> resetPassword({required String email}) async {
    await _authService.resetPassword(email: email);
  }

  @override
  Future<UserResponse> updatePassword({required String password}) async {
    return await _authService.updatePassword(password: password);
  }

  @override
  User? getCurrentUser() {
    return _authService.getCurrentUser();
  }

  @override
  bool isAuthenticated() {
    return _authService.isAuthenticated();
  }

  @override
  Session? getCurrentSession() {
    return _authService.getCurrentSession();
  }

  @override
  Stream<AuthState> onAuthStateChange() {
    return _authService.onAuthStateChange();
  }
} 