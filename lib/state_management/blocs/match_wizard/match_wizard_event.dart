import 'package:equatable/equatable.dart';
import 'package:topdeck_app_flutter/model/entities/deck.dart';

/// Base class for all match wizard events
abstract class MatchWizardEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

/// Event to search for users by query
class SearchUsersEvent extends MatchWizardEvent {
  /// Search query
  final String query;
  
  /// Constructor
  SearchUsersEvent(this.query);
  
  @override
  List<Object?> get props => [query];
}

/// Event to load deck by format for the current user
class LoadUserDecksByFormatEvent extends MatchWizardEvent {
  /// Deck format
  final DeckFormat format;
  
  /// Constructor
  LoadUserDecksByFormatEvent(this.format);
  
  @override
  List<Object?> get props => [format];
}

/// Event to load opponent decks
class LoadOpponentDecksEvent extends MatchWizardEvent {
  /// Opponent user ID
  final String opponentId;
  
  /// Constructor
  LoadOpponentDecksEvent(this.opponentId);
  
  @override
  List<Object?> get props => [opponentId];
}

/// Event to save match result
class SaveMatchResultEvent extends MatchWizardEvent {
  /// Player ID
  final String playerId;
  /// Opponent ID
  final String opponentId;
  /// Player deck ID
  final String playerDeckId;
  /// Opponent deck ID
  final String opponentDeckId;
  /// Match format
  final DeckFormat format;
  /// Winner ID
  final String winnerId;
  
  /// Constructor
  SaveMatchResultEvent({
    required this.playerId,
    required this.opponentId,
    required this.playerDeckId,
    required this.opponentDeckId,
    required this.format,
    required this.winnerId,
  });
  
  @override
  List<Object?> get props => [
    playerId,
    opponentId, 
    playerDeckId, 
    opponentDeckId, 
    format, 
    winnerId,
  ];
}

/// Event to send a match invitation
class SendMatchInvitationEvent extends MatchWizardEvent {
  /// Player ID
  final String playerId;
  /// Player deck ID
  final String playerDeckId;
  /// Opponent ID
  final String opponentId;
  /// Match format
  final DeckFormat format;
  /// Optional message
  final String? message;
  
  /// Constructor
  SendMatchInvitationEvent({
    required this.playerId,
    required this.playerDeckId,
    required this.opponentId,
    required this.format,
    this.message,
  });
  
  @override
  List<Object?> get props => [
    playerId,
    playerDeckId,
    opponentId,
    format,
    message,
  ];
}

/// Event to reset the state
class ResetEvent extends MatchWizardEvent {} 