import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:topdeck_app_flutter/model/entities/tournament_match.dart';
import 'package:topdeck_app_flutter/model/entities/tournament_participant.dart';
import 'package:topdeck_app_flutter/network/service/impl/base_service_impl.dart';
import 'package:topdeck_app_flutter/network/supabase_config.dart';

/// Service for managing Swiss pairing system
class SwissPairingServiceImpl extends BaseServiceImpl {
  @override
  String get tableName => 'tournament_matches';

  /// Generate Swiss system pairings for a tournament round
  Future<List<TournamentMatch>> generateSwissPairings({
    required String tournamentId,
    required int roundNumber,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$supabaseUrl/functions/v1/swiss-pairing-system/generate-pairings'),
        headers: {
          'Authorization': 'Bearer $supabaseAnonKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'tournament_id': tournamentId,
          'round_number': roundNumber,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final pairings = data['pairings'] as List;
        
        return pairings
            .map((pairing) => TournamentMatch.fromJson(pairing as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception('Failed to generate pairings: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error generating Swiss pairings: $e');
    }
  }

  /// Calculate recommended number of rounds for tournament
  Future<int> calculateTotalRounds(String tournamentId) async {
    try {
      final response = await http.post(
        Uri.parse('$supabaseUrl/functions/v1/swiss-pairing-system/calculate-rounds'),
        headers: {
          'Authorization': 'Bearer $supabaseAnonKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'tournament_id': tournamentId,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return data['recommended_rounds'] as int;
      } else {
        throw Exception('Failed to calculate rounds: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error calculating total rounds: $e');
    }
  }

  /// Advance tournament to next round by processing completed matches
  Future<bool> advanceToNextRound({
    required String tournamentId,
    required int completedRound,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$supabaseUrl/functions/v1/swiss-pairing-system/advance-round'),
        headers: {
          'Authorization': 'Bearer $supabaseAnonKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'tournament_id': tournamentId,
          'completed_round': completedRound,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return data['success'] as bool;
      } else {
        throw Exception('Failed to advance round: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error advancing to next round: $e');
    }
  }

  /// Get tournament standings with Swiss system calculations
  Future<List<Map<String, dynamic>>> getTournamentStandings(String tournamentId) async {
    try {
      final response = await http.get(
        Uri.parse('$supabaseUrl/functions/v1/swiss-pairing-system/standings?tournament_id=$tournamentId'),
        headers: {
          'Authorization': 'Bearer $supabaseAnonKey',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return List<Map<String, dynamic>>.from(data['standings']);
      } else {
        throw Exception('Failed to get standings: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error getting tournament standings: $e');
    }
  }

  /// Get current round pairings for a tournament
  Future<List<TournamentMatch>> getCurrentRoundPairings({
    required String tournamentId,
    required int round,
  }) async {
    final response = await client
        .from(tableName)
        .select()
        .eq('tournament_id', tournamentId)
        .eq('round', round)
        .order('table_number');

    return response
        .map((data) => TournamentMatch.fromJson(data as Map<String, dynamic>))
        .toList();
  }

  /// Get all matches for a tournament
  Future<List<TournamentMatch>> getTournamentMatches(String tournamentId) async {
    final response = await client
        .from(tableName)
        .select()
        .eq('tournament_id', tournamentId)
        .order('round')
        .order('table_number');

    return response
        .map((data) => TournamentMatch.fromJson(data as Map<String, dynamic>))
        .toList();
  }

  /// Update match result
  Future<TournamentMatch> updateMatchResult({
    required String matchId,
    required String winnerId,
    required String resultScore,
  }) async {
    final updateData = {
      'winner_id': winnerId,
      'result_score': resultScore,
      'match_status': 'finished',
      'finished_at': DateTime.now().toIso8601String(),
    };

    final response = await client
        .from(tableName)
        .update(updateData)
        .eq('id', matchId)
        .select()
        .single();

    return TournamentMatch.fromJson(response as Map<String, dynamic>);
  }

  /// Start a match (set status to in_progress)
  Future<TournamentMatch> startMatch(String matchId) async {
    final updateData = {
      'match_status': 'in_progress',
      'started_at': DateTime.now().toIso8601String(),
    };

    final response = await client
        .from(tableName)
        .update(updateData)
        .eq('id', matchId)
        .select()
        .single();

    return TournamentMatch.fromJson(response as Map<String, dynamic>);
  }

  /// Check if a round is complete (all matches finished)
  Future<bool> isRoundComplete({
    required String tournamentId,
    required int round,
  }) async {
    final response = await client
        .from(tableName)
        .select('match_status')
        .eq('tournament_id', tournamentId)
        .eq('round', round);

    if (response.isEmpty) return false;

    return response.every((match) => match['match_status'] == 'finished');
  }

  /// Get matches for a specific player in a tournament
  Future<List<TournamentMatch>> getPlayerMatches({
    required String tournamentId,
    required String playerId,
  }) async {
    final response = await client
        .from(tableName)
        .select()
        .eq('tournament_id', tournamentId)
        .or('player1_id.eq.$playerId,player2_id.eq.$playerId')
        .order('round');

    return response
        .map((data) => TournamentMatch.fromJson(data as Map<String, dynamic>))
        .toList();
  }

  /// Drop a player from the tournament
  Future<void> dropPlayer({
    required String tournamentId,
    required String playerId,
    required int currentRound,
  }) async {
    // Update participant status
    await client
        .from('tournament_participants')
        .update({
          'is_dropped': true,
          'dropped_round': currentRound,
        })
        .eq('tournament_id', tournamentId)
        .eq('user_id', playerId);

    // Cancel any pending matches for this player
    await client
        .from(tableName)
        .update({'match_status': 'cancelled'})
        .eq('tournament_id', tournamentId)
        .eq('match_status', 'pending')
        .or('player1_id.eq.$playerId,player2_id.eq.$playerId');
  }
} 