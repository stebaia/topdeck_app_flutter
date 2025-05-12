import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:topdeck_app_flutter/network/service/impl/base_service_impl.dart';

/// Service implementation for the matches table
class MatchServiceImpl extends BaseServiceImpl {
  @override
  String get tableName => 'matches';
  
  /// Finds matches by player ID (either player1 or player2)
  Future<List<Map<String, dynamic>>> findByPlayerId(String playerId) async {
    final response = await client.from(tableName)
        .select()
        .or('player1_id.eq.$playerId,player2_id.eq.$playerId');
    return response;
  }
  
  /// Finds matches by format
  Future<List<Map<String, dynamic>>> findByFormat(String format) async {
    final response = await client.from(tableName)
        .select()
        .eq('format', format);
    return response;
  }
  
  /// Finds matches by winner ID
  Future<List<Map<String, dynamic>>> findByWinnerId(String winnerId) async {
    final response = await client.from(tableName)
        .select()
        .eq('winner_id', winnerId);
    return response;
  }
  
  /// Updates the winner of a match
  Future<Map<String, dynamic>> updateWinner(String matchId, String winnerId) async {
    final response = await client.from(tableName)
        .update({'winner_id': winnerId})
        .eq('id', matchId)
        .select()
        .single();
    return response;
  }
} 