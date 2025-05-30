import 'package:topdeck_app_flutter/model/entities/tournament_participant.dart';
import 'package:topdeck_app_flutter/repositories/base_repository.dart';

/// Repository interface for TournamentParticipant entities
abstract class TournamentParticipantRepository extends BaseRepository<TournamentParticipant> {
  /// Finds participants by tournament ID
  Future<List<TournamentParticipant>> findByTournament(String tournamentId);
  
  /// Finds tournaments by user ID
  Future<List<TournamentParticipant>> findByUser(String userId);
  
  /// Checks if a user is already participating in a tournament
  Future<bool> isUserParticipating(String tournamentId, String userId);
  
  /// Joins a user to a tournament
  Future<TournamentParticipant> joinTournament(String tournamentId, String userId);
  
  /// Removes a user from a tournament
  Future<void> leaveTournament(String tournamentId, String userId);
  
  /// Gets the count of participants for a tournament
  Future<int> getParticipantCount(String tournamentId);
} 