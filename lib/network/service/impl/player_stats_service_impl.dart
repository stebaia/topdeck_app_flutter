import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:topdeck_app_flutter/network/supabase_config.dart';

/// Service implementation for player statistics using Edge Functions
class PlayerStatsServiceImpl {
  /// The Supabase client
  final SupabaseClient client = supabase;
  
  /// Updates the ELO rating for the current user using the Edge Function
  Future<Map<String, dynamic>> updateEloRating(int newEloRating) async {
    try {
      final response = await client.functions.invoke(
        'update-elo-rating',
        body: {'newEloRating': newEloRating},
      );
      
      if (response.status != 200) {
        throw Exception(response.data['error'] ?? 'Failed to update ELO rating');
      }
      
      return response.data;
    } catch (e) {
      throw Exception('Failed to update ELO rating: $e');
    }
  }
  
  /// Updates the tournament points for the current user using the Edge Function
  Future<Map<String, dynamic>> updateTournamentPoints(int tournamentPoints) async {
    try {
      final response = await client.functions.invoke(
        'update-tournament-points',
        body: {'tournamentPoints': tournamentPoints},
      );
      
      if (response.status != 200) {
        throw Exception(response.data['error'] ?? 'Failed to update tournament points');
      }
      
      return response.data;
    } catch (e) {
      throw Exception('Failed to update tournament points: $e');
    }
  }
  
  /// Gets the current player's statistics
  Future<Map<String, dynamic>?> getCurrentPlayerStats() async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) {
      throw Exception('User not authenticated');
    }
    
    try {
      final response = await client
          .from('players')
          .select()
          .eq('user_id', userId)
          .maybeSingle();
      
      return response;
    } catch (e) {
      throw Exception('Failed to get player stats: $e');
    }
  }
} 