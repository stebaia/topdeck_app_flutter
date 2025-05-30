import 'package:topdeck_app_flutter/model/entities/tournament_invitation.dart';
import 'package:topdeck_app_flutter/network/service/impl/tournament_invitation_service_impl.dart';
import 'package:topdeck_app_flutter/repositories/tournament_invitation_repository.dart';

/// Implementation of the TournamentInvitationRepository
class TournamentInvitationRepositoryImpl implements TournamentInvitationRepository {
  /// The tournament invitation service
  final TournamentInvitationServiceImpl _service;

  /// Constructor
  TournamentInvitationRepositoryImpl(this._service);

  @override
  Future<TournamentInvitation> create(TournamentInvitation entity) async {
    final json = await _service.insert(entity.toJson());
    return TournamentInvitation.fromJson(json);
  }

  @override
  Future<void> delete(String id) async {
    await _service.delete(id);
  }

  @override
  Future<TournamentInvitation?> get(String id) async {
    final json = await _service.getById(id);
    if (json == null) return null;
    return TournamentInvitation.fromJson(json);
  }

  @override
  Future<List<TournamentInvitation>> getAll() async {
    final jsonList = await _service.getAll();
    return jsonList.map((json) => TournamentInvitation.fromJson(json)).toList();
  }

  @override
  Future<TournamentInvitation> update(TournamentInvitation entity) async {
    final json = await _service.update(entity.id, entity.toJson());
    return TournamentInvitation.fromJson(json);
  }

  @override
  Future<List<TournamentInvitation>> findByTournament(String tournamentId) async {
    final jsonList = await _service.findByTournament(tournamentId);
    return jsonList.map((json) => TournamentInvitation.fromJson(json)).toList();
  }

  @override
  Future<List<TournamentInvitation>> findByReceiver(String receiverId) async {
    final jsonList = await _service.findByReceiver(receiverId);
    return jsonList.map((json) => TournamentInvitation.fromJson(json)).toList();
  }

  @override
  Future<List<TournamentInvitation>> findBySender(String senderId) async {
    final jsonList = await _service.findBySender(senderId);
    return jsonList.map((json) => TournamentInvitation.fromJson(json)).toList();
  }

  @override
  Future<List<TournamentInvitation>> findByStatus(TournamentInvitationStatus status) async {
    final jsonList = await _service.findByStatus(status);
    return jsonList.map((json) => TournamentInvitation.fromJson(json)).toList();
  }

  @override
  Future<TournamentInvitation> updateStatus(String id, TournamentInvitationStatus status) async {
    final json = await _service.updateStatus(id, status);
    return TournamentInvitation.fromJson(json);
  }

  @override
  Future<TournamentInvitation?> findPendingInvitation(String tournamentId, String receiverId) async {
    final json = await _service.findPendingInvitation(tournamentId, receiverId);
    if (json == null) return null;
    return TournamentInvitation.fromJson(json);
  }
} 