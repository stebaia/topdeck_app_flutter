import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:topdeck_app_flutter/network/service/impl/match_invitation_list_service_impl.dart';
import 'package:topdeck_app_flutter/state_management/blocs/invitation_list/invitation_list_event.dart';
import 'package:topdeck_app_flutter/state_management/blocs/invitation_list/invitation_list_state.dart';

/// BLoC for managing match invitation listings
class InvitationListBloc extends Bloc<InvitationListEvent, InvitationListState> {
  final MatchInvitationListServiceImpl _invitationService = MatchInvitationListServiceImpl();
  final bool isForSentInvitations;

  /// Constructor
  InvitationListBloc({this.isForSentInvitations = false}) : super(InvitationListInitialState()) {
    on<LoadInvitationsEvent>(_onLoadInvitations);
    on<RefreshInvitationsEvent>(_onRefreshInvitations);
    on<LoadSentInvitationsEvent>(_onLoadSentInvitations);
    on<RefreshSentInvitationsEvent>(_onRefreshSentInvitations);
    on<ToggleInvitationViewEvent>(_onToggleView);
    on<AcceptInvitationEvent>(_onAcceptInvitation);
    on<DeclineInvitationEvent>(_onDeclineInvitation);
    
    // Carica automaticamente il tipo appropriato di inviti all'avvio
    if (isForSentInvitations) {
      add(LoadSentInvitationsEvent());
    } else {
      add(LoadInvitationsEvent());
    }
  }
  
  /// Getter per verificare se stiamo mostrando gli inviti inviati
  bool get showingSentInvitations => isForSentInvitations;

  Future<void> _onLoadInvitations(
    LoadInvitationsEvent event,
    Emitter<InvitationListState> emit,
  ) async {
    if (isForSentInvitations) return; // Ignora se questo bloc è per inviti inviati
    
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
    if (isForSentInvitations) return; // Ignora se questo bloc è per inviti inviati
    
    // Don't show loading state during refresh
    try {
      final invitations = await _invitationService.getUserInvitations();
      emit(InvitationListLoadedState(invitations, areSentInvitations: false));
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
      final invitations = await _invitationService.getSentInvitations();
      emit(InvitationListLoadedState(invitations, areSentInvitations: true));
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
      final invitations = await _invitationService.getSentInvitations();
      emit(InvitationListLoadedState(invitations, areSentInvitations: true));
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
      final result = await _invitationService.acceptInvitation(event.invitationId);
      emit(InvitationAcceptedState(result));
      
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
      await _invitationService.declineInvitation(event.invitationId);
      emit(InvitationDeclinedState(event.invitationId));
      
      // Ricarica la lista degli inviti dopo il rifiuto
      add(LoadInvitationsEvent());
    } catch (e) {
      emit(InvitationListErrorState(e.toString(), forSentInvitations: false));
    }
  }
} 