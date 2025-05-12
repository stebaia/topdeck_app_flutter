import 'package:topdeck_app_flutter/model/entities/match.dart';
import 'package:topdeck_app_flutter/network/service/impl/match_service_impl.dart';
import 'package:topdeck_app_flutter/repositories/match_repository.dart';

/// Implementation of the MatchRepository
class MatchRepositoryImpl implements MatchRepository {
  /// The match service
  final MatchServiceImpl _service;

  /// Constructor
  MatchRepositoryImpl(this._service);

  @override
  Future<Match> create(Match entity) async {
    final json = await _service.insert(entity.toJson());
    return Match.fromJson(json);
  }

  @override
  Future<void> delete(String id) async {
    await _service.delete(id);
  }

  @override
  Future<List<Match>> findByFormat(String format) async {
    final jsonList = await _service.findByFormat(format);
    return jsonList.map((json) => Match.fromJson(json)).toList();
  }

  @override
  Future<List<Match>> findByPlayerId(String playerId) async {
    final jsonList = await _service.findByPlayerId(playerId);
    return jsonList.map((json) => Match.fromJson(json)).toList();
  }

  @override
  Future<List<Match>> findByWinnerId(String winnerId) async {
    final jsonList = await _service.findByWinnerId(winnerId);
    return jsonList.map((json) => Match.fromJson(json)).toList();
  }

  @override
  Future<Match?> get(String id) async {
    final json = await _service.getById(id);
    if (json == null) return null;
    return Match.fromJson(json);
  }

  @override
  Future<List<Match>> getAll() async {
    final jsonList = await _service.getAll();
    return jsonList.map((json) => Match.fromJson(json)).toList();
  }

  @override
  Future<Match> update(Match entity) async {
    final json = await _service.update(entity.id, entity.toJson());
    return Match.fromJson(json);
  }

  @override
  Future<Match> updateWinner(String matchId, String winnerId) async {
    final json = await _service.updateWinner(matchId, winnerId);
    return Match.fromJson(json);
  }
} 