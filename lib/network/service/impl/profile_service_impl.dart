import 'package:topdeck_app_flutter/network/service/impl/base_service_impl.dart';
import 'package:topdeck_app_flutter/network/supabase_config.dart';

/// Service implementation for the profiles table
class ProfileServiceImpl extends BaseServiceImpl {
  @override
  String get tableName => 'profiles';
  
  /// Finds a profile by username
  Future<Map<String, dynamic>?> findByUsername(String username) async {
    final response = await client.from(tableName)
        .select()
        .eq('username', username)
        .maybeSingle();
    return response;
  }
  
  /// Gets the current user's profile
  Future<Map<String, dynamic>?> getCurrentUserProfile() async {
    final currentUserId = supabase.auth.currentUser?.id;
    if (currentUserId == null) return null;
    
    return getById(currentUserId);
  }
  
  /// Updates the avatar URL for a profile
  Future<Map<String, dynamic>> updateAvatar(String id, String avatarUrl) async {
    final response = await client.from(tableName)
        .update({'avatar_url': avatarUrl})
        .eq('id', id)
        .select()
        .single();
    return response;
  }
} 