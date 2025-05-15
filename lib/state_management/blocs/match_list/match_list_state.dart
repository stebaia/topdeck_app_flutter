import 'package:equatable/equatable.dart';

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
  final List<Map<String, dynamic>> matches;

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