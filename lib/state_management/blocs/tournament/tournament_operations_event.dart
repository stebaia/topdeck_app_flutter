import 'package:equatable/equatable.dart';

/// Base class for tournament operation events
abstract class TournamentOperationsEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

/// Event to create a new tournament
class CreateTournamentOperationEvent extends TournamentOperationsEvent {
  /// Tournament name
  final String name;
  /// Tournament format
  final String format;
  /// Whether the tournament is public
  final bool isPublic;
  /// Maximum number of participants (optional)
  final int? maxParticipants;
  /// Tournament league (optional)
  final String? league;
  /// Tournament start date (optional)
  final DateTime? startDate;
  /// Tournament start time in HH:MM format (optional)
  final String? startTime;
  /// Tournament description (optional)
  final String? description;

  /// Constructor
  CreateTournamentOperationEvent({
    required this.name,
    required this.format,
    required this.isPublic,
    this.maxParticipants,
    this.league,
    this.startDate,
    this.startTime,
    this.description,
  });

  @override
  List<Object?> get props => [
    name, 
    format, 
    isPublic, 
    maxParticipants, 
    league,
    startDate,
    startTime,
    description,
  ];
}

/// Event to join a tournament using an invite code
class JoinTournamentByCodeOperationEvent extends TournamentOperationsEvent {
  /// Invite code
  final String inviteCode;

  /// Constructor
  JoinTournamentByCodeOperationEvent(this.inviteCode);

  @override
  List<Object?> get props => [inviteCode];
}

/// Event to join a public tournament
class JoinPublicTournamentOperationEvent extends TournamentOperationsEvent {
  /// Tournament ID
  final String tournamentId;

  /// Constructor
  JoinPublicTournamentOperationEvent(this.tournamentId);

  @override
  List<Object?> get props => [tournamentId];
}

/// Event to generate an invite code for a tournament
class GenerateInviteCodeOperationEvent extends TournamentOperationsEvent {
  /// Tournament ID
  final String tournamentId;

  /// Constructor
  GenerateInviteCodeOperationEvent(this.tournamentId);

  @override
  List<Object?> get props => [tournamentId];
} 