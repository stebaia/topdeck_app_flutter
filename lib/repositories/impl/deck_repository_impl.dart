import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:topdeck_app_flutter/model/entities/deck.dart';
import 'package:topdeck_app_flutter/network/service/impl/deck_service_impl.dart';
import 'package:topdeck_app_flutter/repositories/deck_repository.dart';

/// Implementation of the DeckRepository
class DeckRepositoryImpl implements DeckRepository {
  /// The deck service
  final DeckServiceImpl _service;

  /// Constructor
  DeckRepositoryImpl(this._service);

  @override
  Future<Deck> create(Deck entity) async {
    final json = await _service.createDeck(
      name: entity.name,
      format: entity.format.toString().split('.').last,
      shared: entity.shared ?? false,
    );
    return Deck.fromJson({
      'id': json['deck_id'],
      'user_id': entity.userId,
      'name': entity.name,
      'format': entity.format.toString().split('.').last,
      'shared': entity.shared,
    });
  }

  @override
  Future<void> delete(String id) async {
    await _service.deleteDeck(id);
  }

  @override
  Future<List<Deck>> findByFormat(DeckFormat format) async {
    try {
      final jsonList = await _service.listDecks();
      final formatString = format.toString().split('.').last;
      
      List<Deck> decks = [];
      for (var json in jsonList) {
        if (json['format'] == formatString) {
          try {
            final deck = Deck.fromJson(json);
            decks.add(deck);
          } catch (e) {
            print('Error parsing deck from JSON in findByFormat: $e, json: $json');
          }
        }
      }
      
      return decks;
    } on AuthException catch (e) {
      throw AuthException('Error loading decks: ${e.message}');
    } catch (e) {
      print('Exception in findByFormat: $e');
      return [];
    }
  }

  @override
  Future<List<Deck>> findByUserId(String userId) async {
    try {
      // All decks from listDecks are the current user's decks
      final jsonList = await _service.listDecks();
      
      List<Deck> decks = [];
      for (var json in jsonList) {
        try {
          final deck = Deck.fromJson(json);
          decks.add(deck);
        } catch (e) {
          print('Error parsing deck from JSON in findByUserId: $e, json: $json');
        }
      }
      
      return decks;
    } catch (e) {
      print('Exception in findByUserId: $e');
      return [];
    }
  }

  @override
  Future<List<Deck>> findSharedDecks() async {
    try {
      final jsonList = await _service.listDecks();
      
      List<Deck> decks = [];
      for (var json in jsonList) {
        if (json['shared'] == true) {
          try {
            final deck = Deck.fromJson(json);
            decks.add(deck);
          } catch (e) {
            print('Error parsing deck from JSON in findSharedDecks: $e, json: $json');
          }
        }
      }
      
      return decks;
    } catch (e) {
      print('Exception in findSharedDecks: $e');
      return [];
    }
  }

  @override
  Future<Deck?> get(String id) async {
    final response = await _service.getDeckDetails(id);
    if (response['deck'] == null) return null;
    return Deck.fromJson(response['deck']);
  }

  @override
  Future<List<Deck>> getAll() async {
    try {
      final jsonList = await _service.listDecks();
      
      // Aggiungo log per debug
      print('DeckRepository getAll received ${jsonList.length} decks');
      
      List<Deck> decks = [];
      for (var json in jsonList) {
        try {
          final deck = Deck.fromJson(json);
          decks.add(deck);
        } catch (e) {
          print('Error parsing deck from JSON: $e, json: $json');
          // Continuiamo con il prossimo deck se uno fallisce
        }
      }
      
      print('DeckRepository getAll returning ${decks.length} valid decks');
      return decks;
    } on AuthException catch (e) {
      print('Auth exception in getAll: ${e.message}');
      throw AuthException('Error loading decks: ${e.message}');
    } catch (e) {
      print('General exception in getAll: $e');
      // In caso di errore nell'intera operazione, ritorniamo una lista vuota
      return [];
    }
  }

  @override
  Future<Deck> update(Deck entity) async {
    await _service.editDeck(
      deckId: entity.id,
      name: entity.name,
      format: entity.format.toString().split('.').last,
      shared: entity.shared,
    );
    return entity;
  }

  @override
  Future<Deck> updateSharedStatus(String id, bool shared) async {
    await _service.editDeck(
      deckId: id,
      shared: shared,
    );
    
    final deckDetails = await _service.getDeckDetails(id);
    return Deck.fromJson(deckDetails['deck']);
  }
  
  @override
  Future<List<Deck>> getPublicDecksByUser(String userId) async {
    try {
      final jsonList = await _service.getPublicDecksByUser(userId);
      
      List<Deck> decks = [];
      for (var json in jsonList) {
        try {
          final deck = Deck.fromJson(json);
          decks.add(deck);
        } catch (e) {
          print('Error parsing deck from JSON in getPublicDecksByUser: $e, json: $json');
        }
      }
      
      return decks;
    } catch (e) {
      print('Exception in getPublicDecksByUser: $e');
      return [];
    }
  }
} 