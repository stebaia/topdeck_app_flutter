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
} 