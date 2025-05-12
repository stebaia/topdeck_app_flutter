/// Repository for searching users
abstract class UserSearchRepository {
  /// Search for users by username query
  Future<List<Map<String, dynamic>>> searchUsers(String query);
  
  /// Get user by ID
  Future<Map<String, dynamic>?> getUserById(String userId);
} 