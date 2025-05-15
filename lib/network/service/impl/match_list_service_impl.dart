import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:topdeck_app_flutter/network/supabase_config.dart';
import 'package:topdeck_app_flutter/model/entities/match.dart';

/// Service implementation for listing matches with edge function and fallback
class MatchListServiceImpl {
  /// The Supabase client
  final SupabaseClient client = supabase;
  
  /// Get matches for the current user
  Future<List<Map<String, dynamic>>> getUserMatches() async {
    try {
      final currentUser = client.auth.currentUser;
      if (currentUser == null) {
        throw AuthException('User not authenticated');
      }
      
      final session = await client.auth.currentSession;
      if (session == null || session.accessToken.isEmpty) {
        throw AuthException('No valid session found');
      }
      
      // Prima proviamo con l'edge function
      try {
        print('Fetching matches via edge function');
        final response = await client.functions.invoke(
          'see-my-matches',
          headers: {
            'Authorization': 'Bearer ${session.accessToken}',
            'Content-Type': 'application/json',
          },
        );
        
        if (response.status != 200) {
          print('Error response from edge function: ${response.status} - ${response.data}');
          if (response.data is Map && response.data.containsKey('error')) {
            throw Exception(response.data['error']);
          }
          throw Exception('Failed to fetch matches');
        }
        
        // Converti la risposta in una lista di Map<String, dynamic>
        if (response.data is List) {
          return (response.data as List).map((item) {
            // Converti ogni elemento in Map<String, dynamic>
            if (item is Map) {
              return Map<String, dynamic>.from(item);
            } else {
              return <String, dynamic>{'data': item};
            }
          }).toList();
        }
        
        // Se la risposta non è una lista, restituisci una lista vuota
        print('Unexpected response format from edge function, not a list');
        return [];
      } catch (e) {
        print('Error using edge function, falling back to direct DB: $e');
        // Se l'edge function fallisce, usiamo l'approccio diretto
        return await getUserMatchesDirectly();
      }
    } catch (e) {
      print('Failed to fetch matches: $e');
      throw Exception('Failed to fetch matches: $e');
    }
  }
  
  /// Get matches directly from database
  Future<List<Map<String, dynamic>>> getUserMatchesDirectly() async {
    try {
      final currentUser = client.auth.currentUser;
      if (currentUser == null) {
        throw AuthException('User not authenticated');
      }
      
      print('Fetching matches directly from DB');
      
      final response = await client
          .from('matches')
          .select('*, player1:player1_id(username), player2:player2_id(username), player1_deck:player1_deck_id(name), player2_deck:player2_deck_id(name)')
          .or('player1_id.eq.${currentUser.id},player2_id.eq.${currentUser.id}')
          .order('date', ascending: false);
      
      return response;
    } catch (e) {
      print('Failed to fetch matches directly: $e');
      throw Exception('Failed to fetch matches: $e');
    }
  }
  
  /// Convert raw response to Match objects
  List<Match> convertResponseToMatches(List<Map<String, dynamic>> response) {
    return response.map((data) => Match.fromJson(data)).toList();
  }
} 