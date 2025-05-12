import 'package:topdeck_app_flutter/model/entities/profile.dart';
import 'package:topdeck_app_flutter/repositories/base_repository.dart';

/// Repository interface for Profile entities
abstract class ProfileRepository extends BaseRepository<Profile> {
  /// Finds a profile by username
  Future<Profile?> findByUsername(String username);
  
  /// Gets the current user's profile
  Future<Profile?> getCurrentUserProfile();
  
  /// Updates the avatar URL for a profile
  Future<Profile> updateAvatar(String id, String avatarUrl);
} 