import 'package:json_annotation/json_annotation.dart';
import 'package:uuid/uuid.dart';
import '../base_model.dart';

part 'tournament_invitation.g.dart';

/// Status of a tournament invitation
enum TournamentInvitationStatus {
  @JsonValue('pending')
  pending,
  @JsonValue('accepted')
  accepted,
  @JsonValue('declined')
  declined
}

/// Tournament invitation model representing an invitation to join a tournament
@JsonSerializable()
class TournamentInvitation extends BaseModel {
  /// The ID of the tournament being invited to
  @JsonKey(name: 'tournament_id')
  final String tournamentId;
  
  /// The ID of the user who sent the invitation
  @JsonKey(name: 'sender_id')
  final String senderId;
  
  /// The ID of the user who received the invitation
  @JsonKey(name: 'receiver_id')
  final String receiverId;
  
  /// Optional message from sender to receiver
  final String? message;
  
  /// Status of the invitation
  final TournamentInvitationStatus status;
  
  /// The creation timestamp
  @JsonKey(name: 'created_at')
  final DateTime? createdAt;

  /// Constructor
  const TournamentInvitation({
    required super.id,
    required this.tournamentId,
    required this.senderId,
    required this.receiverId,
    this.message,
    this.status = TournamentInvitationStatus.pending,
    this.createdAt,
  });

  /// Creates a new TournamentInvitation instance with a generated UUID
  factory TournamentInvitation.create({
    required String tournamentId,
    required String senderId,
    required String receiverId,
    String? message,
    TournamentInvitationStatus status = TournamentInvitationStatus.pending,
  }) {
    return TournamentInvitation(
      id: const Uuid().v4(),
      tournamentId: tournamentId,
      senderId: senderId,
      receiverId: receiverId,
      message: message,
      status: status,
      createdAt: DateTime.now(),
    );
  }

  /// Creates a tournament invitation from JSON
  factory TournamentInvitation.fromJson(Map<String, dynamic> json) => 
      _$TournamentInvitationFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$TournamentInvitationToJson(this);

  @override
  TournamentInvitation copyWith({
    String? id,
    String? tournamentId,
    String? senderId,
    String? receiverId,
    String? message,
    TournamentInvitationStatus? status,
    DateTime? createdAt,
  }) {
    return TournamentInvitation(
      id: id ?? this.id,
      tournamentId: tournamentId ?? this.tournamentId,
      senderId: senderId ?? this.senderId,
      receiverId: receiverId ?? this.receiverId,
      message: message ?? this.message,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }
} 