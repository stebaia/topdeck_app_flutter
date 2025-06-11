import 'package:equatable/equatable.dart';
import 'package:topdeck_app_flutter/model/entities/deck.dart';

/// Base class for decks state
abstract class DecksState extends Equatable {
  @override
  List<Object?> get props => [];
}

/// Initial state
class DecksInitial extends DecksState {}

/// Loading state
class DecksLoading extends DecksState {}

/// Loaded state with deck list
class DecksLoaded extends DecksState {
  /// The list of decks
  final List<Deck> decks;

  /// Constructor
  DecksLoaded(this.decks);

  @override
  List<Object?> get props => [decks];
}

/// Error state
class DecksError extends DecksState {
  /// The error message
  final String message;

  /// Constructor
  DecksError(this.message);

  @override
  List<Object?> get props => [message];
} 