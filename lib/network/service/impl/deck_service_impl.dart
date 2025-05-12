import 'package:topdeck_app_flutter/model/entities/deck.dart';
import 'package:topdeck_app_flutter/network/service/impl/base_service_impl.dart';

/// Service implementation for the decks table
class DeckServiceImpl extends BaseServiceImpl {
  @override
  String get tableName => 'decks';
  
  /// Finds decks by user ID
  Future<List<Map<String, dynamic>>> findByUserId(String userId) async {
    final response = await client.from(tableName)
        .select()
        .eq('user_id', userId);
    return response;
  }
  
  /// Finds all shared decks
  Future<List<Map<String, dynamic>>> findSharedDecks() async {
    final response = await client.from(tableName)
        .select()
        .eq('shared', true);
    return response;
  }
  
  /// Finds decks by format
  Future<List<Map<String, dynamic>>> findByFormat(DeckFormat format) async {
    final response = await client.from(tableName)
        .select()
        .eq('format', format.name);
    return response;
  }
  
  /// Updates the shared status of a deck
  Future<Map<String, dynamic>> updateSharedStatus(String id, bool shared) async {
    final response = await client.from(tableName)
        .update({'shared': shared})
        .eq('id', id)
        .select()
        .single();
    return response;
  }
} 