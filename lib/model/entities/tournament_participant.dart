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
  
  /// When the user joined the tournament
  @JsonKey(name: 'joined_at')
  final DateTime? joinedAt;

  /// Constructor
  const TournamentParticipant({
    required super.id,
    required this.tournamentId,
    required this.userId,
    this.joinedAt,
  });

  /// Creates a new TournamentParticipant instance with a generated UUID
  factory TournamentParticipant.create({
    required String tournamentId,
    required String userId,
  }) {
    return TournamentParticipant(
      id: const Uuid().v4(),
      tournamentId: tournamentId,
      userId: userId,
      joinedAt: DateTime.now(),
    );
  }

  /// Creates a tournament participant from JSON
  factory TournamentParticipant.fromJson(Map<String, dynamic> json) => 
      _$TournamentParticipantFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$TournamentParticipantToJson(this);

  @override
  TournamentParticipant copyWith({
    String? id,
    String? tournamentId,
    String? userId,
    DateTime? joinedAt,
  }) {
    return TournamentParticipant(
      id: id ?? this.id,
      tournamentId: tournamentId ?? this.tournamentId,
      userId: userId ?? this.userId,
      joinedAt: joinedAt ?? this.joinedAt,
    );
  }
} 