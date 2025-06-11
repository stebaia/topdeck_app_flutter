import '../elo_service.dart';
import '../../../services/elo_edge_service.dart';
import '../../../model/entities/user_profile_extended.dart';
import '../../../network/supabase_config.dart' as config;

/// Implementation of ELO service using Supabase Edge Functions
class EloServiceImpl implements EloService {
  final EloEdgeService _eloEdgeService;

  EloServiceImpl({
    String? supabaseUrl,
    String? supabaseAnonKey,
  }) : _eloEdgeService = EloEdgeService(
          supabaseUrl: supabaseUrl ?? config.supabaseUrl,
          supabaseAnonKey: supabaseAnonKey ?? config.supabaseAnonKey,
        );

  @override
  Future<Map<String, dynamic>> createFriendlyMatch({
    required String player1Id,
    required String player2Id,
    required String winnerId,
    required String format,
    String? player1DeckId,
    String? player2DeckId,
  }) async {
    return _eloEdgeService.createFriendlyMatch(
      player1Id: player1Id,
      player2Id: player2Id,
      winnerId: winnerId,
      format: format,
      player1DeckId: player1DeckId,
      player2DeckId: player2DeckId,
    );
  }

  @override
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
  }) async {
    return _eloEdgeService.createTournamentMatch(
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

  @override
  Future<Map<String, dynamic>> createByeMatch({
    required String playerId,
    required String format,
    required String tournamentId,
    int? round,
  }) async {
    return _eloEdgeService.createTournamentMatch(
      player1Id: playerId,
      player2Id: null,
      winnerId: playerId,
      format: format,
      tournamentId: tournamentId,
      isBye: true,
      round: round,
    );
  }

  @override
  Future<Map<String, dynamic>> completeTournament({
    required String tournamentId,
    required String format,
    required List<TournamentParticipation> finalRankings,
  }) async {
    return _eloEdgeService.completeTournament(
      tournamentId: tournamentId,
      format: format,
      finalRankings: finalRankings,
    );
  }

  @override
  Future<UserProfileExtended> getUserProfileExtended({
    required String userId,
    bool includeMatches = true,
    bool includeTournaments = true,
    int matchLimit = 50,
    int tournamentLimit = 50,
  }) async {
    return _eloEdgeService.getUserProfileExtended(
      userId: userId,
      includeMatches: includeMatches,
      includeTournaments: includeTournaments,
      matchLimit: matchLimit,
      tournamentLimit: tournamentLimit,
    );
  }

  @override
  Future<Map<String, dynamic>> getLeaderboard({
    String? format,
    int limit = 50,
    int page = 1,
    String? search,
    String? userId,
  }) async {
    return _eloEdgeService.getLeaderboard(
      format: format,
      limit: limit,
      page: page,
      search: search,
      userId: userId,
    );
  }

  @override
  Future<Map<String, dynamic>> getUserMatchHistory({
    required String userId,
    String? format,
    int limit = 50,
    int page = 1,
    bool tournamentOnly = false,
    bool friendlyOnly = false,
  }) async {
    return _eloEdgeService.getMatchHistory(
      userId: userId,
      format: format,
      limit: limit,
      page: page,
      tournamentOnly: tournamentOnly,
      friendlyOnly: friendlyOnly,
    );
  }

  @override
  Future<Map<String, dynamic>> getUserStatistics({
    required String userId,
    String? format,
    bool includeRanking = true,
  }) async {
    return _eloEdgeService.getUserStatistics(
      userId: userId,
      format: format,
      includeRanking: includeRanking,
    );
  }
} 