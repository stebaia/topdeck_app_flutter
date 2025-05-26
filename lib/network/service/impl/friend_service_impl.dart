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
      
      // Get JWT token
      final session = await supabase.auth.currentSession;
      if (session == null || session.accessToken.isEmpty) {
        print('No valid session found, cannot authenticate with Edge Function');
        throw Exception('User not authenticated or session expired');
      }

      // Prima verifichiamo se esiste già un'amicizia o una richiesta pendente
      final currentUserId = supabase.auth.currentUser?.id;
      if (currentUserId == null) {
        throw Exception('User not authenticated');
      }

      print('Checking if friendship already exists between $currentUserId and $recipientId');
      
      // Cerca se c'è già un'amicizia accettata o una richiesta pendente
      final existingRelations = await client
          .from(tableName)
          .select()
          .or('and(user_id.eq.$currentUserId,friend_id.eq.$recipientId),and(user_id.eq.$recipientId,friend_id.eq.$currentUserId)')
          .or('status.eq.accepted,status.eq.pending');
      
      print('Existing relations: $existingRelations');
      
      if (existingRelations.isNotEmpty) {
        final status = existingRelations[0]['status'];
        if (status == 'accepted') {
          throw Exception('Questo utente è già tuo amico');
        } else if (status == 'pending') {
          throw Exception('Esiste già una richiesta di amicizia pendente con questo utente');
        }
      }
      
      // Use explicit Authorization header
      final headers = {
        'Authorization': 'Bearer ${session.accessToken}',
      };
      
      // Print header info for debugging
      print('Using authorization header: ${headers['Authorization']?.substring(0, 15)}...');
      
      final response = await supabase.functions.invoke(
        'send-friend-request',
        body: {'recipient_id': recipientId},
        headers: headers,
      );
      
      print('Edge function response status: ${response.status}');
      print('Edge function response data type: ${response.data.runtimeType}');
      print('Edge function response data: ${response.data}');
      
      if (response.status != 200) {
        throw Exception(response.data is Map 
          ? response.data['error'] ?? 'Failed to send friend request'
          : 'Failed to send friend request: ${response.data}');
      }
      
      // Handle the case where data is a String
      if (response.data is String) {
        try {
          // Try to convert from JSON string to Map if needed
          print('Converting response data from String to Map');
          return {'message': response.data};
        } catch (e) {
          print('Error converting response data: $e');
          return {'message': 'Friend request sent', 'raw_response': response.data};
        }
      } else if (response.data is Map<String, dynamic>) {
        // If it's already a Map, return it directly
        return response.data;
      } else {
        // For any other type, create a new Map with the data
        print('Unexpected response data type: ${response.data.runtimeType}');
        return {'message': 'Friend request sent', 'raw_response': response.data.toString()};
      }
    } catch (e) {
      print('Exception in sendFriendRequest: $e');
      throw Exception('Failed to send friend request: $e');
    }
  }
  
  /// Accepts a friend request using the Edge Function
  Future<Map<String, dynamic>> acceptFriendRequest(String friendId) async {
    try {
      if (friendId.isEmpty) {
        throw Exception('friendId non può essere vuoto');
      }
      
      print('Invoking edge function accept-friend-request with friendId: $friendId');
      
      // Get JWT token
      final session = await supabase.auth.currentSession;
      if (session == null || session.accessToken.isEmpty) {
        print('No valid session found, cannot authenticate with Edge Function');
        throw Exception('User not authenticated or session expired');
      }
      
      // Use explicit Authorization header
      final headers = {
        'Authorization': 'Bearer ${session.accessToken}',
        'Content-Type': 'application/json',
      };
      
      print('Sending request with friendId: $friendId');
      
      final response = await supabase.functions.invoke(
        'accept-friend-request',
        body: {'friendId': friendId},
        headers: headers,
      );
      
      print('Edge function response status: ${response.status}');
      print('Edge function response data type: ${response.data.runtimeType}');
      print('Edge function response data: ${response.data}');
      
      if (response.status != 200) {
        throw Exception(response.data is Map 
          ? response.data['error'] ?? 'Failed to accept friend request'
          : 'Failed to accept friend request: ${response.data}');
      }
      
      // Handle the case where data is a String
      if (response.data is String) {
        try {
          // Try to convert from JSON string to Map if needed
          print('Converting response data from String to Map');
          return {'message': response.data};
        } catch (e) {
          print('Error converting response data: $e');
          return {'message': 'Friend request accepted', 'raw_response': response.data};
        }
      } else if (response.data is Map<String, dynamic>) {
        // If it's already a Map, return it directly
        return response.data;
      } else {
        // For any other type, create a new Map with the data
        print('Unexpected response data type: ${response.data.runtimeType}');
        return {'message': 'Friend request accepted', 'raw_response': response.data.toString()};
      }
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
      // Ripristino della query originale che funzionava
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
      
      // Check if session exists
      final session = await supabase.auth.currentSession;
      if (session == null || session.accessToken.isEmpty) {
        print('No valid session found, cannot authenticate with Edge Function');
        throw Exception('User not authenticated or session expired');
      }
      
      print('Session token: ${session.accessToken}');
      
      // EXPLICITLY set Authorization header with Bearer token
      final headers = {
        'Authorization': 'Bearer ${session.accessToken}',
      };
      
      print('Headers: $headers');
      
      // Call with explicit headers
      final response = await supabase.functions.invoke(
        'debug-get-friends',
        headers: headers,
      );
      
      print('Debug edge function response status: ${response.status}');
      print('Debug edge function response data type: ${response.data.runtimeType}');
      
      if (response.status != 200) {
        throw Exception(response.data is Map 
          ? response.data['error'] ?? 'Failed to debug friend requests'
          : 'Failed to debug friend requests: ${response.data}');
      }
      
      print('Debug data: ${response.data}');
      
      // Handle the case where data is a String
      if (response.data is String) {
        try {
          // Try to convert from JSON string to Map if needed
          print('Converting response data from String to Map');
          return {'message': response.data};
        } catch (e) {
          print('Error converting response data: $e');
          return {'message': 'Debug info retrieved', 'raw_response': response.data};
        }
      } else if (response.data is Map<String, dynamic>) {
        // If it's already a Map, return it directly
        return response.data;
      } else {
        // For any other type, create a new Map with the data
        print('Unexpected response data type: ${response.data.runtimeType}');
        return {'message': 'Debug info retrieved', 'raw_response': response.data.toString()};
      }
    } catch (e) {
      print('Exception in debugGetFriends: $e');
      throw Exception('Failed to debug friend requests: $e');
    }
  }
} 