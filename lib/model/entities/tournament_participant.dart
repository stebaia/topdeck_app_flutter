import 'package:json_annotation/json_annotation.dart';
import 'package:uuid/uuid.dart';
import '../base_model.dart';

part 'tournament_participant.g.dart';

/// Tournament participant model representing a user's participation in a tournament
@JsonSerializable()
class TournamentParticipant extends BaseModel {
  /// The ID of the tournament
  @JsonKey(name: 'tournament_id')
  final String tournamentId;
  
  /// The ID of the user who joined
  @JsonKey(name: 'user_id')
  final String userId;

  /// The ID of the deck being used (optional)
  @JsonKey(name: 'deck_id')
  final String? deckId;

  /// The points accumulated by the participant
  final int? points;

  /// Number of matches won
  @JsonKey(name: 'match_wins')
  final int matchWins;

  /// Number of matches lost
  @JsonKey(name: 'match_losses')
  final int matchLosses;

  /// Number of matches drawn
  @JsonKey(name: 'match_draws')
  final int matchDraws;

  /// Total number of games won
  @JsonKey(name: 'game_wins')
  final int gameWins;

  /// Total number of games lost
  @JsonKey(name: 'game_losses')
  final int gameLosses;

  /// List of opponent IDs already faced
  @JsonKey(name: 'opponents_faced')
  final List<String> opponentsFaced;

  /// Whether the player has dropped from the tournament
  @JsonKey(name: 'is_dropped')
  final bool isDropped;

  /// Round number when the player dropped
  @JsonKey(name: 'dropped_round')
  final int? droppedRound;
  
  /// When the user joined the tournament
  @JsonKey(name: 'joined_at')
  final DateTime? joinedAt;

  /// Constructor
  const TournamentParticipant({
    required super.id,
    required this.tournamentId,
    required this.userId,
    this.deckId,
    this.points,
    this.matchWins = 0,
    this.matchLosses = 0,
    this.matchDraws = 0,
    this.gameWins = 0,
    this.gameLosses = 0,
    this.opponentsFaced = const [],
    this.isDropped = false,
    this.droppedRound,
    this.joinedAt,
  });

  /// Creates a new TournamentParticipant instance with a generated UUID
  factory TournamentParticipant.create({
    required String tournamentId,
    required String userId,
    String? deckId,
  }) {
    return TournamentParticipant(
      id: const Uuid().v4(),
      tournamentId: tournamentId,
      userId: userId,
      deckId: deckId,
      joinedAt: DateTime.now(),
    );
  }

  /// Creates a tournament participant from JSON
  factory TournamentParticipant.fromJson(Map<String, dynamic> json) => 
      _$TournamentParticipantFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$TournamentParticipantToJson(this);

  /// Calculate match win percentage
  double get matchWinPercentage {
    final totalMatches = matchWins + matchLosses + matchDraws;
    if (totalMatches == 0) return 0.0;
    return (matchWins + (matchDraws * 0.5)) / totalMatches;
  }

  /// Calculate game win percentage
  double get gameWinPercentage {
    final totalGames = gameWins + gameLosses;
    if (totalGames == 0) return 0.0;
    return gameWins / totalGames;
  }

  /// Check if this participant has faced a specific opponent
  bool hasFacedOpponent(String opponentId) {
    return opponentsFaced.contains(opponentId);
  }

  /// Get total matches played
  int get totalMatches => matchWins + matchLosses + matchDraws;

  /// Get total points (with safety check)
  int get safePoints => points ?? 0;

  @override
  TournamentParticipant copyWith({
    String? id,
    String? tournamentId,
    String? userId,
    String? deckId,
    int? points,
    int? matchWins,
    int? matchLosses,
    int? matchDraws,
    int? gameWins,
    int? gameLosses,
    List<String>? opponentsFaced,
    bool? isDropped,
    int? droppedRound,
    DateTime? joinedAt,
  }) {
    return TournamentParticipant(
      id: id ?? this.id,
      tournamentId: tournamentId ?? this.tournamentId,
      userId: userId ?? this.userId,
      deckId: deckId ?? this.deckId,
      points: points ?? this.points,
      matchWins: matchWins ?? this.matchWins,
      matchLosses: matchLosses ?? this.matchLosses,
      matchDraws: matchDraws ?? this.matchDraws,
      gameWins: gameWins ?? this.gameWins,
      gameLosses: gameLosses ?? this.gameLosses,
      opponentsFaced: opponentsFaced ?? this.opponentsFaced,
      isDropped: isDropped ?? this.isDropped,
      droppedRound: droppedRound ?? this.droppedRound,
      joinedAt: joinedAt ?? this.joinedAt,
    );
  }
} 