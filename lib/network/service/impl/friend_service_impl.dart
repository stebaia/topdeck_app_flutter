import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:topdeck_app_flutter/network/service/impl/base_service_impl.dart';
import 'package:topdeck_app_flutter/network/supabase_config.dart';

/// Service implementation for friend requests using Edge Functions
class FriendServiceImpl extends BaseServiceImpl {
  @override
  String get tableName => 'friends';
  
  /// Sends a friend request using the Edge Function
  Future<Map<String, dynamic>> sendFriendRequest(String recipientId) async {
    try {
      print('Invoking edge function send-friend-request with recipient_id: $recipientId');
      
      // Ottieni la sessione corrente per avere il token di accesso
      final session = await supabase.auth.currentSession;
      
      if (session == null || session.accessToken.isEmpty) {
        print('No valid session found, cannot authenticate with Edge Function');
        throw Exception('User not authenticated or session expired');
      }
      
      // Configura l'header di autorizzazione
      final headers = {
        'Authorization': 'Bearer ${session.accessToken}',
        'Content-Type': 'application/json'
      };
      
      print('Using access token for authorization (first 10 chars): ${session.accessToken.substring(0, 10)}...');
      
      final response = await supabase.functions.invoke(
        'send-friend-request',
        body: {'recipient_id': recipientId},
        headers: headers,
      );
      
      print('Edge function response status: ${response.status}');
      print('Edge function response data: ${response.data}');
      
      if (response.status != 200) {
        throw Exception(response.data['error'] ?? 'Failed to send friend request');
      }
      
      return response.data;
    } catch (e) {
      print('Exception in sendFriendRequest: $e');
      throw Exception('Failed to send friend request: $e');
    }
  }
  
  /// Accepts a friend request using the Edge Function
  Future<Map<String, dynamic>> acceptFriendRequest(String friendId) async {
    try {
      print('Invoking edge function accept-friend-request with friendId: $friendId');
      
      // Ottieni la sessione corrente per avere il token di accesso
      final session = await supabase.auth.currentSession;
      
      if (session == null || session.accessToken.isEmpty) {
        print('No valid session found, cannot authenticate with Edge Function');
        throw Exception('User not authenticated or session expired');
      }
      
      // Configura l'header di autorizzazione
      final headers = {
        'Authorization': 'Bearer ${session.accessToken}',
        'Content-Type': 'application/json'
      };
      
      print('Using access token for authorization (first 10 chars): ${session.accessToken.substring(0, 10)}...');
      
      final response = await supabase.functions.invoke(
        'accept-friend-request',
        body: {'friendId': friendId},
        headers: headers,
      );
      
      print('Edge function response status: ${response.status}');
      print('Edge function response data: ${response.data}');
      
      if (response.status != 200) {
        throw Exception(response.data['error'] ?? 'Failed to accept friend request');
      }
      
      return response.data;
    } catch (e) {
      print('Exception in acceptFriendRequest: $e');
      throw Exception('Failed to accept friend request: $e');
    }
  }
  
  /// Gets all friend requests for the current user
  Future<List<Map<String, dynamic>>> getFriendRequests() async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) {
      print('ERROR: getFriendRequests - User not authenticated');
      throw Exception('User not authenticated');
    }
    
    print('Fetching friend requests for user: $userId');
    try {
      print('Query: SELECT * FROM $tableName WHERE friend_id = $userId AND status = pending');
      final response = await client
          .from(tableName)
          .select()
          .eq('friend_id', userId)
          .eq('status', 'pending');
      
      print('Friend requests response: $response');
      print('Found ${response.length} friend requests');
      
      return response;
    } catch (e) {
      print('ERROR: Failed to fetch friend requests: $e');
      rethrow;
    }
  }
  
  /// Gets all friends of the current user
  Future<List<Map<String, dynamic>>> getFriends() async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) {
      print('ERROR: getFriends - User not authenticated');
      throw Exception('User not authenticated');
    }
    
    print('Fetching friends for user: $userId');
    try {
      print('Query: SELECT * FROM $tableName WHERE (user_id = $userId OR friend_id = $userId) AND status = accepted');
      // Recupera amicizie accettate dove l'utente è sia mittente che destinatario
      final response = await client
          .from(tableName)
          .select()
          .or('user_id.eq.$userId,friend_id.eq.$userId')
          .eq('status', 'accepted');
      
      print('Friends response: $response');
      print('Found ${response.length} friends');
      
      return response;
    } catch (e) {
      print('ERROR: Failed to fetch friends: $e');
      rethrow;
    }
  }
  
  /// Debug function to get all friendship data for the current user
  Future<Map<String, dynamic>> debugGetFriends() async {
    try {
      print('Calling debug-get-friends edge function');
      
      // Ottieni la sessione corrente per avere il token di accesso
      final session = await supabase.auth.currentSession;
      
      if (session == null || session.accessToken.isEmpty) {
        print('No valid session found, cannot authenticate with Edge Function');
        throw Exception('User not authenticated or session expired');
      }
      
      // Configura l'header di autorizzazione
      final headers = {
        'Authorization': 'Bearer ${session.accessToken}',
        'Content-Type': 'application/json'
      };
      
      final response = await supabase.functions.invoke(
        'debug-get-friends',
        headers: headers,
      );
      
      print('Debug edge function response status: ${response.status}');
      
      if (response.status != 200) {
        throw Exception(response.data['error'] ?? 'Failed to debug friend requests');
      }
      
      print('Debug data: ${response.data}');
      return response.data;
    } catch (e) {
      print('Exception in debugGetFriends: $e');
      throw Exception('Failed to debug friend requests: $e');
    }
  }
} 