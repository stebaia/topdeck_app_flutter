import 'package:equatable/equatable.dart';
import 'package:topdeck_app_flutter/model/entities/match.dart';

/// Base state class for match listing
abstract class MatchListState extends Equatable {
  @override
  List<Object?> get props => [];
}

/// Initial state
class MatchListInitialState extends MatchListState {}

/// Loading state
class MatchListLoadingState extends MatchListState {}

/// Loaded state with matches
class MatchListLoadedState extends MatchListState {
  /// The loaded matches
  final List<Match> matches;

  /// Constructor
  MatchListLoadedState(this.matches);

  @override
  List<Object?> get props => [matches];
}

/// Error state
class MatchListErrorState extends MatchListState {
  /// The error message
  final String message;

  /// Constructor
  MatchListErrorState(this.message);

  @override
  List<Object?> get props => [message];
}

/// Match cancellation states
class MatchCancellingState extends MatchListState {
  final String matchId;

  MatchCancellingState(this.matchId);

  @override
  List<Object?> get props => [matchId];
}

class MatchCancelledState extends MatchListState {
  final String matchId;

  MatchCancelledState(this.matchId);

  @override
  List<Object?> get props => [matchId];
}

class MatchCancelErrorState extends MatchListState {
  final String matchId;
  final String error;

  MatchCancelErrorState(this.matchId, this.error);

  @override
  List<Object?> get props => [matchId, error];
} 