import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:topdeck_app_flutter/network/service/impl/match_invitation_list_service_impl.dart';
import 'package:topdeck_app_flutter/state_management/blocs/invitation_list/invitation_list_event.dart';
import 'package:topdeck_app_flutter/state_management/blocs/invitation_list/invitation_list_state.dart';

/// BLoC specifico per gestire gli inviti inviati
class SentInvitationListBloc extends Bloc<InvitationListEvent, InvitationListState> {
  final MatchInvitationListServiceImpl _invitationService = MatchInvitationListServiceImpl();

  /// Constructor
  SentInvitationListBloc() : super(InvitationListInitialState()) {
    on<LoadSentInvitationsEvent>(_onLoadSentInvitations);
    on<RefreshSentInvitationsEvent>(_onRefreshSentInvitations);
    
    // Carica automaticamente gli inviti inviati all'avvio
    add(LoadSentInvitationsEvent());
  }
  
  Future<void> _onLoadSentInvitations(
    LoadSentInvitationsEvent event,
    Emitter<InvitationListState> emit,
  ) async {
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
    // Don't show loading state during refresh
    try {
      final invitations = await _invitationService.getSentInvitations();
      emit(InvitationListLoadedState(invitations, areSentInvitations: true));
    } catch (e) {
      emit(InvitationListErrorState(e.toString(), forSentInvitations: true));
    }
  }
} 