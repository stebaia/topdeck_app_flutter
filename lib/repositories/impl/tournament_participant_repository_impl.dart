import 'package:topdeck_app_flutter/model/entities/tournament_participant.dart';
import 'package:topdeck_app_flutter/network/service/impl/tournament_participant_service_impl.dart';
import 'package:topdeck_app_flutter/repositories/tournament_participant_repository.dart';

/// Implementation of the TournamentParticipantRepository
class TournamentParticipantRepositoryImpl implements TournamentParticipantRepository {
  /// The tournament participant service
  final TournamentParticipantServiceImpl _service;

  /// Constructor
  TournamentParticipantRepositoryImpl(this._service);

  @override
  Future<TournamentParticipant> create(TournamentParticipant entity) async {
    final json = await _service.insert(entity.toJson());
    return TournamentParticipant.fromJson(json);
  }

  @override
  Future<void> delete(String id) async {
    await _service.delete(id);
  }

  @override
  Future<TournamentParticipant?> get(String id) async {
    final json = await _service.getById(id);
    if (json == null) return null;
    return TournamentParticipant.fromJson(json);
  }

  @override
  Future<List<TournamentParticipant>> getAll() async {
    final jsonList = await _service.getAll();
    return jsonList.map((json) => TournamentParticipant.fromJson(json)).toList();
  }

  @override
  Future<TournamentParticipant> update(TournamentParticipant entity) async {
    final json = await _service.update(entity.id, entity.toJson());
    return TournamentParticipant.fromJson(json);
  }

  @override
  Future<List<TournamentParticipant>> findByTournament(String tournamentId) async {
    final jsonList = await _service.findByTournament(tournamentId);
    return jsonList.map((json) => TournamentParticipant.fromJson(json)).toList();
  }

  @override
  Future<List<TournamentParticipant>> findByUser(String userId) async {
    final jsonList = await _service.findByUser(userId);
    return jsonList.map((json) => TournamentParticipant.fromJson(json)).toList();
  }

  @override
  Future<bool> isUserParticipating(String tournamentId, String userId) async {
    return await _service.isUserParticipating(tournamentId, userId);
  }

  @override
  Future<TournamentParticipant> joinTournament(String tournamentId, String userId) async {
    final json = await _service.joinTournament(tournamentId, userId);
    return TournamentParticipant.fromJson(json);
  }

  @override
  Future<void> leaveTournament(String tournamentId, String userId) async {
    await _service.leaveTournament(tournamentId, userId);
  }

  @override
  Future<int> getParticipantCount(String tournamentId) async {
    return await _service.getParticipantCount(tournamentId);
  }
} 