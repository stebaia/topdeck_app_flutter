import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:topdeck_app_flutter/model/user.dart';
import 'package:topdeck_app_flutter/model/entities/match.dart';
import 'package:topdeck_app_flutter/network/supabase_config.dart';
import 'package:topdeck_app_flutter/network/service/impl/match_invitation_service_impl.dart';
import 'package:topdeck_app_flutter/repositories/deck_repository.dart';
import 'package:topdeck_app_flutter/repositories/match_repository.dart';
import 'package:topdeck_app_flutter/repositories/user_search_repository.dart';
import 'package:topdeck_app_flutter/state_management/blocs/match_wizard/match_wizard_event.dart';
import 'package:topdeck_app_flutter/state_management/blocs/match_wizard/match_wizard_state.dart';

/// BLoC for managing the match wizard flow
class MatchWizardBloc extends Bloc<MatchWizardEvent, MatchWizardState> {
  final UserSearchRepository _userSearchRepository;
  final DeckRepository _deckRepository;
  final MatchRepository _matchRepository;
  final MatchInvitationServiceImpl _invitationService = MatchInvitationServiceImpl();

  /// Constructor
  MatchWizardBloc({
    required UserSearchRepository userSearchRepository,
    required DeckRepository deckRepository,
    required MatchRepository matchRepository,
  }) : 
    _userSearchRepository = userSearchRepository,
    _deckRepository = deckRepository,
    _matchRepository = matchRepository,
    super(MatchWizardInitialState()) {
    on<SearchUsersEvent>(_onSearchUsers);
    on<LoadUserDecksByFormatEvent>(_onLoadUserDecksByFormat);
    on<LoadOpponentDecksEvent>(_onLoadOpponentDecks);
    on<SaveMatchResultEvent>(_onSaveMatchResult);
    on<SendMatchInvitationEvent>(_onSendMatchInvitation);
    on<ResetEvent>(_onReset);
  }

  Future<void> _onSearchUsers(
    SearchUsersEvent event,
    Emitter<MatchWizardState> emit,
  ) async {
    if (event.query.trim().isEmpty) {
      emit(UserSearchResultsState([]));
      return;
    }

    emit(MatchWizardLoadingState());

    try {
      final results = await _userSearchRepository.searchUsers(event.query);
      
      final users = results.map((userData) => UserProfile(
        id: userData['id'],
        username: userData['username'],
        displayName: userData['display_name'],
      )).toList();
      
      emit(UserSearchResultsState(users));
    } catch (e) {
      emit(MatchWizardErrorState('Error searching for users: $e'));
    }
  }

  Future<void> _onLoadUserDecksByFormat(
    LoadUserDecksByFormatEvent event,
    Emitter<MatchWizardState> emit,
  ) async {
    // Verifica l'autenticazione prima di procedere
    final currentUser = supabase.auth.currentUser;
    if (currentUser == null) {
      emit(MatchWizardErrorState('Non sei autenticato. Accedi per visualizzare i tuoi mazzi.'));
      return;
    }
    
    emit(MatchWizardLoadingState());

    try {
      final decks = await _deckRepository.findByFormat(event.format);
      emit(UserDecksLoadedState(decks, event.format));
    } catch (e) {
      String errorMessage = 'Errore durante il caricamento dei mazzi';
      
      if (e is AuthException) {
        errorMessage = 'Errore di autenticazione: ${e.message}';
      } else if (e is PostgrestException) {
        errorMessage = 'Errore di database: ${e.message}';
      } else {
        errorMessage = 'Errore: $e';
      }
      
      emit(MatchWizardErrorState(errorMessage));
    }
  }

  Future<void> _onLoadOpponentDecks(
    LoadOpponentDecksEvent event,
    Emitter<MatchWizardState> emit,
  ) async {
    emit(MatchWizardLoadingState());

    try {
      final decks = await _deckRepository.getPublicDecksByUser(event.opponentId);
      emit(OpponentDecksLoadedState(
        decks.map((deck) => deck.toJson()).toList(),
        event.opponentId,
      ));
    } catch (e) {
      emit(MatchWizardErrorState('Error loading opponent decks: $e'));
    }
  }

  Future<void> _onSaveMatchResult(
    SaveMatchResultEvent event,
    Emitter<MatchWizardState> emit,
  ) async {
    emit(SavingMatchState());

    try {
      final match = await _matchRepository.create(
        Match.create(
          player1Id: event.playerId,
          player2Id: event.opponentId,
          player1DeckId: event.playerDeckId,
          player2DeckId: event.opponentDeckId,
          format: event.format.toString().split('.').last,
          winnerId: event.winnerId,
        ),
      );
      
      emit(MatchSavedState(match.id));
    } catch (e) {
      emit(MatchWizardErrorState('Error saving match: $e'));
    }
  }
  
  Future<void> _onSendMatchInvitation(
    SendMatchInvitationEvent event,
    Emitter<MatchWizardState> emit,
  ) async {
    emit(SendingInvitationState());

    try {
      final formatString = event.format.toString().split('.').last;
      
      final result = await _invitationService.sendInvitation(
        receiverId: event.opponentId,
        format: formatString,
        message: event.message,
      );
      
      final invitationId = result['invitation_id'];
      
      if (invitationId != null) {
        emit(InvitationSentState(invitationId));
      } else {
        emit(MatchWizardErrorState('Errore nell\'invio dell\'invito: ID non ricevuto'));
      }
    } catch (e) {
      emit(MatchWizardErrorState('Errore nell\'invio dell\'invito: $e'));
    }
  }

  void _onReset(
    ResetEvent event,
    Emitter<MatchWizardState> emit,
  ) {
    emit(MatchWizardInitialState());
  }
} 