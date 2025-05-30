import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:topdeck_app_flutter/network/supabase_config.dart';
import 'package:topdeck_app_flutter/repositories/tournament_repository.dart';
import 'package:topdeck_app_flutter/state_management/blocs/tournament/tournament_event.dart';
import 'package:topdeck_app_flutter/state_management/blocs/tournament/tournament_state.dart';

/// BLoC for managing tournament lists (public and user tournaments)
class TournamentBloc extends Bloc<TournamentEvent, TournamentState> {
  final TournamentRepository _tournamentRepository;

  /// Constructor
  TournamentBloc({
    required TournamentRepository tournamentRepository,
  }) : 
    _tournamentRepository = tournamentRepository,
    super(TournamentInitialState()) {
    on<LoadPublicTournamentsEvent>(_onLoadPublicTournaments);
    on<LoadMyTournamentsEvent>(_onLoadMyTournaments);
    on<ResetTournamentEvent>(_onReset);
  }

  Future<void> _onLoadPublicTournaments(
    LoadPublicTournamentsEvent event,
    Emitter<TournamentState> emit,
  ) async {
    emit(TournamentLoadingState());

    try {
      // Get current user to exclude their tournaments from public list
      final currentUser = supabase.auth.currentUser;
      final tournaments = await _tournamentRepository.findPublicTournaments(
        excludeCreatedBy: currentUser?.id,
      );
      emit(PublicTournamentsLoadedState(tournaments));
    } catch (e) {
      emit(TournamentErrorState('Error loading public tournaments: $e'));
    }
  }

  Future<void> _onLoadMyTournaments(
    LoadMyTournamentsEvent event,
    Emitter<TournamentState> emit,
  ) async {
    // Verifica l'autenticazione prima di procedere
    final currentUser = supabase.auth.currentUser;
    if (currentUser == null) {
      emit(TournamentErrorState('Non sei autenticato. Accedi per visualizzare i tuoi tornei.'));
      return;
    }
    
    emit(TournamentLoadingState());

    try {
      final tournaments = await _tournamentRepository.findByCreator(currentUser.id);
      emit(MyTournamentsLoadedState(tournaments));
    } catch (e) {
      String errorMessage = 'Errore durante il caricamento dei tornei';
      
      if (e is AuthException) {
        errorMessage = 'Errore di autenticazione: ${e.message}';
      } else if (e is PostgrestException) {
        errorMessage = 'Errore di database: ${e.message}';
      } else {
        errorMessage = 'Errore: $e';
      }
      
      emit(TournamentErrorState(errorMessage));
    }
  }

  void _onReset(
    ResetTournamentEvent event,
    Emitter<TournamentState> emit,
  ) {
    emit(TournamentInitialState());
  }
} 