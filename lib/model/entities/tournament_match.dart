import 'package:json_annotation/json_annotation.dart';
import 'package:uuid/uuid.dart';
import '../base_model.dart';

part 'tournament_match.g.dart';

/// Status of a tournament match
enum MatchStatus {
  @JsonValue('pending')
  pending,
  @JsonValue('in_progress')
  inProgress,
  @JsonValue('finished')
  finished,
  @JsonValue('disputed')
  disputed
}

/// Tournament match model representing a match in a tournament
@JsonSerializable()
class TournamentMatch extends BaseModel {
  /// The ID of the tournament
  @JsonKey(name: 'tournament_id')
  final String tournamentId;
  
  /// The ID of player 1
  @JsonKey(name: 'player1_id')
  final String? player1Id;
  
  /// The ID of player 2 (null for bye)
  @JsonKey(name: 'player2_id')
  final String? player2Id;
  
  /// The ID of the winner (null if not finished)
  @JsonKey(name: 'winner_id')
  final String? winnerId;
  
  /// The round number
  final int round;
  
  /// The date of the match
  final DateTime? date;
  
  /// Status of the match
  @JsonKey(name: 'match_status')
  final MatchStatus matchStatus;
  
  /// Result score in format "X-Y" (e.g., "2-1")
  @JsonKey(name: 'result_score')
  final String? resultScore;
  
  /// Physical table number for the match
  @JsonKey(name: 'table_number')
  final int? tableNumber;
  
  /// Whether this is a bye match (no opponent)
  @JsonKey(name: 'is_bye')
  final bool isBye;
  
  /// When the match started
  @JsonKey(name: 'started_at')
  final DateTime? startedAt;
  
  /// When the match finished
  @JsonKey(name: 'finished_at')
  final DateTime? finishedAt;

  /// Constructor
  const TournamentMatch({
    required super.id,
    required this.tournamentId,
    this.player1Id,
    this.player2Id,
    this.winnerId,
    required this.round,
    this.date,
    this.matchStatus = MatchStatus.pending,
    this.resultScore,
    this.tableNumber,
    this.isBye = false,
    this.startedAt,
    this.finishedAt,
  });

  /// Creates a new TournamentMatch instance with a generated UUID
  factory TournamentMatch.create({
    required String tournamentId,
    String? player1Id,
    String? player2Id,
    required int round,
    int? tableNumber,
    bool isBye = false,
  }) {
    return TournamentMatch(
      id: const Uuid().v4(),
      tournamentId: tournamentId,
      player1Id: player1Id,
      player2Id: player2Id,
      round: round,
      date: DateTime.now(),
      tableNumber: tableNumber,
      isBye: isBye,
    );
  }

  /// Creates a tournament match from JSON
  factory TournamentMatch.fromJson(Map<String, dynamic> json) => 
      _$TournamentMatchFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$TournamentMatchToJson(this);

  /// Get the non-bye player ID (for bye matches)
  String? get activePlayerId {
    if (!isBye) return null;
    return player1Id ?? player2Id;
  }

  /// Check if this is a finished match
  bool get isFinished => matchStatus == MatchStatus.finished;

  /// Check if this is a bye match
  bool get isByeMatch => isBye && player2Id == null;

  /// Get opponent ID for a given player
  String? getOpponentId(String playerId) {
    if (isBye) return null;
    if (player1Id == playerId) return player2Id;
    if (player2Id == playerId) return player1Id;
    return null;
  }

  /// Check if a player won this match
  bool didPlayerWin(String playerId) {
    return winnerId == playerId;
  }

  /// Parse the result score into individual game scores
  List<int>? get parsedScore {
    if (resultScore == null) return null;
    final parts = resultScore!.split('-');
    if (parts.length != 2) return null;
    
    final player1Games = int.tryParse(parts[0]);
    final player2Games = int.tryParse(parts[1]);
    
    if (player1Games == null || player2Games == null) return null;
    return [player1Games, player2Games];
  }

  /// Check if the match was a draw
  bool get isDraw {
    final scores = parsedScore;
    if (scores == null) return false;
    return scores[0] == scores[1];
  }

  @override
  TournamentMatch copyWith({
    String? id,
    String? tournamentId,
    String? player1Id,
    String? player2Id,
    String? winnerId,
    int? round,
    DateTime? date,
    MatchStatus? matchStatus,
    String? resultScore,
    int? tableNumber,
    bool? isBye,
    DateTime? startedAt,
    DateTime? finishedAt,
  }) {
    return TournamentMatch(
      id: id ?? this.id,
      tournamentId: tournamentId ?? this.tournamentId,
      player1Id: player1Id ?? this.player1Id,
      player2Id: player2Id ?? this.player2Id,
      winnerId: winnerId ?? this.winnerId,
      round: round ?? this.round,
      date: date ?? this.date,
      matchStatus: matchStatus ?? this.matchStatus,
      resultScore: resultScore ?? this.resultScore,
      tableNumber: tableNumber ?? this.tableNumber,
      isBye: isBye ?? this.isBye,
      startedAt: startedAt ?? this.startedAt,
      finishedAt: finishedAt ?? this.finishedAt,
    );
  }
} 