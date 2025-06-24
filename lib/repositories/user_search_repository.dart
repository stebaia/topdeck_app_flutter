import 'package:topdeck_app_flutter/model/user.dart';

/// Repository for searching users
abstract class UserSearchRepository {
  /// Search for users by username query
  Future<List<Map<String, dynamic>>> searchUsers(String query);

  Future<List<UserProfile>> getAllMyFriends();
  
  /// Get user by ID
  Future<Map<String, dynamic>?> getUserById(String userId);
} 