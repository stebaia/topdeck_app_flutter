import 'package:json_annotation/json_annotation.dart';
import 'package:uuid/uuid.dart';
import '../base_model.dart';

part 'match_extended.g.dart';

/// MatchExtended model representing extended match information with ELO data in the Supabase matches_extended table
@JsonSerializable()
class MatchExtended extends BaseModel {
  /// The ID of player 1
  @JsonKey(name: 'player1_id')
  final String player1Id;
  
  /// The ID of player 2 (null for bye matches)
  @JsonKey(name: 'player2_id')
  final String? player2Id;
  
  /// The ID of the winner (null for draws)
  @JsonKey(name: 'winner_id')
  final String? winnerId;
  
  /// The format of the match
  final String format;
  
  /// The date of the match
  final DateTime? date;
  
  /// The tournament this match belongs to (null for friendly matches)
  @JsonKey(name: 'tournament_id')
  final String? tournamentId;
  
  /// Whether this is a friendly match
  @JsonKey(name: 'is_friendly')
  final bool isFriendly;
  
  /// Whether this is a bye match
  @JsonKey(name: 'is_bye')
  final bool isBye;
  
  /// Player 1's ELO before the match
  @JsonKey(name: 'player1_elo_before')
  final int? player1EloBefore;
  
  /// Player 2's ELO before the match
  @JsonKey(name: 'player2_elo_before')
  final int? player2EloBefore;
  
  /// Player 1's ELO after the match
  @JsonKey(name: 'player1_elo_after')
  final int? player1EloAfter;
  
  /// Player 2's ELO after the match
  @JsonKey(name: 'player2_elo_after')
  final int? player2EloAfter;
  
  /// Player 1's ELO change (+/-)
  @JsonKey(name: 'player1_elo_change')
  final int? player1EloChange;
  
  /// Player 2's ELO change (+/-)
  @JsonKey(name: 'player2_elo_change')
  final int? player2EloChange;
  
  /// Tournament round number
  final int? round;
  
  /// The ID of player 1's deck
  @JsonKey(name: 'player1_deck_id')
  final String? player1DeckId;
  
  /// The ID of player 2's deck
  @JsonKey(name: 'player2_deck_id')
  final String? player2DeckId;
  
  /// Timestamp when this record was created
  @JsonKey(name: 'created_at')
  final DateTime? createdAt;

  /// Constructor
  const MatchExtended({
    required super.id,
    required this.player1Id,
    this.player2Id,
    this.winnerId,
    required this.format,
    this.date,
    this.tournamentId,
    this.isFriendly = false,
    this.isBye = false,
    this.player1EloBefore,
    this.player2EloBefore,
    this.player1EloAfter,
    this.player2EloAfter,
    this.player1EloChange,
    this.player2EloChange,
    this.round,
    this.player1DeckId,
    this.player2DeckId,
    this.createdAt,
  });

  /// Creates a new MatchExtended instance with a generated UUID
  factory MatchExtended.create({
    required String player1Id,
    String? player2Id,
    String? winnerId,
    required String format,
    String? tournamentId,
    bool isFriendly = false,
    bool isBye = false,
    int? round,
    String? player1DeckId,
    String? player2DeckId,
  }) {
    return MatchExtended(
      id: const Uuid().v4(),
      player1Id: player1Id,
      player2Id: player2Id,
      winnerId: winnerId,
      format: format,
      date: DateTime.now(),
      tournamentId: tournamentId,
      isFriendly: isFriendly,
      isBye: isBye,
      round: round,
      player1DeckId: player1DeckId,
      player2DeckId: player2DeckId,
      createdAt: DateTime.now(),
    );
  }

  /// Creates a MatchExtended from JSON
  factory MatchExtended.fromJson(Map<String, dynamic> json) => _$MatchExtendedFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$MatchExtendedToJson(this);

  @override
  MatchExtended copyWith({
    String? id,
    String? player1Id,
    String? player2Id,
    String? winnerId,
    String? format,
    DateTime? date,
    String? tournamentId,
    bool? isFriendly,
    bool? isBye,
    int? player1EloBefore,
    int? player2EloBefore,
    int? player1EloAfter,
    int? player2EloAfter,
    int? player1EloChange,
    int? player2EloChange,
    int? round,
    String? player1DeckId,
    String? player2DeckId,
    DateTime? createdAt,
  }) {
    return MatchExtended(
      id: id ?? this.id,
      player1Id: player1Id ?? this.player1Id,
      player2Id: player2Id ?? this.player2Id,
      winnerId: winnerId ?? this.winnerId,
      format: format ?? this.format,
      date: date ?? this.date,
      tournamentId: tournamentId ?? this.tournamentId,
      isFriendly: isFriendly ?? this.isFriendly,
      isBye: isBye ?? this.isBye,
      player1EloBefore: player1EloBefore ?? this.player1EloBefore,
      player2EloBefore: player2EloBefore ?? this.player2EloBefore,
      player1EloAfter: player1EloAfter ?? this.player1EloAfter,
      player2EloAfter: player2EloAfter ?? this.player2EloAfter,
      player1EloChange: player1EloChange ?? this.player1EloChange,
      player2EloChange: player2EloChange ?? this.player2EloChange,
      round: round ?? this.round,
      player1DeckId: player1DeckId ?? this.player1DeckId,
      player2DeckId: player2DeckId ?? this.player2DeckId,
      createdAt: createdAt ?? this.createdAt,
    );
  }
  
  /// Check if this was a draw
  bool get isDraw => winnerId == null && !isBye;
  
  /// Check if this is a tournament match
  bool get isTournament => tournamentId != null;
  
  /// Get the match result for a specific player
  MatchResult getResultForPlayer(String playerId) {
    if (isBye && player1Id == playerId) return MatchResult.bye;
    if (winnerId == null) return MatchResult.draw;
    if (winnerId == playerId) return MatchResult.win;
    return MatchResult.loss;
  }
  
  /// Get ELO change for a specific player
  int? getEloChangeForPlayer(String playerId) {
    if (player1Id == playerId) return player1EloChange;
    if (player2Id == playerId) return player2EloChange;
    return null;
  }
}

/// Enum for match results
enum MatchResult {
  win,
  loss,
  draw,
  bye,
} 