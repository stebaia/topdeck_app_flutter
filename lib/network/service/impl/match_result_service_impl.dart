import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:topdeck_app_flutter/network/supabase_config.dart';

/// Service implementation for match results
class MatchResultServiceImpl {
  /// The Supabase client
  final SupabaseClient client = supabase;

  /// Submit a match result
  Future<Map<String, dynamic>> submitMatchResult({
    required String matchId,
    required String winnerId,
    int player1Score = 0,
    int player2Score = 0,
    String? notes,
  }) async {
    try {
      print('Submitting match result for match: $matchId, winner: $winnerId');
      
      final response = await client.functions.invoke(
        'submit-match-result',
        body: {
          'match_id': matchId,
          'winner_id': winnerId,
          'player1_score': player1Score,
          'player2_score': player2Score,
          'notes': notes,
        },
      );

      if (response.status != 200) {
        throw Exception('Failed to submit match result: ${response.data}');
      }

      print('Successfully submitted match result: ${response.data}');
      return response.data;
    } catch (e) {
      print('Error in submitMatchResult: $e');
      
      // Fallback: try direct DB update if the edge function fails
      try {
        final currentUser = client.auth.currentUser;
        if (currentUser == null) {
          throw Exception('User not authenticated');
        }
        
        // Get match details to verify user is a participant
        final match = await client
          .from('matches')
          .select()
          .eq('id', matchId)
          .single();
        
        // Verify user is a participant
        if (match['player1_id'] != currentUser.id && match['player2_id'] != currentUser.id) {
          throw Exception('You are not a participant in this match');
        }
        
        // Verify winner is a participant
        if (winnerId != match['player1_id'] && winnerId != match['player2_id']) {
          throw Exception('Winner must be a participant in this match');
        }
        
        // Update match result - only update the winner_id since other fields don't exist in the schema
        await client
          .from('matches')
          .update({
            'winner_id': winnerId,
          })
          .eq('id', matchId);
        
        // Get updated match
        final updatedMatch = await client
          .from('matches')
          .select('*, player1:player1_id(username), player2:player2_id(username), winner:winner_id(username)')
          .eq('id', matchId)
          .single();
        
        return {
          'message': 'Match result recorded successfully (direct DB)',
          'match': updatedMatch,
        };
      } catch (dbError) {
        print('Complete failure in submitting match result: $dbError');
        throw Exception('Failed to submit match result: ${e.toString()}');
      }
    }
  }
  
  /// Get match details by ID
  Future<Map<String, dynamic>> getMatchDetails(String matchId) async {
    try {
      final response = await client
        .from('matches')
        .select('*, player1:player1_id(username), player2:player2_id(username), player1_deck:player1_deck_id(name), player2_deck:player2_deck_id(name), winner:winner_id(username)')
        .eq('id', matchId)
        .single();
      
      return response;
    } catch (e) {
      print('Error in getMatchDetails: $e');
      throw Exception('Failed to get match details: ${e.toString()}');
    }
  }
} 