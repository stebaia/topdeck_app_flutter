import 'package:topdeck_app_flutter/model/entities/match.dart';
import 'package:topdeck_app_flutter/repositories/base_repository.dart';

/// Repository interface for Match entities
abstract class MatchRepository extends BaseRepository<Match> {
  /// Finds matches by player ID (either player1 or player2)
  Future<List<Match>> findByPlayerId(String playerId);
  
  /// Finds matches by format
  Future<List<Match>> findByFormat(String format);
  
  /// Finds matches by winner ID
  Future<List<Match>> findByWinnerId(String winnerId);
  
  /// Updates the winner of a match
  Future<Match> updateWinner(String matchId, String winnerId);
} 