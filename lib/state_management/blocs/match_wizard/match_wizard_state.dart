import 'package:equatable/equatable.dart';
import 'package:topdeck_app_flutter/model/entities/deck.dart';
import 'package:topdeck_app_flutter/model/user.dart';

/// Represents the state of the match wizard
abstract class MatchWizardState extends Equatable {
  @override
  List<Object?> get props => [];
}

/// Initial state of the match wizard
class MatchWizardInitialState extends MatchWizardState {}

/// Loading state when fetching data
class MatchWizardLoadingState extends MatchWizardState {}

/// Error state with error message
class MatchWizardErrorState extends MatchWizardState {
  /// Error message
  final String errorMessage;

  /// Constructor
  MatchWizardErrorState(this.errorMessage);

  @override
  List<Object?> get props => [errorMessage];
}

/// State for user search results
class UserSearchResultsState extends MatchWizardState {
  /// List of user profiles found
  final List<UserProfile> users;
  
  /// Constructor
  UserSearchResultsState(this.users);
  
  @override
  List<Object?> get props => [users];
}

/// State for user decks loaded
class UserDecksLoadedState extends MatchWizardState {
  /// List of user decks
  final List<Deck> decks;
  /// Format selected
  final DeckFormat format;
  
  /// Constructor
  UserDecksLoadedState(this.decks, this.format);
  
  @override
  List<Object?> get props => [decks, format];
}

/// State for opponent deck selection
class OpponentDecksLoadedState extends MatchWizardState {
  /// List of opponent decks
  final List<Map<String, dynamic>> decks;
  /// Selected opponent ID
  final String opponentId;
  
  /// Constructor
  OpponentDecksLoadedState(this.decks, this.opponentId);
  
  @override
  List<Object?> get props => [decks, opponentId];
}

/// State for saving match
class SavingMatchState extends MatchWizardState {}

/// State when match has been saved successfully
class MatchSavedState extends MatchWizardState {
  /// Match ID
  final String matchId;
  
  /// Constructor
  MatchSavedState(this.matchId);
  
  @override
  List<Object?> get props => [matchId];
}

/// State when sending match invitation
class SendingInvitationState extends MatchWizardState {}

/// State when match invitation has been sent successfully
class InvitationSentState extends MatchWizardState {
  /// Invitation ID
  final String invitationId;
  
  /// Constructor
  InvitationSentState(this.invitationId);
  
  @override
  List<Object?> get props => [invitationId];
} 