import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:topdeck_app_flutter/model/entities/tournament_match.dart';
import 'package:topdeck_app_flutter/network/service/impl/swiss_pairing_service_impl.dart';

// Events
abstract class SwissSystemEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class GeneratePairingsEvent extends SwissSystemEvent {
  final String tournamentId;
  final int roundNumber;

  GeneratePairingsEvent({
    required this.tournamentId,
    required this.roundNumber,
  });

  @override
  List<Object?> get props => [tournamentId, roundNumber];
}

class LoadCurrentRoundEvent extends SwissSystemEvent {
  final String tournamentId;
  final int round;

  LoadCurrentRoundEvent({
    required this.tournamentId,
    required this.round,
  });

  @override
  List<Object?> get props => [tournamentId, round];
}

class SubmitMatchResultEvent extends SwissSystemEvent {
  final String matchId;
  final String winnerId;
  final String score;

  SubmitMatchResultEvent({
    required this.matchId,
    required this.winnerId,
    required this.score,
  });

  @override
  List<Object?> get props => [matchId, winnerId, score];
}

class AdvanceRoundEvent extends SwissSystemEvent {
  final String tournamentId;
  final int completedRound;

  AdvanceRoundEvent({
    required this.tournamentId,
    required this.completedRound,
  });

  @override
  List<Object?> get props => [tournamentId, completedRound];
}

class LoadStandingsEvent extends SwissSystemEvent {
  final String tournamentId;

  LoadStandingsEvent({required this.tournamentId});

  @override
  List<Object?> get props => [tournamentId];
}

class StartMatchEvent extends SwissSystemEvent {
  final String matchId;

  StartMatchEvent({required this.matchId});

  @override
  List<Object?> get props => [matchId];
}

class DropPlayerEvent extends SwissSystemEvent {
  final String tournamentId;
  final String playerId;
  final int currentRound;

  DropPlayerEvent({
    required this.tournamentId,
    required this.playerId,
    required this.currentRound,
  });

  @override
  List<Object?> get props => [tournamentId, playerId, currentRound];
}

// States
abstract class SwissSystemState extends Equatable {
  @override
  List<Object?> get props => [];
}

class SwissSystemInitial extends SwissSystemState {}

class SwissSystemLoading extends SwissSystemState {}

class SwissSystemError extends SwissSystemState {
  final String message;

  SwissSystemError({required this.message});

  @override
  List<Object?> get props => [message];
}

class PairingsGenerated extends SwissSystemState {
  final List<TournamentMatch> pairings;
  final int round;
  final int totalMatches;

  PairingsGenerated({
    required this.pairings,
    required this.round,
    required this.totalMatches,
  });

  @override
  List<Object?> get props => [pairings, round, totalMatches];
}

class CurrentRoundLoaded extends SwissSystemState {
  final List<TournamentMatch> matches;
  final int round;

  CurrentRoundLoaded({
    required this.matches,
    required this.round,
  });

  @override
  List<Object?> get props => [matches, round];
}

class MatchResultSubmitted extends SwissSystemState {
  final TournamentMatch updatedMatch;

  MatchResultSubmitted({required this.updatedMatch});

  @override
  List<Object?> get props => [updatedMatch];
}

class RoundAdvanced extends SwissSystemState {
  final bool success;
  final int processedMatches;

  RoundAdvanced({
    required this.success,
    required this.processedMatches,
  });

  @override
  List<Object?> get props => [success, processedMatches];
}

class StandingsLoaded extends SwissSystemState {
  final List<Map<String, dynamic>> standings;

  StandingsLoaded({required this.standings});

  @override
  List<Object?> get props => [standings];
}

class MatchStarted extends SwissSystemState {
  final TournamentMatch match;

  MatchStarted({required this.match});

  @override
  List<Object?> get props => [match];
}

class PlayerDropped extends SwissSystemState {
  final String playerId;

  PlayerDropped({required this.playerId});

  @override
  List<Object?> get props => [playerId];
}

// BLoC
class SwissSystemBloc extends Bloc<SwissSystemEvent, SwissSystemState> {
  final SwissPairingServiceImpl _swissPairingService;

  SwissSystemBloc({
    required SwissPairingServiceImpl swissPairingService,
  }) : _swissPairingService = swissPairingService,
       super(SwissSystemInitial()) {
    on<GeneratePairingsEvent>(_onGeneratePairings);
    on<LoadCurrentRoundEvent>(_onLoadCurrentRound);
    on<SubmitMatchResultEvent>(_onSubmitMatchResult);
    on<AdvanceRoundEvent>(_onAdvanceRound);
    on<LoadStandingsEvent>(_onLoadStandings);
    on<StartMatchEvent>(_onStartMatch);
    on<DropPlayerEvent>(_onDropPlayer);
  }

  Future<void> _onGeneratePairings(
    GeneratePairingsEvent event,
    Emitter<SwissSystemState> emit,
  ) async {
    emit(SwissSystemLoading());
    try {
      final pairings = await _swissPairingService.generateSwissPairings(
        tournamentId: event.tournamentId,
        roundNumber: event.roundNumber,
      );

      emit(PairingsGenerated(
        pairings: pairings,
        round: event.roundNumber,
        totalMatches: pairings.length,
      ));
    } catch (e) {
      emit(SwissSystemError(message: e.toString()));
    }
  }

  Future<void> _onLoadCurrentRound(
    LoadCurrentRoundEvent event,
    Emitter<SwissSystemState> emit,
  ) async {
    emit(SwissSystemLoading());
    try {
      final matches = await _swissPairingService.getCurrentRoundPairings(
        tournamentId: event.tournamentId,
        round: event.round,
      );

      emit(CurrentRoundLoaded(
        matches: matches,
        round: event.round,
      ));
    } catch (e) {
      emit(SwissSystemError(message: e.toString()));
    }
  }

  Future<void> _onSubmitMatchResult(
    SubmitMatchResultEvent event,
    Emitter<SwissSystemState> emit,
  ) async {
    emit(SwissSystemLoading());
    try {
      final updatedMatch = await _swissPairingService.updateMatchResult(
        matchId: event.matchId,
        winnerId: event.winnerId,
        resultScore: event.score,
      );

      emit(MatchResultSubmitted(updatedMatch: updatedMatch));
    } catch (e) {
      emit(SwissSystemError(message: e.toString()));
    }
  }

  Future<void> _onAdvanceRound(
    AdvanceRoundEvent event,
    Emitter<SwissSystemState> emit,
  ) async {
    emit(SwissSystemLoading());
    try {
      final success = await _swissPairingService.advanceToNextRound(
        tournamentId: event.tournamentId,
        completedRound: event.completedRound,
      );

      emit(RoundAdvanced(
        success: success,
        processedMatches: 0, // Will be updated by the service
      ));
    } catch (e) {
      emit(SwissSystemError(message: e.toString()));
    }
  }

  Future<void> _onLoadStandings(
    LoadStandingsEvent event,
    Emitter<SwissSystemState> emit,
  ) async {
    emit(SwissSystemLoading());
    try {
      final standings = await _swissPairingService.getTournamentStandings(
        event.tournamentId,
      );

      emit(StandingsLoaded(standings: standings));
    } catch (e) {
      emit(SwissSystemError(message: e.toString()));
    }
  }

  Future<void> _onStartMatch(
    StartMatchEvent event,
    Emitter<SwissSystemState> emit,
  ) async {
    emit(SwissSystemLoading());
    try {
      final match = await _swissPairingService.startMatch(event.matchId);
      emit(MatchStarted(match: match));
    } catch (e) {
      emit(SwissSystemError(message: e.toString()));
    }
  }

  Future<void> _onDropPlayer(
    DropPlayerEvent event,
    Emitter<SwissSystemState> emit,
  ) async {
    emit(SwissSystemLoading());
    try {
      await _swissPairingService.dropPlayer(
        tournamentId: event.tournamentId,
        playerId: event.playerId,
        currentRound: event.currentRound,
      );

      emit(PlayerDropped(playerId: event.playerId));
    } catch (e) {
      emit(SwissSystemError(message: e.toString()));
    }
  }
} 