import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:topdeck_app_flutter/network/supabase_config.dart';

/// Service implementation for deck operations using Edge Functions
class DeckServiceImpl {
  /// The Supabase client
  final SupabaseClient client = supabase;
  
  /// Lists all decks for the current user
  Future<List<Map<String, dynamic>>> listDecks() async {
    try {
      final response = await client.functions.invoke('list-deck');
      
      if (response.status != 200) {
        throw Exception(response.data['error'] ?? 'Failed to list decks');
      }
      
      return (response.data as List).cast<Map<String, dynamic>>();
    } catch (e) {
      throw Exception('Failed to list decks: $e');
    }
  }
  
  /// Gets deck details
  Future<Map<String, dynamic>> getDeckDetails(String deckId) async {
    try {
      final response = await client.functions.invoke(
        'deck-detail',
        body: {'deck_id': deckId},
      );
      
      if (response.status != 200) {
        throw Exception(response.data['error'] ?? 'Failed to get deck details');
      }
      
      return response.data;
    } catch (e) {
      throw Exception('Failed to get deck details: $e');
    }
  }
  
  /// Get public decks for a user (for opponent deck selection)
  Future<List<Map<String, dynamic>>> getPublicDecksByUser(String userId) async {
    try {
      // This uses the database query directly since there's no edge function for this specific operation
      final response = await client
        .from('decks')
        .select('id, name, format')
        .eq('user_id', userId)
        .eq('shared', true);
      
      return response;
    } catch (e) {
      throw Exception('Failed to get public decks: $e');
    }
  }
  
  /// Creates a new deck
  Future<Map<String, dynamic>> createDeck({
    required String name,
    required String format,
    bool shared = false,
  }) async {
    try {
      final response = await client.functions.invoke(
        'create-deck',
        body: {
          'name': name,
          'format': format,
          'shared': shared,
        },
      );
      
      if (response.status != 200) {
        throw Exception(response.data['error'] ?? 'Failed to create deck');
      }
      
      return response.data;
    } catch (e) {
      throw Exception('Failed to create deck: $e');
    }
  }
  
  /// Edits an existing deck
  Future<Map<String, dynamic>> editDeck({
    required String deckId,
    String? name,
    String? format,
    bool? shared,
  }) async {
    try {
      final response = await client.functions.invoke(
        'edit-deck',
        body: {
          'deck_id': deckId,
          if (name != null) 'name': name,
          if (format != null) 'format': format,
          if (shared != null) 'shared': shared,
        },
      );
      
      if (response.status != 200) {
        throw Exception(response.data['error'] ?? 'Failed to edit deck');
      }
      
      return response.data;
    } catch (e) {
      throw Exception('Failed to edit deck: $e');
    }
  }
  
  /// Deletes a deck
  Future<Map<String, dynamic>> deleteDeck(String deckId) async {
    try {
      final response = await client.functions.invoke(
        'delete-deck',
        body: {'deck_id': deckId},
      );
      
      if (response.status != 200) {
        throw Exception(response.data['error'] ?? 'Failed to delete deck');
      }
      
      return response.data;
    } catch (e) {
      throw Exception('Failed to delete deck: $e');
    }
  }
} 