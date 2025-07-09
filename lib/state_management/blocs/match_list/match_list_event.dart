import 'package:equatable/equatable.dart';

/// Base event class for match listing
abstract class MatchListEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

/// Event to load all matches for the current user
class LoadMatchesEvent extends MatchListEvent {}

/// Event to refresh all matches for the current user
class RefreshMatchesEvent extends MatchListEvent {}

/// Event to cancel a match
class CancelMatchEvent extends MatchListEvent {
  final String matchId;

  CancelMatchEvent(this.matchId);

  @override
  List<Object?> get props => [matchId];
} 