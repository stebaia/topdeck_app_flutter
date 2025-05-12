import 'package:topdeck_app_flutter/model/entities/deck_card.dart';
import 'package:topdeck_app_flutter/repositories/base_repository.dart';

/// Repository interface for DeckCard entities
abstract class DeckCardRepository extends BaseRepository<DeckCard> {
  /// Finds cards by deck ID
  Future<List<DeckCard>> findByDeckId(String deckId);
  
  /// Updates the quantity of a card in a deck
  Future<DeckCard> updateQuantity(String id, int quantity);
  
  /// Deletes all cards in a deck
  Future<void> deleteByDeckId(String deckId);
} 