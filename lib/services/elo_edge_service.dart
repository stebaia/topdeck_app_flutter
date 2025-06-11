import 'dart:convert';
import 'package:http/http.dart' as http;
import '../model/entities/user_elo.dart';
import '../model/entities/match_extended.dart';
import '../model/entities/user_profile_extended.dart';

/// Service that communicates with Supabase Edge Functions for ELO management
class EloEdgeService {
  final String _baseUrl;
  final String _apiKey;

  EloEdgeService({
    required String supabaseUrl,
    required String supabaseAnonKey,
  })  : _baseUrl = '$supabaseUrl/functions/v1',
        _apiKey = supabaseAnonKey;

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $_apiKey',
      };

  /// Update ELO after a match
  Future<Map<String, dynamic>> updateEloAfterMatch({
    required String player1Id,
    String? player2Id,
    String? winnerId,
    required String format,
    String? tournamentId,
    bool isFriendly = false,
    bool isBye = false,
    String? player1DeckId,
    String? player2DeckId,
    int? round,
  }) async {
    final url = Uri.parse('$_baseUrl/update-elo-after-match');
    
    final body = {
      'player1_id': player1Id,
      if (player2Id != null) 'player2_id': player2Id,
      if (winnerId != null) 'winner_id': winnerId,
      'format': format,
      if (tournamentId != null) 'tournament_id': tournamentId,
      'is_friendly': isFriendly,
      'is_bye': isBye,
      if (player1DeckId != null) 'player1_deck_id': player1DeckId,
      if (player2DeckId != null) 'player2_deck_id': player2DeckId,
      if (round != null) 'round': round,
    };

    final response = await http.post(
      url,
      headers: _headers,
      body: json.encode(body),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update ELO: ${response.body}');
    }

    return json.decode(response.body);
  }

  /// Apply tournament bonuses
  Future<Map<String, dynamic>> applyTournamentBonuses({
    required String tournamentId,
    required String format,
    required List<Map<String, dynamic>> finalRankings,
  }) async {
    final url = Uri.parse('$_baseUrl/apply-tournament-bonuses');
    
    final body = {
      'tournament_id': tournamentId,
      'format': format,
      'final_rankings': finalRankings,
    };

    final response = await http.post(
      url,
      headers: _headers,
      body: json.encode(body),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to apply tournament bonuses: ${response.body}');
    }

    return json.decode(response.body);
  }

  /// Get extended user profile with ELO statistics
  Future<UserProfileExtended> getUserProfileExtended({
    required String userId,
    bool includeMatches = true,
    bool includeTournaments = true,
    int matchLimit = 50,
    int tournamentLimit = 50,
  }) async {
    final url = Uri.parse('$_baseUrl/get-user-profile-extended').replace(
      queryParameters: {
        'user_id': userId,
        'include_matches': includeMatches.toString(),
        'include_tournaments': includeTournaments.toString(),
        'match_limit': matchLimit.toString(),
        'tournament_limit': tournamentLimit.toString(),
      },
    );

    final response = await http.get(url, headers: _headers);

    if (response.statusCode != 200) {
      throw Exception('Failed to get user profile: ${response.body}');
    }

    final responseData = json.decode(response.body);
    if (!responseData['success']) {
      throw Exception('API error: ${responseData['error']}');
    }

    final data = responseData['data'];
    
    // Convert ELO ratings map
    final Map<String, UserElo> eloRatings = {};
    final eloRatingsData = data['elo_ratings'] as Map<String, dynamic>;
    for (final entry in eloRatingsData.entries) {
      eloRatings[entry.key] = UserElo(
        id: '', // Will be set from actual database if needed
        userId: userId,
        format: entry.key,
        elo: entry.value['elo'],
        matchesPlayed: entry.value['matches_played'],
        wins: entry.value['wins'],
        losses: entry.value['losses'],
        draws: entry.value['draws'],
        winRate: entry.value['win_rate'].toDouble(),
        peakElo: entry.value['peak_elo'],
        lastMatchDate: entry.value['last_match_date'] != null 
          ? DateTime.parse(entry.value['last_match_date'])
          : null,
      );
    }

    // Convert match history
    final List<MatchExtended> matchHistory = [];
    final matchHistoryData = data['match_history'] as List<dynamic>;
    for (final match in matchHistoryData) {
      matchHistory.add(MatchExtended(
        id: match['id'],
        player1Id: match['player1_id'],
        player2Id: match['player2_id'],
        winnerId: match['winner_id'],
        format: match['format'],
        date: match['date'] != null ? DateTime.parse(match['date']) : null,
        tournamentId: match['tournament_id'],
        isFriendly: match['is_friendly'] ?? false,
        isBye: match['is_bye'] ?? false,
        player1EloBefore: match['player1_elo_before'],
        player2EloBefore: match['player2_elo_before'],
        player1EloAfter: match['player1_elo_after'],
        player2EloAfter: match['player2_elo_after'],
        player1EloChange: match['player1_elo_change'],
        player2EloChange: match['player2_elo_change'],
        round: match['round'],
      ));
    }

    // Convert tournament history
    final List<TournamentParticipation> tournamentHistory = [];
    final tournamentHistoryData = data['tournament_history'] as List<dynamic>;
    for (final tournament in tournamentHistoryData) {
      tournamentHistory.add(TournamentParticipation(
        tournamentId: tournament['tournament_id'],
        userId: userId,
        tournamentName: tournament['tournament']['name'],
        format: tournament['tournament']['format'],
        position: tournament['final_position'],
        totalParticipants: tournament['total_participants'],
        date: DateTime.parse(tournament['tournament']['created_at']),
        isWinner: tournament['is_winner'],
        isTop4: tournament['is_top4'],
        points: tournament['points'],
        deckId: tournament['deck_id'],
      ));
    }

    // Convert overall stats
    final statsData = data['overall_stats'];
    final overallStats = UserStatistics(
      totalMatches: statsData['total_matches'],
      totalWins: statsData['total_wins'],
      totalLosses: statsData['total_losses'],
      totalDraws: statsData['total_draws'],
      totalTournaments: statsData['total_tournaments'],
      tournamentWins: statsData['tournament_wins'],
      top4Finishes: statsData['top4_finishes'],
      favoriteFormat: statsData['favorite_format'],
      bestFormat: statsData['best_format'],
      peakElo: statsData['peak_elo'],
      peakEloDate: statsData['peak_elo_date'] != null 
        ? DateTime.parse(statsData['peak_elo_date'])
        : null,
    );

    return UserProfileExtended(
      userId: userId,
      username: data['username'],
      nome: data['nome'],
      cognome: data['cognome'],
      avatarUrl: data['avatar_url'],
      eloRatings: eloRatings,
      matchHistory: matchHistory,
      tournamentHistory: tournamentHistory,
      decks: [], // TODO: Add decks conversion if needed
      overallStats: overallStats,
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
    final queryParams = <String, String>{
      'limit': limit.toString(),
      'page': page.toString(),
    };
    
    if (format != null) queryParams['format'] = format;
    if (search != null) queryParams['search'] = search;
    if (userId != null) queryParams['user_id'] = userId;

    final url = Uri.parse('$_baseUrl/get-leaderboard').replace(
      queryParameters: queryParams,
    );

    final response = await http.get(url, headers: _headers);

    if (response.statusCode != 200) {
      throw Exception('Failed to get leaderboard: ${response.body}');
    }

    final responseData = json.decode(response.body);
    if (!responseData['success']) {
      throw Exception('API error: ${responseData['error']}');
    }

    return responseData['data'];
  }

  /// Get match history
  Future<Map<String, dynamic>> getMatchHistory({
    required String userId,
    String? format,
    int limit = 50,
    int page = 1,
    bool tournamentOnly = false,
    bool friendlyOnly = false,
  }) async {
    final queryParams = <String, String>{
      'user_id': userId,
      'limit': limit.toString(),
      'page': page.toString(),
      'tournament_only': tournamentOnly.toString(),
      'friendly_only': friendlyOnly.toString(),
    };
    
    if (format != null) queryParams['format'] = format;

    final url = Uri.parse('$_baseUrl/get-match-history').replace(
      queryParameters: queryParams,
    );

    final response = await http.get(url, headers: _headers);

    if (response.statusCode != 200) {
      throw Exception('Failed to get match history: ${response.body}');
    }

    final responseData = json.decode(response.body);
    if (!responseData['success']) {
      throw Exception('API error: ${responseData['error']}');
    }

    return responseData['data'];
  }

  /// Get user statistics
  Future<Map<String, dynamic>> getUserStatistics({
    required String userId,
    String? format,
    bool includeRanking = true,
  }) async {
    final queryParams = <String, String>{
      'user_id': userId,
      'include_ranking': includeRanking.toString(),
    };
    
    if (format != null) queryParams['format'] = format;

    final url = Uri.parse('$_baseUrl/get-user-statistics').replace(
      queryParameters: queryParams,
    );

    final response = await http.get(url, headers: _headers);

    if (response.statusCode != 200) {
      throw Exception('Failed to get user statistics: ${response.body}');
    }

    final responseData = json.decode(response.body);
    if (!responseData['success']) {
      throw Exception('API error: ${responseData['error']}');
    }

    return responseData['data'];
  }

  /// Create a friendly match
  Future<Map<String, dynamic>> createFriendlyMatch({
    required String player1Id,
    required String player2Id,
    required String winnerId,
    required String format,
    String? player1DeckId,
    String? player2DeckId,
  }) async {
    return updateEloAfterMatch(
      player1Id: player1Id,
      player2Id: player2Id,
      winnerId: winnerId,
      format: format,
      isFriendly: true,
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
    return updateEloAfterMatch(
      player1Id: player1Id,
      player2Id: player2Id,
      winnerId: winnerId,
      format: format,
      tournamentId: tournamentId,
      isFriendly: false,
      isBye: isBye,
      player1DeckId: player1DeckId,
      player2DeckId: player2DeckId,
      round: round,
    );
  }

  /// Complete a tournament and apply bonuses
  Future<Map<String, dynamic>> completeTournament({
    required String tournamentId,
    required String format,
    required List<TournamentParticipation> finalRankings,
  }) async {
    final rankingsData = finalRankings.map((participation) => {
      'user_id': participation.userId,
      'position': participation.position,
      'points': participation.points,
      if (participation.deckId != null) 'deck_id': participation.deckId,
    }).toList();

    return applyTournamentBonuses(
      tournamentId: tournamentId,
      format: format,
      finalRankings: rankingsData,
    );
  }
} 