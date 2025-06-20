import 'package:topdeck_app_flutter/model/entities/match_invitation.dart';
import 'package:topdeck_app_flutter/repositories/base_repository.dart';

/// Repository interface for MatchInvitation entities
abstract class MatchInvitationRepository extends BaseRepository<MatchInvitation> {
  /// Gets all invitations received by the current user
 
  
  
  
  
  /// Finds invitations by status
  Future<List<MatchInvitation>> findByStatus(MatchInvitationStatus status);
  
  /// Finds pending invitations for today only
  Future<List<MatchInvitation>> findTodaysPendingInvitations();
  
  /// Accepts an invitation with a selected deck
  Future<Map<String, dynamic>> acceptInvitation(String invitationId, {String? selectedDeckId});
  
  /// Declines an invitation
  Future<void> declineInvitation(String invitationId);
  
  /// Updates the status of an invitation
  Future<MatchInvitation> updateStatus(String id, MatchInvitationStatus status);
  
  /// Sends a new match invitation
  Future<MatchInvitation> sendInvitation({
    required String receiverId,
    required String format,
    String? message,
  });
  
  /// Checks if an invitation is expired (more than 24 hours old)
  Future<bool> isInvitationExpired(String invitationId);
  
  /// Gets invitations that are about to expire (within 1 hour)
  Future<List<MatchInvitation>> getExpiringInvitations();
  
  /// Finds pending invitations between two specific users
  Future<MatchInvitation?> findPendingInvitationBetweenUsers(String senderId, String receiverId);
} 