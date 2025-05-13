import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:topdeck_app_flutter/network/supabase_config.dart';

/// Service implementation for match creation using Edge Functions
class MatchCreationServiceImpl {
  /// The Supabase client
  final SupabaseClient client = supabase;
  
  /// Creates a new match using the Edge Function
  Future<Map<String, dynamic>> createMatch({
    required String homeTeam,
    required String awayTeam,
    required DateTime matchDate,
  }) async {
    try {
      final response = await client.functions.invoke(
        'create-match',
        body: {
          'homeTeam': homeTeam,
          'awayTeam': awayTeam,
          'matchDate': matchDate.toIso8601String(),
        },
      );
      
      if (response.status != 201) {
        throw Exception(response.data['error'] ?? 'Failed to create match');
      }
      
      return response.data[0];
    } catch (e) {
      throw Exception('Failed to create match: $e');
    }
  }

  /// Records a match result using the smooth-processor edge function
  Future<Map<String, dynamic>> recordMatchResult({
    required String player1Id,
    required String player2Id,
    required String player1DeckId,
    required String player2DeckId,
    required String format,
    required String winnerId,
  }) async {
    try {
      final response = await client.functions.invoke(
        'smooth-processor',
        body: {
          'player1_id': player1Id,
          'player2_id': player2Id,
          'player1_deck': player1DeckId,
          'player2_deck': player2DeckId,
          'format': format,
          'winner_id': winnerId,
        },
      );
      
      if (response.status != 200) {
        throw Exception(response.data['error'] ?? 'Failed to record match result');
      }
      
      return {
        'message': response.data['message'] ?? 'Match recorded successfully',
        'match_id': response.data['match_id'],
      };
    } catch (e) {
      throw Exception('Failed to record match result: $e');
    }
  }
} 