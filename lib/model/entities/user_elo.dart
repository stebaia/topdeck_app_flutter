import 'dart:math';
import 'package:json_annotation/json_annotation.dart';
import 'package:uuid/uuid.dart';
import '../base_model.dart';

part 'user_elo.g.dart';

/// UserElo model representing user ELO ratings per format in the Supabase user_elo table
@JsonSerializable()
class UserElo extends BaseModel {
  /// User ID that this ELO belongs to
  @JsonKey(name: 'user_id')
  final String userId;
  
  /// Game format (Advanced, Edison, GOAT, etc.)
  final String format;
  
  /// Current ELO rating
  final int elo;
  
  /// Total matches played in this format
  @JsonKey(name: 'matches_played')
  final int matchesPlayed;
  
  /// Total wins in this format
  final int wins;
  
  /// Total losses in this format
  final int losses;
  
  /// Total draws in this format
  final int draws;
  
  /// Win rate percentage (0.0 to 1.0)
  @JsonKey(name: 'win_rate')
  final double winRate;
  
  /// Highest ELO ever achieved in this format
  @JsonKey(name: 'peak_elo')
  final int peakElo;
  
  /// Date of the last match in this format
  @JsonKey(name: 'last_match_date')
  final DateTime? lastMatchDate;
  
  /// Timestamp when this record was created
  @JsonKey(name: 'created_at')
  final DateTime? createdAt;
  
  /// Timestamp when this record was last updated
  @JsonKey(name: 'updated_at')
  final DateTime? updatedAt;

  /// Constructor
  const UserElo({
    required super.id,
    required this.userId,
    required this.format,
    required this.elo,
    required this.matchesPlayed,
    required this.wins,
    required this.losses,
    required this.draws,
    required this.winRate,
    required this.peakElo,
    this.lastMatchDate,
    this.createdAt,
    this.updatedAt,
  });

  /// Creates a new UserElo instance with a generated UUID
  factory UserElo.create({
    required String userId,
    required String format,
    int elo = 1200, // Starting ELO
  }) {
    return UserElo(
      id: const Uuid().v4(),
      userId: userId,
      format: format,
      elo: elo,
      matchesPlayed: 0,
      wins: 0,
      losses: 0,
      draws: 0,
      winRate: 0.0,
      peakElo: elo,
      lastMatchDate: null,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  /// Creates a UserElo from JSON
  factory UserElo.fromJson(Map<String, dynamic> json) => _$UserEloFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$UserEloToJson(this);

  @override
  UserElo copyWith({
    String? id,
    String? userId,
    String? format,
    int? elo,
    int? matchesPlayed,
    int? wins,
    int? losses,
    int? draws,
    double? winRate,
    int? peakElo,
    DateTime? lastMatchDate,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserElo(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      format: format ?? this.format,
      elo: elo ?? this.elo,
      matchesPlayed: matchesPlayed ?? this.matchesPlayed,
      wins: wins ?? this.wins,
      losses: losses ?? this.losses,
      draws: draws ?? this.draws,
      winRate: winRate ?? this.winRate,
      peakElo: peakElo ?? this.peakElo,
      lastMatchDate: lastMatchDate ?? this.lastMatchDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
  
  /// Check if user is in calibration period (first 30 matches)
  bool get isInCalibration => matchesPlayed < 30;
  
  /// Calculate current win rate
  double get currentWinRate {
    if (matchesPlayed == 0) return 0.0;
    return wins / matchesPlayed;
  }
  
  /// Get total games (excludes draws for some calculations)
  int get totalDecidedGames => wins + losses;
  
  /// Calculate ELO change using standard ELO formula
  /// Returns the new ELO value
  int calculateEloChange({
    required int opponentElo,
    required double score, // 1.0 for win, 0.5 for draw, 0.0 for loss
    required int kFactor,
  }) {
    // Expected score formula: E = 1 / (1 + 10^((opponent_elo - player_elo) / 400))
    final double expectedScore = 1 / (1 + pow(10, (opponentElo - elo) / 400));
    
    // ELO change formula: ΔR = K × (S - E)
    final double eloChange = kFactor * (score - expectedScore);
    
    return elo + eloChange.round();
  }
  
  /// Get the appropriate K-factor based on match type and number of games played
  int getKFactor({
    required bool isTournamentMatch,
    required bool isFriendlyMatch,
  }) {
    // K = 40 for first 30 matches (calibration)
    if (matchesPlayed < 30) {
      return 40;
    }
    
    // K = 20 for tournament matches
    if (isTournamentMatch && !isFriendlyMatch) {
      return 20;
    }
    
    // K = 10 for friendly matches
    if (isFriendlyMatch) {
      return 10;
    }
    
    // Default K = 20 for other matches
    return 20;
  }
  
  /// Update stats after a match
  UserElo updateAfterMatch({
    required int opponentElo,
    required double score, // 1.0 for win, 0.5 for draw, 0.0 for loss
    required bool isTournamentMatch,
    required bool isFriendlyMatch,
    required bool isBye, // Bye matches don't affect ELO
  }) {
    if (isBye) {
      // Bye matches only update win count for tournament standings, not ELO
      return copyWith(
        wins: wins + 1,
        matchesPlayed: matchesPlayed + 1,
        winRate: (wins + 1) / (matchesPlayed + 1),
        lastMatchDate: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    }
    
    final int kFactor = getKFactor(
      isTournamentMatch: isTournamentMatch,
      isFriendlyMatch: isFriendlyMatch,
    );
    
    final int newElo = calculateEloChange(
      opponentElo: opponentElo,
      score: score,
      kFactor: kFactor,
    );
    
    final int newWins = score == 1.0 ? wins + 1 : wins;
    final int newLosses = score == 0.0 ? losses + 1 : losses;
    final int newDraws = score == 0.5 ? draws + 1 : draws;
    final int newMatchesPlayed = matchesPlayed + 1;
    final double newWinRate = newWins / newMatchesPlayed;
    final int newPeakElo = newElo > peakElo ? newElo : peakElo;
    
    return copyWith(
      elo: newElo,
      matchesPlayed: newMatchesPlayed,
      wins: newWins,
      losses: newLosses,
      draws: newDraws,
      winRate: newWinRate,
      peakElo: newPeakElo,
      lastMatchDate: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }
  
  /// Apply tournament bonus (+50 for winner, +25 for top 4)
  UserElo applyTournamentBonus({
    required bool isWinner,
    required bool isTop4,
  }) {
    int bonus = 0;
    if (isWinner) {
      bonus = 50;
    } else if (isTop4) {
      bonus = 25;
    }
    
    if (bonus > 0) {
      final int newElo = elo + bonus;
      final int newPeakElo = newElo > peakElo ? newElo : peakElo;
      
      return copyWith(
        elo: newElo,
        peakElo: newPeakElo,
        updatedAt: DateTime.now(),
      );
    }
    
    return this;
  }
} 