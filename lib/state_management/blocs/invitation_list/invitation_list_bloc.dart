import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:topdeck_app_flutter/repositories/match_invitation_repository.dart';
import 'package:topdeck_app_flutter/state_management/blocs/invitation_list/invitation_list_event.dart';
import 'package:topdeck_app_flutter/state_management/blocs/invitation_list/invitation_list_state.dart';

/// BLoC for managing match invitation listings
class InvitationListBloc extends Bloc<InvitationListEvent, InvitationListState> {
  final MatchInvitationRepository _repository;
  final bool isForSentInvitations;

  /// Constructor
  InvitationListBloc(this._repository, {this.isForSentInvitations = false}) : super(InvitationListInitialState()) {
    on<LoadInvitationsEvent>(_onLoadInvitations);
    on<RefreshInvitationsEvent>(_onRefreshInvitations);
    on<LoadSentInvitationsEvent>(_onLoadSentInvitations);
    on<RefreshSentInvitationsEvent>(_onRefreshSentInvitations);
    on<ToggleInvitationViewEvent>(_onToggleView);
    on<AcceptInvitationEvent>(_onAcceptInvitation);
    on<AcceptInvitationWithDeckEvent>(_onAcceptInvitationWithDeck);
    on<DeclineInvitationEvent>(_onDeclineInvitation);
    
    // Carica automaticamente il tipo appropriato di inviti all'avvio
    if (isForSentInvitations) {
      add(LoadSentInvitationsEvent());
    } else {
      add(LoadInvitationsEvent());
    }
  }

  void loadInvitations() => add(LoadInvitationsEvent());


  /// Getter per verificare se stiamo mostrando gli inviti inviati
  bool get showingSentInvitations => isForSentInvitations;

  Future<void> _onLoadInvitations(
    LoadInvitationsEvent event,
    Emitter<InvitationListState> emit,
  ) async {
    if (isForSentInvitations) return; // Ignora se questo bloc è per inviti inviati
    
    emit(InvitationListLoadingState());

    try {
      final invitations = await _repository.getAll();
      final jsonInvitations = invitations.map((inv) => inv.toJson()).toList();
      emit(InvitationListLoadedState(jsonInvitations, areSentInvitations: false));
    } catch (e) {
      emit(InvitationListErrorState(e.toString(), forSentInvitations: false));
    }
  }

  Future<void> _onRefreshInvitations(
    RefreshInvitationsEvent event,
    Emitter<InvitationListState> emit,
  ) async {
    if (isForSentInvitations) return; // Ignora se questo bloc è per inviti inviati
    
    // Don't show loading state during refresh
    try {
      final invitations = await _repository.getAll();
      final jsonInvitations = invitations.map((inv) => inv.toJson()).toList();
      emit(InvitationListLoadedState(jsonInvitations, areSentInvitations: false));
    } catch (e) {
      emit(InvitationListErrorState(e.toString(), forSentInvitations: false));
    }
  }
  
  Future<void> _onLoadSentInvitations(
    LoadSentInvitationsEvent event,
    Emitter<InvitationListState> emit,
  ) async {
    if (!isForSentInvitations) return; // Ignora se questo bloc è per inviti ricevuti
    
    emit(SentInvitationsLoadingState());

    try {
      final invitations = await _repository.getAll();
      final jsonInvitations = invitations.map((inv) => inv.toJson()).toList();
      emit(InvitationListLoadedState(jsonInvitations, areSentInvitations: true));
    } catch (e) {
      emit(InvitationListErrorState(e.toString(), forSentInvitations: true));
    }
  }

  Future<void> _onRefreshSentInvitations(
    RefreshSentInvitationsEvent event,
    Emitter<InvitationListState> emit,
  ) async {
    if (!isForSentInvitations) return; // Ignora se questo bloc è per inviti ricevuti
    
    // Don't show loading state during refresh
    try {
      final invitations = await _repository.getAll();
      final jsonInvitations = invitations.map((inv) => inv.toJson()).toList();
      emit(InvitationListLoadedState(jsonInvitations, areSentInvitations: true));
    } catch (e) {
      emit(InvitationListErrorState(e.toString(), forSentInvitations: true));
    }
  }
  
  void _onToggleView(
    ToggleInvitationViewEvent event,
    Emitter<InvitationListState> emit,
  ) {
    // Questo metodo ora è un no-op perché ogni bloc è dedicato a un tipo di inviti
    // Ignora il comando di toggle poiché non è più applicabile
    // Il toggle dovrebbe essere gestito a livello di UI
  }
  
  Future<void> _onAcceptInvitation(
    AcceptInvitationEvent event,
    Emitter<InvitationListState> emit,
  ) async {
    if (isForSentInvitations) return; // Solo gli inviti ricevuti possono essere accettati
    
    emit(InvitationProcessingState(event.invitationId));
    
    try {
      // Per ora usiamo un placeholder per l'invito
      // In futuro implementeremo il metodo get nel repository
      final placeholderInvitation = {
        'id': event.invitationId,
        'status': 'pending',
      };
      
      // Emettiamo lo stato che indica di selezionare un mazzo
      emit(SelectingDeckForInvitationState(placeholderInvitation));
    } catch (e) {
      emit(InvitationListErrorState(e.toString(), forSentInvitations: false));
    }
  }
  
  Future<void> _onAcceptInvitationWithDeck(
    AcceptInvitationWithDeckEvent event,
    Emitter<InvitationListState> emit,
  ) async {
    if (isForSentInvitations) return; // Solo gli inviti ricevuti possono essere accettati
    
    emit(InvitationProcessingState(event.invitationId));
    
    try {
      final result = await _repository.acceptInvitation(
        event.invitationId, 
        selectedDeckId: event.selectedDeckId
      );
      
      // Controlliamo se è stato creato un match
      if (result.containsKey('match')) {
        emit(MatchCreatedFromInvitationState(
          match: result['match'],
          invitationId: event.invitationId,
        ));
      } else {
        // Se non è stato creato un match, emettiamo solo lo stato di invito accettato
        emit(InvitationAcceptedState(result));
      }
      
      // Ricarica la lista degli inviti dopo l'accettazione
      add(LoadInvitationsEvent());
    } catch (e) {
      emit(InvitationListErrorState(e.toString(), forSentInvitations: false));
    }
  }
  
  Future<void> _onDeclineInvitation(
    DeclineInvitationEvent event,
    Emitter<InvitationListState> emit,
  ) async {
    if (isForSentInvitations) return; // Solo gli inviti ricevuti possono essere rifiutati
    
    emit(InvitationProcessingState(event.invitationId));
    
    try {
      await _repository.declineInvitation(event.invitationId);
      emit(InvitationDeclinedState(event.invitationId));
      
      // Ricarica la lista degli inviti dopo il rifiuto
      add(LoadInvitationsEvent());
    } catch (e) {
      emit(InvitationListErrorState(e.toString(), forSentInvitations: false));
    }
  }
} 