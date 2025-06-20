import 'package:topdeck_app_flutter/model/entities/match_invitation.dart';
import 'package:topdeck_app_flutter/network/service/impl/match_invitation_list_service_impl.dart';
import 'package:topdeck_app_flutter/network/service/impl/match_invitation_service_impl.dart';
import 'package:topdeck_app_flutter/repositories/match_invitation_repository.dart';

/// Implementation of the MatchInvitationRepository
class MatchInvitationRepositoryImpl implements MatchInvitationRepository {
  /// The match invitation list service
  final MatchInvitationListServiceImpl _listService;
  
  /// The match invitation service
  final MatchInvitationServiceImpl _invitationService;

  /// Constructor
  MatchInvitationRepositoryImpl(this._listService, this._invitationService);

  @override
  Future<MatchInvitation> create(MatchInvitation entity) async {
    final result = await _invitationService.sendInvitation(
      receiverId: entity.receiverId!,
      format: entity.format,
      message: entity.message,
    );
    
    // Se il service ritorna un ID, creiamo un'entità con quell'ID
    if (result.containsKey('invitation_id')) {
      return entity.copyWith(id: result['invitation_id']);
    }
    
    return entity;
  }

  @override
  Future<void> delete(String id) async {
    // Per ora non implementiamo la cancellazione diretta
    // Si potrebbe implementare cambiando lo status a 'cancelled'
    throw UnimplementedError('Direct deletion not implemented. Use declineInvitation instead.');
  }

  @override
  Future<MatchInvitation?> get(String id) async {
    // Implementazione per ottenere un singolo invito
    // Dovremmo aggiungere questo metodo al service se necessario
    throw UnimplementedError('Single invitation retrieval not yet implemented in service layer');
  }

  @override
  Future<List<MatchInvitation>> getAll() async {

    final getAllInvitations = await _listService.getAllInvitations();
    return getAllInvitations.map((json) => MatchInvitation.fromEdgeFunctionResponse(json)).toList();
  }

  @override
  Future<MatchInvitation> update(MatchInvitation entity) async {
    // Per ora supportiamo solo l'aggiornamento dello status
    if (entity.status == MatchInvitationStatus.accepted) {
      await acceptInvitation(entity.id);
    } else if (entity.status == MatchInvitationStatus.declined) {
      await declineInvitation(entity.id);
    }
    
    return entity;
  }

  Future<List<MatchInvitation>> getAllInvitations() async {
    final jsonList = await _listService.getAllInvitations();
    return jsonList.map((json) => MatchInvitation.fromEdgeFunctionResponse(json)).toList();
  }



  @override
  Future<List<MatchInvitation>> findByStatus(MatchInvitationStatus status) async {
    final allInvitations = await getAll();
    return allInvitations.where((invitation) => invitation.status == status).toList();
  }

  @override
  Future<List<MatchInvitation>> findTodaysPendingInvitations() async {
    final pendingInvitations = await findByStatus(MatchInvitationStatus.pending);
    return pendingInvitations.where((invitation) => invitation.isFromToday).toList();
  }

  @override
  Future<Map<String, dynamic>> acceptInvitation(String invitationId, {String? selectedDeckId}) async {
    return await _listService.acceptInvitation(invitationId, selectedDeckId: selectedDeckId);
  }

  @override
  Future<void> declineInvitation(String invitationId) async {
    await _listService.declineInvitation(invitationId);
  }

  @override
  Future<MatchInvitation> updateStatus(String id, MatchInvitationStatus status) async {
    if (status == MatchInvitationStatus.accepted) {
      await acceptInvitation(id);
    } else if (status == MatchInvitationStatus.declined) {
      await declineInvitation(id);
    }
    
    // Ritorniamo l'invito aggiornato (in un'implementazione reale dovremmo ricaricarlo)
    // Per ora creiamo un placeholder
    return MatchInvitation(
      id: id,
      format: 'unknown',
      status: status,
    );
  }

  @override
  Future<MatchInvitation> sendInvitation({
    required String receiverId,
    required String format,
    String? message,
  }) async {
    final result = await _invitationService.sendInvitation(
      receiverId: receiverId,
      format: format,
      message: message,
    );
    
    // Creiamo un'entità MatchInvitation dal risultato
    return MatchInvitation.create(
      senderId: 'current_user', // Dovremmo ottenere l'ID dell'utente corrente
      receiverId: receiverId,
      format: format,
      message: message,
    );
  }

  @override
  Future<bool> isInvitationExpired(String invitationId) async {
    // Per ora usiamo la logica del modello
    // In futuro potremmo implementare una chiamata specifica al backend
    try {
      final invitation = await get(invitationId);
      return invitation?.isExpired ?? false;
    } catch (e) {
      // Se non riusciamo a ottenere l'invito, consideriamolo scaduto
      return true;
    }
  }

  @override
  Future<List<MatchInvitation>> getExpiringInvitations() async {
    final pendingInvitations = await findByStatus(MatchInvitationStatus.pending);
    
    return pendingInvitations.where((invitation) {
      if (invitation.createdAt == null) return false;
      
      final now = DateTime.now();
      final expirationTime = invitation.createdAt!.add(const Duration(hours: 24));
      final timeToExpiry = expirationTime.difference(now);
      
      // Inviti che scadono entro 1 ora
      return timeToExpiry.inHours <= 1 && timeToExpiry.inMinutes > 0;
    }).toList();
  }

  @override
  Future<MatchInvitation?> findPendingInvitationBetweenUsers(String senderId, String receiverId) async {
    final pendingInvitations = await findByStatus(MatchInvitationStatus.pending);
    
    try {
      return pendingInvitations.firstWhere(
        (invitation) => 
          invitation.senderId == senderId && 
          invitation.receiverId == receiverId,
      );
    } catch (e) {
      return null;
    }
  }
} 