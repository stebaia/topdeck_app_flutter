import 'package:topdeck_app_flutter/model/entities/tournament.dart';
import 'package:topdeck_app_flutter/repositories/base_repository.dart';

/// Repository interface for Tournament entities
abstract class TournamentRepository extends BaseRepository<Tournament> {
  /// Finds tournaments by creator ID
  Future<List<Tournament>> findByCreator(String creatorId);
  
  /// Finds tournaments by status
  Future<List<Tournament>> findByStatus(TournamentStatus status);
  
  /// Finds tournaments by format
  Future<List<Tournament>> findByFormat(String format);
  
  /// Updates the status of a tournament
  Future<Tournament> updateStatus(String id, TournamentStatus status);

  /// Finds public tournaments that are open for registration
  Future<List<Tournament>> findPublicTournaments({String? excludeCreatedBy});

  /// Finds a tournament by invite code
  Future<Tournament?> findByInviteCode(String inviteCode);

  /// Generates a unique invite code for a tournament
  Future<String> generateInviteCode(String tournamentId);

  /// Checks if a tournament has available spots
  Future<bool> hasAvailableSpots(String tournamentId);

  /// Gets the current participant count for a tournament
  Future<int> getParticipantCount(String tournamentId);
} 