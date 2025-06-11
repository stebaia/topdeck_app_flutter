import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../repositories/elo_repository.dart';
import '../../../model/entities/user_profile_extended.dart';
import 'elo_state.dart';

/// Cubit for ELO operations
class EloCubit extends Cubit<EloState> {
  final EloRepository _eloRepository;

  EloCubit({required EloRepository eloRepository})
      : _eloRepository = eloRepository,
        super(EloInitial());

  /// Load user profile with ELO statistics
  Future<void> loadUserProfile({
    required String userId,
    bool includeMatches = true,
    bool includeTournaments = true,
    int matchLimit = 50,
    int tournamentLimit = 50,
  }) async {
    try {
      emit(EloLoading());
      final profile = await _eloRepository.getUserProfileExtended(
        userId: userId,
        includeMatches: includeMatches,
        includeTournaments: includeTournaments,
        matchLimit: matchLimit,
        tournamentLimit: tournamentLimit,
      );
      emit(EloProfileLoaded(profile));
    } catch (e) {
      emit(EloError('Failed to load user profile: ${e.toString()}'));
    }
  }

  /// Load leaderboard
  Future<void> loadLeaderboard({
    String? format,
    int limit = 50,
    int page = 1,
    String? search,
    String? userId,
  }) async {
    try {
      emit(EloLoading());
      final leaderboard = await _eloRepository.getLeaderboard(
        format: format,
        limit: limit,
        page: page,
        search: search,
        userId: userId,
      );
      emit(EloLeaderboardLoaded(leaderboard));
    } catch (e) {
      emit(EloError('Failed to load leaderboard: ${e.toString()}'));
    }
  }

  /// Create a friendly match
  Future<void> createFriendlyMatch({
    required String player1Id,
    required String player2Id,
    required String winnerId,
    required String format,
    String? player1DeckId,
    String? player2DeckId,
  }) async {
    try {
      emit(EloLoading());
      final result = await _eloRepository.createFriendlyMatch(
        player1Id: player1Id,
        player2Id: player2Id,
        winnerId: winnerId,
        format: format,
        player1DeckId: player1DeckId,
        player2DeckId: player2DeckId,
      );
      emit(EloMatchCreated(result));
    } catch (e) {
      emit(EloError('Failed to create friendly match: ${e.toString()}'));
    }
  }

  /// Create a tournament match
  Future<void> createTournamentMatch({
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
    try {
      emit(EloLoading());
      final result = await _eloRepository.createTournamentMatch(
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
      emit(EloMatchCreated(result));
    } catch (e) {
      emit(EloError('Failed to create tournament match: ${e.toString()}'));
    }
  }

  /// Create a bye match
  Future<void> createByeMatch({
    required String playerId,
    required String format,
    required String tournamentId,
    int? round,
  }) async {
    try {
      emit(EloLoading());
      final result = await _eloRepository.createByeMatch(
        playerId: playerId,
        format: format,
        tournamentId: tournamentId,
        round: round,
      );
      emit(EloMatchCreated(result));
    } catch (e) {
      emit(EloError('Failed to create bye match: ${e.toString()}'));
    }
  }

  /// Complete a tournament and apply bonuses
  Future<void> completeTournament({
    required String tournamentId,
    required String format,
    required List<TournamentParticipation> finalRankings,
  }) async {
    try {
      emit(EloLoading());
      final result = await _eloRepository.completeTournament(
        tournamentId: tournamentId,
        format: format,
        finalRankings: finalRankings,
      );
      emit(EloTournamentCompleted(result));
    } catch (e) {
      emit(EloError('Failed to complete tournament: ${e.toString()}'));
    }
  }

  /// Load match history for a user
  Future<void> loadMatchHistory({
    required String userId,
    String? format,
    int limit = 50,
    int page = 1,
    bool tournamentOnly = false,
    bool friendlyOnly = false,
  }) async {
    try {
      emit(EloLoading());
      final history = await _eloRepository.getUserMatchHistory(
        userId: userId,
        format: format,
        limit: limit,
        page: page,
        tournamentOnly: tournamentOnly,
        friendlyOnly: friendlyOnly,
      );
      emit(EloMatchHistoryLoaded(history));
    } catch (e) {
      emit(EloError('Failed to load match history: ${e.toString()}'));
    }
  }

  /// Load user statistics
  Future<void> loadUserStatistics({
    required String userId,
    String? format,
    bool includeRanking = true,
  }) async {
    try {
      emit(EloLoading());
      final statistics = await _eloRepository.getUserStatistics(
        userId: userId,
        format: format,
        includeRanking: includeRanking,
      );
      emit(EloStatisticsLoaded(statistics));
    } catch (e) {
      emit(EloError('Failed to load user statistics: ${e.toString()}'));
    }
  }

  /// Search users
  Future<void> searchUsers({
    required String query,
    int limit = 20,
  }) async {
    try {
      emit(EloLoading());
      final results = await _eloRepository.searchUsers(
        query: query,
        limit: limit,
      );
      emit(EloLeaderboardLoaded(results));
    } catch (e) {
      emit(EloError('Failed to search users: ${e.toString()}'));
    }
  }

  /// Reset to initial state
  void reset() {
    emit(EloInitial());
  }
} 