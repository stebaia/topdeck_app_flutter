import 'package:equatable/equatable.dart';

/// Base event class for invitation listing
abstract class InvitationListEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

/// Event to load all match invitations for the current user
class LoadInvitationsEvent extends InvitationListEvent {}

/// Event to refresh all match invitations for the current user
class RefreshInvitationsEvent extends InvitationListEvent {}

/// Event to load all sent invitations by the current user
class LoadSentInvitationsEvent extends InvitationListEvent {}

/// Event to refresh all sent invitations by the current user
class RefreshSentInvitationsEvent extends InvitationListEvent {}

/// Event to toggle between received and sent invitations
class ToggleInvitationViewEvent extends InvitationListEvent {
  /// Whether to show sent invitations
  final bool showSent;
  
  /// Constructor
  ToggleInvitationViewEvent(this.showSent);
  
  @override
  List<Object?> get props => [showSent];
}

/// Event to accept a match invitation
class AcceptInvitationEvent extends InvitationListEvent {
  /// The invitation ID to accept
  final String invitationId;
  
  /// Constructor
  AcceptInvitationEvent(this.invitationId);
  
  @override
  List<Object?> get props => [invitationId];
}

/// Event to decline a match invitation
class DeclineInvitationEvent extends InvitationListEvent {
  /// The invitation ID to decline
  final String invitationId;
  
  /// Constructor
  DeclineInvitationEvent(this.invitationId);
  
  @override
  List<Object?> get props => [invitationId];
} 