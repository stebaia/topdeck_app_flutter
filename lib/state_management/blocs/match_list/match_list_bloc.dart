import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:topdeck_app_flutter/repositories/match_repository.dart';
import 'package:topdeck_app_flutter/state_management/blocs/match_list/match_list_event.dart';
import 'package:topdeck_app_flutter/state_management/blocs/match_list/match_list_state.dart';

/// BLoC for managing match listings
class MatchListBloc extends Bloc<MatchListEvent, MatchListState> {
  final MatchRepository _matchRepository;

  /// Constructor
  MatchListBloc({required MatchRepository matchRepository}) : _matchRepository = matchRepository, super(MatchListInitialState()) {
    on<LoadMatchesEvent>(_onLoadMatches);
    on<RefreshMatchesEvent>(_onRefreshMatches);
    on<CancelMatchEvent>(_onCancelMatch);
  }

  Future<void> _onLoadMatches(
    LoadMatchesEvent event,
    Emitter<MatchListState> emit,
  ) async {
    emit(MatchListLoadingState());

    try {
      final matches = await _matchRepository.getUserMatches();
      emit(MatchListLoadedState(matches));
    } catch (e) {
      emit(MatchListErrorState(e.toString()));
    }
  }

  Future<void> _onRefreshMatches(
    RefreshMatchesEvent event,
    Emitter<MatchListState> emit,
  ) async {
    // Non mostriamo lo stato di caricamento durante il refresh
    try {
      final matches = await _matchRepository.getUserMatches();
      emit(MatchListLoadedState(matches));
    } catch (e) {
      emit(MatchListErrorState(e.toString()));
    }
  }

  Future<void> _onCancelMatch(
    CancelMatchEvent event,
    Emitter<MatchListState> emit,
  ) async {
    emit(MatchCancellingState(event.matchId));

    try {
      await _matchRepository.delete(event.matchId);
      emit(MatchCancelledState(event.matchId));
      
      // Ricarica la lista dei match dopo la cancellazione
      add(LoadMatchesEvent());
    } catch (e) {
      emit(MatchCancelErrorState(event.matchId, e.toString()));
    }
  }
} 