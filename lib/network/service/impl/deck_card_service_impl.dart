import 'package:topdeck_app_flutter/network/service/impl/base_service_impl.dart';

/// Service implementation for the deck_cards table
class DeckCardServiceImpl extends BaseServiceImpl {
  @override
  String get tableName => 'deck_cards';
  
  /// Finds cards by deck ID
  Future<List<Map<String, dynamic>>> findByDeckId(String deckId) async {
    final response = await client.from(tableName)
        .select()
        .eq('deck_id', deckId);
    return response;
  }
  
  /// Updates the quantity of a card in a deck
  Future<Map<String, dynamic>> updateQuantity(String id, int quantity) async {
    final response = await client.from(tableName)
        .update({'quantity': quantity})
        .eq('id', id)
        .select()
        .single();
    return response;
  }
  
  /// Deletes all cards in a deck
  Future<void> deleteByDeckId(String deckId) async {
    await client.from(tableName).delete().eq('deck_id', deckId);
  }
} 