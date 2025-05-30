import 'package:topdeck_app_flutter/model/entities/tournament_invitation.dart';
import 'package:topdeck_app_flutter/network/service/base_service.dart';

/// Service interface for TournamentInvitation operations
abstract class TournamentInvitationService extends BaseService {
  /// Finds invitations by tournament ID
  Future<List<Map<String, dynamic>>> findByTournament(String tournamentId);
  
  /// Finds invitations by receiver ID
  Future<List<Map<String, dynamic>>> findByReceiver(String receiverId);
  
  /// Finds invitations by sender ID
  Future<List<Map<String, dynamic>>> findBySender(String senderId);
  
  /// Finds invitations by status
  Future<List<Map<String, dynamic>>> findByStatus(TournamentInvitationStatus status);
  
  /// Updates the status of an invitation
  Future<Map<String, dynamic>> updateStatus(String id, TournamentInvitationStatus status);
  
  /// Finds pending invitations for a specific user and tournament
  Future<Map<String, dynamic>?> findPendingInvitation(String tournamentId, String receiverId);

  /// Sends a tournament invitation
  Future<Map<String, dynamic>> sendInvitation({
    required String tournamentId,
    required String receiverId,
    String? message,
  });
} 