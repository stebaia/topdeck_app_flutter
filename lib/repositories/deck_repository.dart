import 'package:topdeck_app_flutter/model/entities/deck.dart';
import 'package:topdeck_app_flutter/repositories/base_repository.dart';

/// Repository interface for Deck entities
abstract class DeckRepository extends BaseRepository<Deck> {
  /// Finds decks by user ID
  Future<List<Deck>> findByUserId(String userId);
  
  /// Finds all shared decks
  Future<List<Deck>> findSharedDecks();
  
  /// Finds decks by format
  Future<List<Deck>> findByFormat(DeckFormat format);
  
  /// Updates the shared status of a deck
  Future<Deck> updateSharedStatus(String id, bool shared);
} 