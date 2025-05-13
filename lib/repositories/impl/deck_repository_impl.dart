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
    final jsonList = await _service.listDecks();
    return jsonList
        .where((json) => json['format'] == format.toString().split('.').last)
        .map((json) => Deck.fromJson(json))
        .toList();
  }

  @override
  Future<List<Deck>> findByUserId(String userId) async {
    // All decks from listDecks are the current user's decks
    final jsonList = await _service.listDecks();
    return jsonList.map((json) => Deck.fromJson(json)).toList();
  }

  @override
  Future<List<Deck>> findSharedDecks() async {
    final jsonList = await _service.listDecks();
    return jsonList
        .where((json) => json['shared'] == true)
        .map((json) => Deck.fromJson(json))
        .toList();
  }

  @override
  Future<Deck?> get(String id) async {
    final response = await _service.getDeckDetails(id);
    if (response['deck'] == null) return null;
    return Deck.fromJson(response['deck']);
  }

  @override
  Future<List<Deck>> getAll() async {
    final jsonList = await _service.listDecks();
    return jsonList.map((json) => Deck.fromJson(json)).toList();
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
} 