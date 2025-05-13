import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:topdeck_app_flutter/network/supabase_config.dart';

/// Service implementation for match operations
class MatchServiceImpl {
  /// The Supabase client
  final SupabaseClient client = supabase;
  
  /// Find all matches
  Future<List<Map<String, dynamic>>> getAll() async {
    try {
      final response = await client
        .from('matches')
        .select()
        .order('date', ascending: false);
      
      return response;
    } catch (e) {
      throw Exception('Failed to get matches: $e');
    }
  }
  
  /// Get match by ID
  Future<Map<String, dynamic>?> getById(String id) async {
    try {
      final response = await client
        .from('matches')
        .select()
        .eq('id', id)
        .maybeSingle();
      
      return response;
    } catch (e) {
      throw Exception('Failed to get match: $e');
    }
  }
  
  /// Insert a new match (uses smooth-processor edge function)
  Future<Map<String, dynamic>> insert(Map<String, dynamic> data) async {
    try {
      final response = await client.functions.invoke(
        'smooth-processor',
        body: {
          'player1_id': data['player1_id'],
          'player2_id': data['player2_id'],
          'player1_deck': data['player1_deck_id'],
          'player2_deck': data['player2_deck_id'],
          'format': data['format'],
          'winner_id': data['winner_id'],
        },
      );
      
      if (response.status != 200) {
        throw Exception(response.data['error'] ?? 'Failed to create match');
      }
      
      // Get the newly created match
      final matchId = response.data['match_id'];
      final matchData = await getById(matchId);
      
      if (matchData == null) {
        throw Exception('Match was created but could not be retrieved');
      }
      
      return matchData;
    } catch (e) {
      throw Exception('Failed to create match: $e');
    }
  }
  
  /// Finds matches by player ID (either player1 or player2)
  Future<List<Map<String, dynamic>>> findByPlayerId(String playerId) async {
    try {
      final response = await client
        .from('matches')
        .select()
        .or('player1_id.eq.$playerId,player2_id.eq.$playerId')
        .order('date', ascending: false);
      
      return response;
    } catch (e) {
      throw Exception('Failed to find matches by player: $e');
    }
  }
  
  /// Finds matches by format
  Future<List<Map<String, dynamic>>> findByFormat(String format) async {
    try {
      final response = await client
        .from('matches')
        .select()
        .eq('format', format)
        .order('date', ascending: false);
      
      return response;
    } catch (e) {
      throw Exception('Failed to find matches by format: $e');
    }
  }
  
  /// Finds matches by winner ID
  Future<List<Map<String, dynamic>>> findByWinnerId(String winnerId) async {
    try {
      final response = await client
        .from('matches')
        .select()
        .eq('winner_id', winnerId)
        .order('date', ascending: false);
      
      return response;
    } catch (e) {
      throw Exception('Failed to find matches by winner: $e');
    }
  }
  
  /// Updates the winner of a match
  Future<Map<String, dynamic>> updateWinner(String matchId, String winnerId) async {
    try {
      // For this specific operation, we continue using the database directly
      // since there's no specific edge function for it
      final response = await client
        .from('matches')
        .update({'winner_id': winnerId})
        .eq('id', matchId)
        .select()
        .single();
      
      return response;
    } catch (e) {
      throw Exception('Failed to update match winner: $e');
    }
  }
  
  /// Update a match
  Future<Map<String, dynamic>> update(String id, Map<String, dynamic> data) async {
    try {
      final response = await client
        .from('matches')
        .update(data)
        .eq('id', id)
        .select()
        .single();
      
      return response;
    } catch (e) {
      throw Exception('Failed to update match: $e');
    }
  }
  
  /// Delete a match
  Future<void> delete(String id) async {
    try {
      await client
        .from('matches')
        .delete()
        .eq('id', id);
    } catch (e) {
      throw Exception('Failed to delete match: $e');
    }
  }
} 