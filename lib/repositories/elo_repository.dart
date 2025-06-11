import '../model/entities/user_elo.dart';
import '../model/entities/match_extended.dart';
import '../model/entities/user_profile_extended.dart';
import '../network/service/elo_service.dart';

/// Repository for ELO-related operations using Edge Functions
/// All ELO logic is now handled server-side for security and integrity
class EloRepository {
  final EloService _eloService;

  EloRepository({required EloService eloService})
      : _eloService = eloService;

  /// Create a friendly match between two players
  Future<Map<String, dynamic>> createFriendlyMatch({
    required String player1Id,
    required String player2Id,
    required String winnerId,
    required String format,
    String? player1DeckId,
    String? player2DeckId,
  }) async {
    return _eloService.createFriendlyMatch(
      player1Id: player1Id,
      player2Id: player2Id,
      winnerId: winnerId,
      format: format,
      player1DeckId: player1DeckId,
      player2DeckId: player2DeckId,
    );
  }

  /// Create a tournament match
  Future<Map<String, dynamic>> createTournamentMatch({
    required String player1Id,
    String? player2Id, // null for bye
    String? winnerId,
    required String format,
    required String tournamentId,
    String? player1DeckId,
    String? player2DeckId,
    int? round,
    bool isBye = false,
  }) async {
    return _eloService.createTournamentMatch(
      player1Id: player1Id,
      player2Id: player2Id,
      winnerId: winnerId,
      format: format,
      tournamentId: tournamentId,
      player1DeckId: player1DeckId,
      player2DeckId: player2DeckId,
      round: round,
      isBye: isBye,
    );
  }

  /// Create a bye match (tournament only)
  Future<Map<String, dynamic>> createByeMatch({
    required String playerId,
    required String format,
    required String tournamentId,
    int? round,
  }) async {
    return _eloService.createByeMatch(
      playerId: playerId,
      format: format,
      tournamentId: tournamentId,
      round: round,
    );
  }

  /// Complete tournament and apply bonuses
  Future<Map<String, dynamic>> completeTournament({
    required String tournamentId,
    required String format,
    required List<TournamentParticipation> finalRankings,
  }) async {
    return _eloService.completeTournament(
      tournamentId: tournamentId,
      format: format,
      finalRankings: finalRankings,
    );
  }

  /// Get comprehensive user profile with ELO statistics
  Future<UserProfileExtended> getUserProfileExtended({
    required String userId,
    bool includeMatches = true,
    bool includeTournaments = true,
    int matchLimit = 50,
    int tournamentLimit = 50,
  }) async {
    return _eloService.getUserProfileExtended(
      userId: userId,
      includeMatches: includeMatches,
      includeTournaments: includeTournaments,
      matchLimit: matchLimit,
      tournamentLimit: tournamentLimit,
    );
  }

  /// Get leaderboard
  Future<Map<String, dynamic>> getLeaderboard({
    String? format,
    int limit = 50,
    int page = 1,
    String? search,
    String? userId,
  }) async {
    return _eloService.getLeaderboard(
      format: format,
      limit: limit,
      page: page,
      search: search,
      userId: userId,
    );
  }

  /// Get top players by format (convenience method for leaderboard)
  Future<List<Map<String, dynamic>>> getTopPlayersByFormat({
    required String format,
    int limit = 100,
  }) async {
    final result = await _eloService.getLeaderboard(
      format: format,
      limit: limit,
    );
    return List<Map<String, dynamic>>.from(result['leaderboard'] ?? []);
  }

  /// Get user's rank in a specific format
  Future<int> getUserRank({
    required String userId,
    required String format,
  }) async {
    final result = await _eloService.getLeaderboard(
      format: format,
      userId: userId,
      limit: 1, // We only need the rank
    );
    return result['user_rank'] ?? 0;
  }

  /// Get match history for a user
  Future<Map<String, dynamic>> getUserMatchHistory({
    required String userId,
    String? format,
    int limit = 50,
    int page = 1,
    bool tournamentOnly = false,
    bool friendlyOnly = false,
  }) async {
    return _eloService.getUserMatchHistory(
      userId: userId,
      format: format,
      limit: limit,
      page: page,
      tournamentOnly: tournamentOnly,
      friendlyOnly: friendlyOnly,
    );
  }

  /// Get user statistics
  Future<Map<String, dynamic>> getUserStatistics({
    required String userId,
    String? format,
    bool includeRanking = true,
  }) async {
    return _eloService.getUserStatistics(
      userId: userId,
      format: format,
      includeRanking: includeRanking,
    );
  }

  /// Get global leaderboard for all formats
  Future<Map<String, dynamic>> getGlobalLeaderboard({
    int limit = 50,
  }) async {
    return _eloService.getLeaderboard(limit: limit);
  }

  /// Search users by username with ELO information
  Future<Map<String, dynamic>> searchUsers({
    required String query,
    int limit = 20,
  }) async {
    return _eloService.getLeaderboard(
      search: query,
      limit: limit,
    );
  }

  /// Get ELO record for a user in a specific format (from user profile)
  Future<UserElo?> getUserElo({
    required String userId,
    required String format,
  }) async {
    try {
      final profile = await getUserProfileExtended(
        userId: userId,
        includeMatches: false,
        includeTournaments: false,
      );
      return profile.eloRatings[format];
    } catch (e) {
      return null;
    }
  }

  /// Get all ELO records for a user across all formats
  Future<List<UserElo>> getUserEloAllFormats(String userId) async {
    try {
      final profile = await getUserProfileExtended(
        userId: userId,
        includeMatches: false,
        includeTournaments: false,
      );
      return profile.eloRatings.values.toList();
    } catch (e) {
      return [];
    }
  }

  /// Get match statistics for a user in a specific format
  Future<Map<String, dynamic>> getUserMatchStats({
    required String userId,
    required String format,
  }) async {
    final stats = await getUserStatistics(
      userId: userId,
      format: format,
    );
    return stats['match_statistics'] ?? {};
  }

  /// Get tournament history for a user
  Future<List<TournamentParticipation>> getUserTournamentHistory({
    required String userId,
    String? format,
    int limit = 50,
  }) async {
    try {
      final profile = await getUserProfileExtended(
        userId: userId,
        includeMatches: false,
        includeTournaments: true,
        tournamentLimit: limit,
      );
      
      if (format != null) {
        return profile.tournamentHistory
            .where((t) => t.format == format)
            .toList();
      }
      
      return profile.tournamentHistory;
    } catch (e) {
      return [];
    }
  }

  // Deprecated methods - maintained for backward compatibility
  
  /// @deprecated Use createFriendlyMatch or createTournamentMatch instead
  @Deprecated('Use createFriendlyMatch or createTournamentMatch instead')
  Future<MatchExtended> saveMatch(MatchExtended match) async {
    throw UnsupportedError(
      'saveMatch is deprecated. Use createFriendlyMatch or createTournamentMatch instead.',
    );
  }

  /// @deprecated Use completeTournament instead
  @Deprecated('Use completeTournament instead')
  Future<void> saveTournamentResult({
    required String tournamentId,
    required String userId,
    required int finalPosition,
    required int totalParticipants,
    required int points,
    required bool isWinner,
    required bool isTop4,
    required int eloBonus,
    String? deckId,
  }) async {
    throw UnsupportedError(
      'saveTournamentResult is deprecated. Use completeTournament instead.',
    );
  }

  /// @deprecated Direct ELO updates are now handled by edge functions
  @Deprecated('Direct ELO updates are not allowed. Use match creation methods instead.')
  Future<UserElo> upsertUserElo(UserElo userElo) async {
    throw UnsupportedError(
      'Direct ELO updates are not allowed. Use match creation methods instead.',
    );
  }
} 