import 'package:equatable/equatable.dart';

/// Base state class for invitation listing
abstract class InvitationListState extends Equatable {
  @override
  List<Object?> get props => [];
}

/// Initial state
class InvitationListInitialState extends InvitationListState {}

/// Loading state
class InvitationListLoadingState extends InvitationListState {}

/// Loaded state with received invitations
class InvitationListLoadedState extends InvitationListState {
  /// The loaded invitations
  final List<Map<String, dynamic>> invitations;
  /// Whether these are sent invitations (false = received)
  final bool areSentInvitations;

  /// Constructor
  InvitationListLoadedState(this.invitations, {this.areSentInvitations = false});

  @override
  List<Object?> get props => [invitations, areSentInvitations];
}

/// Loading sent invitations state
class SentInvitationsLoadingState extends InvitationListState {}

/// Loaded state with sent invitations
class SentInvitationsLoadedState extends InvitationListState {
  /// The loaded sent invitations
  final List<Map<String, dynamic>> invitations;

  /// Constructor
  SentInvitationsLoadedState(this.invitations);

  @override
  List<Object?> get props => [invitations];
}

/// Error state
class InvitationListErrorState extends InvitationListState {
  /// The error message
  final String message;
  /// Whether this error is from sent invitations
  final bool forSentInvitations;

  /// Constructor
  InvitationListErrorState(this.message, {this.forSentInvitations = false});

  @override
  List<Object?> get props => [message, forSentInvitations];
}

/// Processing invitation action state (accepting/declining)
class InvitationProcessingState extends InvitationListState {
  /// The invitation being processed
  final String invitationId;
  
  /// Constructor
  InvitationProcessingState(this.invitationId);
  
  @override
  List<Object?> get props => [invitationId];
}

/// Invitation accepted state
class InvitationAcceptedState extends InvitationListState {
  /// The accepted invitation
  final Map<String, dynamic> invitation;
  
  /// Constructor
  InvitationAcceptedState(this.invitation);
  
  @override
  List<Object?> get props => [invitation];
}

/// Invitation declined state
class InvitationDeclinedState extends InvitationListState {
  /// The declined invitation id
  final String invitationId;
  
  /// Constructor
  InvitationDeclinedState(this.invitationId);
  
  @override
  List<Object?> get props => [invitationId];
} 