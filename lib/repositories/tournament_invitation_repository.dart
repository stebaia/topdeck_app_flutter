import 'package:topdeck_app_flutter/model/entities/tournament_invitation.dart';
import 'package:topdeck_app_flutter/repositories/base_repository.dart';

/// Repository interface for TournamentInvitation entities
abstract class TournamentInvitationRepository extends BaseRepository<TournamentInvitation> {
  /// Finds invitations by tournament ID
  Future<List<TournamentInvitation>> findByTournament(String tournamentId);
  
  /// Finds invitations by receiver ID
  Future<List<TournamentInvitation>> findByReceiver(String receiverId);
  
  /// Finds invitations by sender ID
  Future<List<TournamentInvitation>> findBySender(String senderId);
  
  /// Finds invitations by status
  Future<List<TournamentInvitation>> findByStatus(TournamentInvitationStatus status);
  
  /// Updates the status of an invitation
  Future<TournamentInvitation> updateStatus(String id, TournamentInvitationStatus status);
  
  /// Finds pending invitations for a specific user and tournament
  Future<TournamentInvitation?> findPendingInvitation(String tournamentId, String receiverId);
} 