import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:topdeck_app_flutter/network/supabase_config.dart';

/// Service implementation for user search functionality using Edge Functions
class UserSearchServiceImpl {
  /// The Supabase client
  final SupabaseClient client = supabase;
  
  /// Searches for users by username using the Edge Function
  Future<List<Map<String, dynamic>>> searchUsers(String query) async {
    try {
      if (query.isEmpty) {
        return [];
      }

      // Invece di inviare un URL completo, possiamo passare il nome della funzione
      // e aggiungere un query parameter personalizzato che verrà usato nella URL
      final functionName = 'search-users?query=${Uri.encodeComponent(query)}';
      
      final response = await client.functions.invoke(
        functionName,
        method: HttpMethod.get,
      );
      
      if (response.status != 200) {
        throw Exception(response.data['error'] ?? 'Failed to search users');
      }
      
      // The response.data should be a List<dynamic> that we can cast to List<Map<String, dynamic>>
      return (response.data as List).cast<Map<String, dynamic>>();
    } catch (e) {
      throw Exception('Failed to search users: $e');
    }
  }
  
  /// Gets a user profile by ID
  Future<Map<String, dynamic>?> getUserById(String userId) async {
    try {
      final response = await client
          .from('profiles')
          .select()
          .eq('id', userId)
          .maybeSingle();
      
      return response;
    } catch (e) {
      throw Exception('Failed to get user: $e');
    }
  }
} 