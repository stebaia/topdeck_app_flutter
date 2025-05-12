/// Model class for a user profile
class UserProfile {
  /// Constructor
  UserProfile({
    required this.id,
    required this.username,
    this.avatarUrl,
    this.displayName,
  });

  /// User ID
  final String id;
  
  /// Username
  final String username;
  
  /// URL to user's avatar image
  final String? avatarUrl;
  
  /// Display name (may be null if user hasn't set one)
  final String? displayName;
  
  /// Factory constructor to create a UserProfile from json
  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as String,
      username: json['username'] as String,
      avatarUrl: json['avatar_url'] as String?,
      displayName: json['display_name'] as String?,
    );
  }
  
  /// Convert the UserProfile to json
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'avatar_url': avatarUrl,
      'display_name': displayName,
    };
  }
} 