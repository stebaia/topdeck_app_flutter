import '../../model/entities/user_profile_extended.dart';

/// Abstract ELO service interface
abstract class EloService {
  
  /// Create a friendly match between two players
  Future<Map<String, dynamic>> createFriendlyMatch({
    required String player1Id,
    required String player2Id,
    required String winnerId,
    required String format,
    String? player1DeckId,
    String? player2DeckId,
  });

  /// Create a tournament match
  Future<Map<String, dynamic>> createTournamentMatch({
    required String player1Id,
    String? player2Id,
    String? winnerId,
    required String format,
    required String tournamentId,
    String? player1DeckId,
    String? player2DeckId,
    int? round,
    bool isBye = false,
  });

  /// Create a bye match (tournament only)
  Future<Map<String, dynamic>> createByeMatch({
    required String playerId,
    required String format,
    required String tournamentId,
    int? round,
  });

  /// Complete tournament and apply bonuses
  Future<Map<String, dynamic>> completeTournament({
    required String tournamentId,
    required String format,
    required List<TournamentParticipation> finalRankings,
  });

  /// Get comprehensive user profile with ELO statistics
  Future<UserProfileExtended> getUserProfileExtended({
    required String userId,
    bool includeMatches = true,
    bool includeTournaments = true,
    int matchLimit = 50,
    int tournamentLimit = 50,
  });

  /// Get leaderboard
  Future<Map<String, dynamic>> getLeaderboard({
    String? format,
    int limit = 50,
    int page = 1,
    String? search,
    String? userId,
  });

  /// Get match history for a user
  Future<Map<String, dynamic>> getUserMatchHistory({
    required String userId,
    String? format,
    int limit = 50,
    int page = 1,
    bool tournamentOnly = false,
    bool friendlyOnly = false,
  });

  /// Get user statistics
  Future<Map<String, dynamic>> getUserStatistics({
    required String userId,
    String? format,
    bool includeRanking = true,
  });
} 