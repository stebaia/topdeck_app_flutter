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
    final json = await _service.insert(entity.toJson());
    return Deck.fromJson(json);
  }

  @override
  Future<void> delete(String id) async {
    await _service.delete(id);
  }

  @override
  Future<List<Deck>> findByFormat(DeckFormat format) async {
    final jsonList = await _service.findByFormat(format);
    return jsonList.map((json) => Deck.fromJson(json)).toList();
  }

  @override
  Future<List<Deck>> findByUserId(String userId) async {
    final jsonList = await _service.findByUserId(userId);
    return jsonList.map((json) => Deck.fromJson(json)).toList();
  }

  @override
  Future<List<Deck>> findSharedDecks() async {
    final jsonList = await _service.findSharedDecks();
    return jsonList.map((json) => Deck.fromJson(json)).toList();
  }

  @override
  Future<Deck?> get(String id) async {
    final json = await _service.getById(id);
    if (json == null) return null;
    return Deck.fromJson(json);
  }

  @override
  Future<List<Deck>> getAll() async {
    final jsonList = await _service.getAll();
    return jsonList.map((json) => Deck.fromJson(json)).toList();
  }

  @override
  Future<Deck> update(Deck entity) async {
    final json = await _service.update(entity.id, entity.toJson());
    return Deck.fromJson(json);
  }

  @override
  Future<Deck> updateSharedStatus(String id, bool shared) async {
    final json = await _service.updateSharedStatus(id, shared);
    return Deck.fromJson(json);
  }
} 