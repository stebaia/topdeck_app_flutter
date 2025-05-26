import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:topdeck_app_flutter/network/service/impl/match_invitation_list_service_impl.dart';
import 'package:topdeck_app_flutter/state_management/blocs/invitation_list/invitation_list_event.dart';
import 'package:topdeck_app_flutter/state_management/blocs/invitation_list/invitation_list_state.dart';

/// BLoC specifico per gestire gli inviti ricevuti
class ReceivedInvitationListBloc extends Bloc<InvitationListEvent, InvitationListState> {
  final MatchInvitationListServiceImpl _invitationService = MatchInvitationListServiceImpl();

  /// Constructor
  ReceivedInvitationListBloc() : super(InvitationListInitialState()) {
    on<LoadInvitationsEvent>(_onLoadInvitations);
    on<RefreshInvitationsEvent>(_onRefreshInvitations);
    on<AcceptInvitationEvent>(_onAcceptInvitation);
    on<AcceptInvitationWithDeckEvent>(_onAcceptInvitationWithDeck);
    on<DeclineInvitationEvent>(_onDeclineInvitation);
    
    // Carica automaticamente gli inviti ricevuti all'avvio
    add(LoadInvitationsEvent());
  }

  Future<void> _onLoadInvitations(
    LoadInvitationsEvent event,
    Emitter<InvitationListState> emit,
  ) async {
    emit(InvitationListLoadingState());

    try {
      final invitations = await _invitationService.getUserInvitations();
      emit(InvitationListLoadedState(invitations, areSentInvitations: false));
    } catch (e) {
      emit(InvitationListErrorState(e.toString(), forSentInvitations: false));
    }
  }

  Future<void> _onRefreshInvitations(
    RefreshInvitationsEvent event,
    Emitter<InvitationListState> emit,
  ) async {
    // Don't show loading state during refresh
    try {
      final invitations = await _invitationService.getUserInvitations();
      emit(InvitationListLoadedState(invitations, areSentInvitations: false));
    } catch (e) {
      emit(InvitationListErrorState(e.toString(), forSentInvitations: false));
    }
  }
  
  Future<void> _onAcceptInvitation(
    AcceptInvitationEvent event,
    Emitter<InvitationListState> emit,
  ) async {
    emit(InvitationProcessingState(event.invitationId));
    
    try {
      // Otteniamo i dettagli dell'invito per mostrarli nella UI di selezione deck
      final client = _invitationService.client;
      final invitation = await client
        .from('match_invitations')
        .select('*, sender:sender_id(username, nome, cognome), receiver:receiver_id(username, nome, cognome)')
        .eq('id', event.invitationId)
        .single();
      
      // Emettiamo lo stato che indica di selezionare un mazzo
      emit(SelectingDeckForInvitationState(invitation));
    } catch (e) {
      emit(InvitationListErrorState(e.toString(), forSentInvitations: false));
    }
  }
  
  Future<void> _onAcceptInvitationWithDeck(
    AcceptInvitationWithDeckEvent event,
    Emitter<InvitationListState> emit,
  ) async {
    emit(InvitationProcessingState(event.invitationId));
    
    try {
      final result = await _invitationService.acceptInvitation(
        event.invitationId, 
        selectedDeckId: event.selectedDeckId
      );
      
      // Controlliamo se è stato creato un match
      if (result.containsKey('match')) {
        emit(MatchCreatedFromInvitationState(
          match: result['match'],
          invitationId: event.invitationId,
        ));
      } else if (result.containsKey('error')) {
        // C'è stato un errore nel creare il match (es. constraint violation)
        final errorMessage = result['error'];
        if (errorMessage.toString().contains('matches_format_check')) {
          emit(InvitationListErrorState(
            'Errore di formato: Il formato del mazzo non è compatibile con questo tipo di match. Verifica i formati supportati.',
            forSentInvitations: false
          ));
        } else {
          emit(InvitationListErrorState(
            'Errore nell\'accettare l\'invito: $errorMessage',
            forSentInvitations: false
          ));
        }
      } else if (result.containsKey('success') && result['success'] == true) {
        // Invito accettato ma match non creato (fallback)
        emit(InvitationAcceptedState(result));
      } else {
        // Se non è stato creato un match, emettiamo solo lo stato di invito accettato
        emit(InvitationAcceptedState(result));
      }
      
      // Ricarica la lista degli inviti dopo l'accettazione (solo se non c'è stato errore)
      if (!result.containsKey('error')) {
        add(LoadInvitationsEvent());
      }
    } catch (e) {
      emit(InvitationListErrorState(e.toString(), forSentInvitations: false));
    }
  }
  
  Future<void> _onDeclineInvitation(
    DeclineInvitationEvent event,
    Emitter<InvitationListState> emit,
  ) async {
    emit(InvitationProcessingState(event.invitationId));
    
    try {
      await _invitationService.declineInvitation(event.invitationId);
      emit(InvitationDeclinedState(event.invitationId));
      
      // Ricarica la lista degli inviti dopo il rifiuto
      add(LoadInvitationsEvent());
    } catch (e) {
      emit(InvitationListErrorState(e.toString(), forSentInvitations: false));
    }
  }
} 