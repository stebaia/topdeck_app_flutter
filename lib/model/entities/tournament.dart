import 'package:json_annotation/json_annotation.dart';
import 'package:uuid/uuid.dart';
import '../base_model.dart';
import 'deck.dart';

part 'tournament.g.dart';

/// Status of a tournament
enum TournamentStatus {
  @JsonValue('upcoming')
  upcoming,
  @JsonValue('ongoing')
  ongoing,
  @JsonValue('completed')
  completed
}

/// Tournament model representing a tournament in the Supabase tournaments table
@JsonSerializable()
class Tournament extends BaseModel {
  /// The name of the tournament
  final String name;
  
  /// The format of the tournament
  final String format;
  
  /// The league this tournament belongs to (optional)
  final String? league;
  
  /// The ID of the user who created this tournament
  @JsonKey(name: 'created_by')
  final String? createdBy;
  
  /// The creation timestamp
  @JsonKey(name: 'created_at')
  final DateTime? createdAt;
  
  /// The status of the tournament
  final TournamentStatus status;

  /// Whether the tournament is public (anyone can join) or private (invite only)
  @JsonKey(name: 'is_public')
  final bool isPublic;

  /// Maximum number of participants allowed in the tournament
  @JsonKey(name: 'max_participants')
  final int? maxParticipants;

  /// Unique code for joining private tournaments
  @JsonKey(name: 'invite_code')
  final String? inviteCode;

  /// Constructor
  const Tournament({
    required super.id,
    required this.name,
    required this.format,
    this.league,
    this.createdBy,
    this.createdAt,
    this.status = TournamentStatus.upcoming,
    this.isPublic = true,
    this.maxParticipants,
    this.inviteCode,
  });

  /// Creates a new Tournament instance with a generated UUID
  factory Tournament.create({
    required String name,
    required String format,
    String? league,
    String? createdBy,
    TournamentStatus status = TournamentStatus.upcoming,
    bool isPublic = true,
    int? maxParticipants,
    String? inviteCode,
  }) {
    return Tournament(
      id: const Uuid().v4(),
      name: name,
      format: format,
      league: league,
      createdBy: createdBy,
      createdAt: DateTime.now(),
      status: status,
      isPublic: isPublic,
      maxParticipants: maxParticipants,
      inviteCode: inviteCode,
    );
  }

  /// Creates a tournament from JSON
  factory Tournament.fromJson(Map<String, dynamic> json) => _$TournamentFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$TournamentToJson(this);

  @override
  Tournament copyWith({
    String? id,
    String? name,
    String? format,
    String? league,
    String? createdBy,
    DateTime? createdAt,
    TournamentStatus? status,
    bool? isPublic,
    int? maxParticipants,
    String? inviteCode,
  }) {
    return Tournament(
      id: id ?? this.id,
      name: name ?? this.name,
      format: format ?? this.format,
      league: league ?? this.league,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      status: status ?? this.status,
      isPublic: isPublic ?? this.isPublic,
      maxParticipants: maxParticipants ?? this.maxParticipants,
      inviteCode: inviteCode ?? this.inviteCode,
    );
  }
} 