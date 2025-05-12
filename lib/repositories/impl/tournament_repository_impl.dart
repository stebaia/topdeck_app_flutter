import 'package:topdeck_app_flutter/model/entities/tournament.dart';
import 'package:topdeck_app_flutter/network/service/impl/tournament_service_impl.dart';
import 'package:topdeck_app_flutter/repositories/tournament_repository.dart';

/// Implementation of the TournamentRepository
class TournamentRepositoryImpl implements TournamentRepository {
  /// The tournament service
  final TournamentServiceImpl _service;

  /// Constructor
  TournamentRepositoryImpl(this._service);

  @override
  Future<Tournament> create(Tournament entity) async {
    final json = await _service.insert(entity.toJson());
    return Tournament.fromJson(json);
  }

  @override
  Future<void> delete(String id) async {
    await _service.delete(id);
  }

  @override
  Future<List<Tournament>> findByCreator(String creatorId) async {
    final jsonList = await _service.findByCreator(creatorId);
    return jsonList.map((json) => Tournament.fromJson(json)).toList();
  }

  @override
  Future<List<Tournament>> findByFormat(String format) async {
    final jsonList = await _service.findByFormat(format);
    return jsonList.map((json) => Tournament.fromJson(json)).toList();
  }

  @override
  Future<List<Tournament>> findByStatus(TournamentStatus status) async {
    final jsonList = await _service.findByStatus(status);
    return jsonList.map((json) => Tournament.fromJson(json)).toList();
  }

  @override
  Future<Tournament?> get(String id) async {
    final json = await _service.getById(id);
    if (json == null) return null;
    return Tournament.fromJson(json);
  }

  @override
  Future<List<Tournament>> getAll() async {
    final jsonList = await _service.getAll();
    return jsonList.map((json) => Tournament.fromJson(json)).toList();
  }

  @override
  Future<Tournament> update(Tournament entity) async {
    final json = await _service.update(entity.id, entity.toJson());
    return Tournament.fromJson(json);
  }

  @override
  Future<Tournament> updateStatus(String id, TournamentStatus status) async {
    final json = await _service.updateStatus(id, status);
    return Tournament.fromJson(json);
  }
} 