import 'package:equatable/equatable.dart';

/// Base state class for invitation listing
abstract class InvitationListState extends Equatable {
  @override
  List<Object?> get props => [];
}

/// Initial state
class InvitationListInitialState extends InvitationListState {}

/// Loading invitations state
class InvitationListLoadingState extends InvitationListState {}

/// Loading sent invitations state
class SentInvitationsLoadingState extends InvitationListState {}

/// Invitations loaded state
class InvitationListLoadedState extends InvitationListState {
  /// List of invitations
  final List<Map<String, dynamic>> invitations;
  
  /// Whether these are sent invitations
  final bool areSentInvitations;
  
  /// Constructor
  InvitationListLoadedState(this.invitations, {required this.areSentInvitations});
  
  @override
  List<Object?> get props => [invitations, areSentInvitations];
}

/// Error state
class InvitationListErrorState extends InvitationListState {
  /// Error message
  final String error;
  
  /// Whether this error is for sent invitations
  final bool forSentInvitations;
  
  /// Constructor
  InvitationListErrorState(this.error, {required this.forSentInvitations});
  
  @override
  List<Object?> get props => [error, forSentInvitations];
}

/// Processing invitation state
class InvitationProcessingState extends InvitationListState {
  /// ID of the invitation being processed
  final String invitationId;
  
  /// Constructor
  InvitationProcessingState(this.invitationId);
  
  @override
  List<Object?> get props => [invitationId];
}

/// Selecting deck for invitation state 
class SelectingDeckForInvitationState extends InvitationListState {
  /// The invitation data
  final Map<String, dynamic> invitation;
  
  /// Constructor
  SelectingDeckForInvitationState(this.invitation);
  
  @override
  List<Object?> get props => [invitation];
}

/// Invitation accepted state
class InvitationAcceptedState extends InvitationListState {
  /// The updated invitation data
  final Map<String, dynamic> data;
  
  /// Constructor
  InvitationAcceptedState(this.data);
  
  @override
  List<Object?> get props => [data];
}

/// Invitation accepted and match created state
class MatchCreatedFromInvitationState extends InvitationListState {
  /// The match data
  final Map<String, dynamic> match;
  
  /// The invitation id
  final String invitationId;
  
  /// Constructor
  MatchCreatedFromInvitationState({required this.match, required this.invitationId});
  
  @override
  List<Object?> get props => [match, invitationId];
}

/// Invitation declined state
class InvitationDeclinedState extends InvitationListState {
  /// ID of the declined invitation
  final String invitationId;
  
  /// Constructor
  InvitationDeclinedState(this.invitationId);
  
  @override
  List<Object?> get props => [invitationId];
} 