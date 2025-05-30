import 'package:equatable/equatable.dart';
import 'package:topdeck_app_flutter/model/entities/tournament.dart';

/// Base class for all tournament events
abstract class TournamentEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

/// Event to load all public tournaments
class LoadPublicTournamentsEvent extends TournamentEvent {}

/// Event to load tournaments created by the current user
class LoadMyTournamentsEvent extends TournamentEvent {}

/// Event to create a new tournament
class CreateTournamentEvent extends TournamentEvent {
  /// Tournament name
  final String name;
  /// Tournament format
  final String format;
  /// Whether the tournament is public
  final bool isPublic;
  /// Maximum number of participants
  final int? maxParticipants;
  /// Optional league
  final String? league;
  
  /// Constructor
  CreateTournamentEvent({
    required this.name,
    required this.format,
    required this.isPublic,
    this.maxParticipants,
    this.league,
  });
  
  @override
  List<Object?> get props => [name, format, isPublic, maxParticipants, league];
}

/// Event to join a tournament by invite code
class JoinTournamentByCodeEvent extends TournamentEvent {
  /// Invite code
  final String inviteCode;
  
  /// Constructor
  JoinTournamentByCodeEvent(this.inviteCode);
  
  @override
  List<Object?> get props => [inviteCode];
}

/// Event to join a public tournament
class JoinPublicTournamentEvent extends TournamentEvent {
  /// Tournament ID
  final String tournamentId;
  
  /// Constructor
  JoinPublicTournamentEvent(this.tournamentId);
  
  @override
  List<Object?> get props => [tournamentId];
}

/// Event to generate invite code for a tournament
class GenerateInviteCodeEvent extends TournamentEvent {
  /// Tournament ID
  final String tournamentId;
  
  /// Constructor
  GenerateInviteCodeEvent(this.tournamentId);
  
  @override
  List<Object?> get props => [tournamentId];
}

/// Event to reset the state
class ResetTournamentEvent extends TournamentEvent {} 