part of 'handling_tournament_bloc.dart';

sealed class HandlingTournamentState extends Equatable {
  const HandlingTournamentState();
  
  @override
  List<Object> get props => [];
}

class HandlingTournamentInitial extends HandlingTournamentState {}

class GeneratingSwissPairingsLoadingState extends HandlingTournamentState {}

class GeneratingSwissPairingsSuccessState extends HandlingTournamentState {
  final List<TournamentMatch> matches;

  const GeneratingSwissPairingsSuccessState({required this.matches});
}

class GeneratingSwissPairingsFailureState extends HandlingTournamentState {
  final String error;

  const GeneratingSwissPairingsFailureState({required this.error});
}

class AdvancingToNextRoundLoadingState extends HandlingTournamentState {}

class AdvancingToNextRoundSuccessState extends HandlingTournamentState {}

class AdvancingToNextRoundFailureState extends HandlingTournamentState {
  final String error;

  const AdvancingToNextRoundFailureState({required this.error});
}

class GettingTournamentStandingsLoadingState extends HandlingTournamentState {}

class GettingTournamentStandingsSuccessState extends HandlingTournamentState {}