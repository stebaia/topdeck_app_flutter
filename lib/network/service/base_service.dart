/// Base service interface for all Supabase services
abstract class BaseService {
  /// The Supabase table name
  String get tableName;

  /// Fetches a record by ID
  Future<Map<String, dynamic>?> getById(String id);
  
  /// Fetches all records from a table
  Future<List<Map<String, dynamic>>> getAll();
  
  /// Inserts a new record
  Future<Map<String, dynamic>> insert(Map<String, dynamic> data);
  
  /// Updates an existing record
  Future<Map<String, dynamic>> update(String id, Map<String, dynamic> data);
  
  /// Deletes a record by ID
  Future<void> delete(String id);
} 