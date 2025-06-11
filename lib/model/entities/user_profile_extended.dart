import 'user_elo.dart';
import 'match_extended.dart';
import 'deck.dart';

/// Extended user profile with ELO statistics and match history
/// This is a composite model that combines data from multiple sources
class UserProfileExtended {
  /// User ID
  final String userId;
  
  /// Username/Nickname
  final String username;
  
  /// First name
  final String nome;
  
  /// Last name
  final String cognome;
  
  /// Avatar URL
  final String? avatarUrl;
  
  /// ELO ratings for each format
  final Map<String, UserElo> eloRatings;
  
  /// Match history (most recent first)
  final List<MatchExtended> matchHistory;
  
  /// Tournament history
  final List<TournamentParticipation> tournamentHistory;
  
  /// User's decklists
  final List<Deck> decks;
  
  /// Overall statistics
  final UserStatistics overallStats;

  const UserProfileExtended({
    required this.userId,
    required this.username,
    required this.nome,
    required this.cognome,
    this.avatarUrl,
    required this.eloRatings,
    required this.matchHistory,
    required this.tournamentHistory,
    required this.decks,
    required this.overallStats,
  });

  /// Get ELO for a specific format
  int getEloForFormat(String format) {
    return eloRatings[format]?.elo ?? 1200;
  }
  
  /// Get win rate for a specific format
  double getWinRateForFormat(String format) {
    return eloRatings[format]?.winRate ?? 0.0;
  }
  
  /// Get overall win rate across all formats
  double getOverallWinRate() {
    if (overallStats.totalMatches == 0) return 0.0;
    return overallStats.totalWins / overallStats.totalMatches;
  }
  
  /// Get matches for a specific format
  List<MatchExtended> getMatchesForFormat(String format) {
    return matchHistory.where((match) => match.format == format).toList();
  }
  
  /// Get tournaments for a specific format
  List<TournamentParticipation> getTournamentsForFormat(String format) {
    return tournamentHistory.where((tournament) => tournament.format == format).toList();
  }
  
  /// Check if user has played in a specific format
  bool hasPlayedFormat(String format) {
    return eloRatings.containsKey(format);
  }
  
  /// Get all formats the user has played
  List<String> getPlayedFormats() {
    return eloRatings.keys.toList();
  }
}

/// Tournament participation record
/// This is a simple data class, not a database entity
class TournamentParticipation {
  /// Tournament ID
  final String tournamentId;
  
  /// User ID (participant)
  final String userId;
  
  /// Tournament name
  final String tournamentName;
  
  /// Tournament format
  final String format;
  
  /// User's final position (1st, 2nd, etc.)
  final int position;
  
  /// Total participants in the tournament
  final int totalParticipants;
  
  /// Tournament date
  final DateTime date;
  
  /// Whether the user won the tournament
  final bool isWinner;
  
  /// Whether the user reached top 4
  final bool isTop4;
  
  /// Points scored in the tournament
  final int points;
  
  /// Deck used in the tournament
  final String? deckId;

  const TournamentParticipation({
    required this.tournamentId,
    required this.userId,
    required this.tournamentName,
    required this.format,
    required this.position,
    required this.totalParticipants,
    required this.date,
    required this.isWinner,
    required this.isTop4,
    required this.points,
    this.deckId,
  });
  
  /// Get position suffix (1st, 2nd, 3rd, 4th, etc.)
  String get positionString {
    if (position == 1) return '1st';
    if (position == 2) return '2nd';
    if (position == 3) return '3rd';
    return '${position}th';
  }
}

/// Overall user statistics
/// This is a simple data class, not a database entity
class UserStatistics {
  /// Total matches played across all formats
  final int totalMatches;
  
  /// Total wins across all formats
  final int totalWins;
  
  /// Total losses across all formats
  final int totalLosses;
  
  /// Total draws across all formats
  final int totalDraws;
  
  /// Total tournaments participated
  final int totalTournaments;
  
  /// Tournament wins
  final int tournamentWins;
  
  /// Top 4 finishes
  final int top4Finishes;
  
  /// Favorite format (most played)
  final String? favoriteFormat;
  
  /// Best format (highest ELO)
  final String? bestFormat;
  
  /// Highest ELO ever achieved (across all formats)
  final int peakElo;
  
  /// Date when peak ELO was achieved
  final DateTime? peakEloDate;

  const UserStatistics({
    required this.totalMatches,
    required this.totalWins,
    required this.totalLosses,
    required this.totalDraws,
    required this.totalTournaments,
    required this.tournamentWins,
    required this.top4Finishes,
    this.favoriteFormat,
    this.bestFormat,
    required this.peakElo,
    this.peakEloDate,
  });
  
  /// Calculate overall win rate
  double get winRate {
    if (totalMatches == 0) return 0.0;
    return totalWins / totalMatches;
  }
  
  /// Calculate tournament win rate
  double get tournamentWinRate {
    if (totalTournaments == 0) return 0.0;
    return tournamentWins / totalTournaments;
  }
  
  /// Calculate top 4 rate in tournaments
  double get top4Rate {
    if (totalTournaments == 0) return 0.0;
    return top4Finishes / totalTournaments;
  }
} 