import 'package:equatable/equatable.dart';
import 'package:topdeck_app_flutter/model/entities/match_invitation.dart';

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
  /// List of invitations (using MatchInvitation model)
  final List<MatchInvitation> invitations;
  
  /// Raw JSON data for backward compatibility
  final List<Map<String, dynamic>> rawInvitations;
  
  /// Whether these are sent invitations
  final bool areSentInvitations;
  
  /// Constructor
  InvitationListLoadedState(this.rawInvitations, {required this.areSentInvitations})
      : invitations = rawInvitations
            .map((json) => MatchInvitation.fromEdgeFunctionResponse(json))
            .toList();
  
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
  /// The invitation data (using MatchInvitation model)
  final MatchInvitation invitation;
  
  /// Raw JSON data for backward compatibility
  final Map<String, dynamic> rawInvitation;
  
  /// Constructor
  SelectingDeckForInvitationState(this.rawInvitation)
      : invitation = MatchInvitation.fromEdgeFunctionResponse(rawInvitation);
  
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

class InvitationCancelledState extends InvitationListState {
  final String invitationId;

  InvitationCancelledState(this.invitationId);

  @override
  List<Object?> get props => [invitationId];
}

class InvitationCancelledErrorState extends InvitationListState {
  final String error;

  InvitationCancelledErrorState(this.error);

  @override
  List<Object?> get props => [error];
}

class InvitationCancelledLoadingState extends InvitationListState {
  @override
  List<Object?> get props => [];
}