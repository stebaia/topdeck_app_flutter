import 'package:equatable/equatable.dart';
import 'package:topdeck_app_flutter/model/entities/tournament.dart';

/// Represents the state of the tournament management
abstract class TournamentState extends Equatable {
  @override
  List<Object?> get props => [];
}

/// Initial state of the tournament management
class TournamentInitialState extends TournamentState {}

/// Loading state when fetching data
class TournamentLoadingState extends TournamentState {}

/// Error state with error message
class TournamentErrorState extends TournamentState {
  /// Error message
  final String errorMessage;

  /// Constructor
  TournamentErrorState(this.errorMessage);

  @override
  List<Object?> get props => [errorMessage];
}

/// Combined state that holds both public and user tournaments
class TournamentsLoadedState extends TournamentState {
  /// List of public tournaments
  final List<Tournament>? publicTournaments;
  /// List of user's tournaments
  final List<Tournament>? myTournaments;
  
  /// Constructor
  TournamentsLoadedState({
    this.publicTournaments,
    this.myTournaments,
  });
  
  /// Copy with method to update specific lists
  TournamentsLoadedState copyWith({
    List<Tournament>? publicTournaments,
    List<Tournament>? myTournaments,
  }) {
    return TournamentsLoadedState(
      publicTournaments: publicTournaments ?? this.publicTournaments,
      myTournaments: myTournaments ?? this.myTournaments,
    );
  }
  
  @override
  List<Object?> get props => [publicTournaments, myTournaments];
}

/// State for public tournaments loaded
class PublicTournamentsLoadedState extends TournamentState {
  /// List of public tournaments
  final List<Tournament> tournaments;
  
  /// Constructor
  PublicTournamentsLoadedState(this.tournaments);
  
  @override
  List<Object?> get props => [tournaments];
}

/// State for user's tournaments loaded
class MyTournamentsLoadedState extends TournamentState {
  /// List of user's tournaments
  final List<Tournament> tournaments;
  
  /// Constructor
  MyTournamentsLoadedState(this.tournaments);
  
  @override
  List<Object?> get props => [tournaments];
}

// === OPERATION STATES (separate from list states) ===

/// Base class for tournament operation states
abstract class TournamentOperationState extends Equatable {
  @override
  List<Object?> get props => [];
}

/// State when creating tournament
class CreatingTournamentState extends TournamentOperationState {}

/// State when tournament has been created successfully
class TournamentCreatedState extends TournamentOperationState {
  /// Created tournament
  final Tournament tournament;
  
  /// Constructor
  TournamentCreatedState(this.tournament);
  
  @override
  List<Object?> get props => [tournament];
}

/// State when joining tournament
class JoiningTournamentState extends TournamentOperationState {}

/// State when tournament has been joined successfully
class TournamentJoinedState extends TournamentOperationState {
  /// Joined tournament
  final Tournament tournament;
  
  /// Constructor
  TournamentJoinedState(this.tournament);
  
  @override
  List<Object?> get props => [tournament];
}

/// State when generating invite code
class GeneratingInviteCodeState extends TournamentOperationState {}

/// State when invite code has been generated successfully
class InviteCodeGeneratedState extends TournamentOperationState {
  /// Tournament ID
  final String tournamentId;
  /// Generated invite code
  final String inviteCode;
  
  /// Constructor
  InviteCodeGeneratedState(this.tournamentId, this.inviteCode);
  
  @override
  List<Object?> get props => [tournamentId, inviteCode];
} 