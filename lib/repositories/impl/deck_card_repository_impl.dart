import 'package:topdeck_app_flutter/model/entities/deck_card.dart';
import 'package:topdeck_app_flutter/network/service/impl/deck_card_service_impl.dart';
import 'package:topdeck_app_flutter/repositories/deck_card_repository.dart';

/// Implementation of the DeckCardRepository
class DeckCardRepositoryImpl implements DeckCardRepository {
  /// The deck card service
  final DeckCardServiceImpl _service;

  /// Constructor
  DeckCardRepositoryImpl(this._service);

  @override
  Future<DeckCard> create(DeckCard entity) async {
    final json = await _service.insert(entity.toJson());
    return DeckCard.fromJson(json);
  }

  @override
  Future<void> delete(String id) async {
    await _service.delete(id);
  }

  @override
  Future<void> deleteByDeckId(String deckId) async {
    await _service.deleteByDeckId(deckId);
  }

  @override
  Future<List<DeckCard>> findByDeckId(String deckId) async {
    final jsonList = await _service.findByDeckId(deckId);
    return jsonList.map((json) => DeckCard.fromJson(json)).toList();
  }

  @override
  Future<DeckCard?> get(String id) async {
    final json = await _service.getById(id);
    if (json == null) return null;
    return DeckCard.fromJson(json);
  }

  @override
  Future<List<DeckCard>> getAll() async {
    final jsonList = await _service.getAll();
    return jsonList.map((json) => DeckCard.fromJson(json)).toList();
  }

  @override
  Future<DeckCard> update(DeckCard entity) async {
    final json = await _service.update(entity.id, entity.toJson());
    return DeckCard.fromJson(json);
  }

  @override
  Future<DeckCard> updateQuantity(String id, int quantity) async {
    final json = await _service.updateQuantity(id, quantity);
    return DeckCard.fromJson(json);
  }
} 