import 'package:topdeck_app_flutter/model/base_model.dart';

/// Base repository interface for all repositories
abstract class BaseRepository<T extends BaseModel> {
  /// Fetches a single entity by ID
  Future<T?> get(String id);
  
  /// Fetches all entities
  Future<List<T>> getAll();
  
  /// Creates a new entity
  Future<T> create(T entity);
  
  /// Updates an existing entity
  Future<T> update(T entity);
  
  /// Deletes an entity by ID
  Future<void> delete(String id);
} 