import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:topdeck_app_flutter/network/service/impl/base_service_impl.dart';
import 'package:topdeck_app_flutter/network/supabase_config.dart';

/// Service implementation for friend requests using Edge Functions
class FriendServiceImpl extends BaseServiceImpl {
  @override
  String get tableName => 'friend_requests';
  
  /// Sends a friend request using the Edge Function
  Future<Map<String, dynamic>> sendFriendRequest(String recipientId) async {
    try {
      final response = await supabase.functions.invoke(
        'send-friend-request',
        body: {'recipient_id': recipientId},
      );
      
      if (response.status != 200) {
        throw Exception(response.data['error'] ?? 'Failed to send friend request');
      }
      
      return response.data;
    } catch (e) {
      throw Exception('Failed to send friend request: $e');
    }
  }
  
  /// Accepts a friend request using the Edge Function
  Future<Map<String, dynamic>> acceptFriendRequest(String friendId) async {
    try {
      final response = await supabase.functions.invoke(
        'accept-friend-request',
        body: {'friendId': friendId},
      );
      
      if (response.status != 200) {
        throw Exception(response.data['error'] ?? 'Failed to accept friend request');
      }
      
      return response.data;
    } catch (e) {
      throw Exception('Failed to accept friend request: $e');
    }
  }
  
  /// Gets all friend requests for the current user
  Future<List<Map<String, dynamic>>> getFriendRequests() async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) {
      throw Exception('User not authenticated');
    }
    
    final response = await client
        .from(tableName)
        .select()
        .eq('recipient_id', userId)
        .eq('status', 'pending');
    
    return response;
  }
  
  /// Gets all friends of the current user
  Future<List<Map<String, dynamic>>> getFriends() async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) {
      throw Exception('User not authenticated');
    }
    
    // This query depends on your database structure
    // Assuming you have a 'status' field for accepted friend requests
    final response = await client
        .from(tableName)
        .select()
        .or('sender_id.eq.$userId,recipient_id.eq.$userId')
        .eq('status', 'accepted');
    
    return response;
  }
} 