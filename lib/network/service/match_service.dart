/// Interface for match service
abstract class MatchService {
  /// Get all matches
  Future<List<Map<String, dynamic>>> getAll();
  
  /// Get match by ID
  Future<Map<String, dynamic>?> getById(String id);
  
  /// Insert a new match
  Future<Map<String, dynamic>> insert(Map<String, dynamic> data);
  
  /// Update a match
  Future<Map<String, dynamic>> update(String id, Map<String, dynamic> data);
  
  /// Update the winner of a match
  Future<Map<String, dynamic>> updateWinner(String matchId, String winnerId);
  
  /// Delete a match
  Future<void> delete(String id);
  
  /// Finds matches by player ID (either player1 or player2)
  Future<List<Map<String, dynamic>>> findByPlayerId(String playerId);
  
  /// Finds matches by format
  Future<List<Map<String, dynamic>>> findByFormat(String format);
  
  /// Finds matches by winner ID
  Future<List<Map<String, dynamic>>> findByWinnerId(String winnerId);
  
  /// Get matches for the current user
  Future<List<Map<String, dynamic>>> getUserMatches();
} 