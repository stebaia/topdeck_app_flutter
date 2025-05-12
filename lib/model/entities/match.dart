import 'package:json_annotation/json_annotation.dart';
import 'package:uuid/uuid.dart';
import '../base_model.dart';
import 'deck.dart';

part 'match.g.dart';

/// Match model representing a match in the Supabase matches table
@JsonSerializable()
class Match extends BaseModel {
  /// The ID of player 1
  @JsonKey(name: 'player1_id')
  final String? player1Id;
  
  /// The ID of player 2
  @JsonKey(name: 'player2_id')
  final String? player2Id;
  
  /// The ID of the winner
  @JsonKey(name: 'winner_id')
  final String? winnerId;
  
  /// The format of the match
  final String format;
  
  /// The ID of player 1's deck
  @JsonKey(name: 'player1_deck_id')
  final String? player1DeckId;
  
  /// The ID of player 2's deck
  @JsonKey(name: 'player2_deck_id')
  final String? player2DeckId;
  
  /// The date of the match
  final DateTime? date;

  /// Constructor
  const Match({
    required super.id,
    this.player1Id,
    this.player2Id,
    this.winnerId,
    required this.format,
    this.player1DeckId,
    this.player2DeckId,
    this.date,
  });

  /// Creates a new Match instance with a generated UUID
  factory Match.create({
    String? player1Id,
    String? player2Id,
    String? winnerId,
    required String format,
    String? player1DeckId,
    String? player2DeckId,
  }) {
    return Match(
      id: const Uuid().v4(),
      player1Id: player1Id,
      player2Id: player2Id,
      winnerId: winnerId,
      format: format,
      player1DeckId: player1DeckId,
      player2DeckId: player2DeckId,
      date: DateTime.now(),
    );
  }

  /// Creates a match from JSON
  factory Match.fromJson(Map<String, dynamic> json) => _$MatchFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$MatchToJson(this);

  @override
  Match copyWith({
    String? id,
    String? player1Id,
    String? player2Id,
    String? winnerId,
    String? format,
    String? player1DeckId,
    String? player2DeckId,
    DateTime? date,
  }) {
    return Match(
      id: id ?? this.id,
      player1Id: player1Id ?? this.player1Id,
      player2Id: player2Id ?? this.player2Id,
      winnerId: winnerId ?? this.winnerId,
      format: format ?? this.format,
      player1DeckId: player1DeckId ?? this.player1DeckId,
      player2DeckId: player2DeckId ?? this.player2DeckId,
      date: date ?? this.date,
    );
  }
} 