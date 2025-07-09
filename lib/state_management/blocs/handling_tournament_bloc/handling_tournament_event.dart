part of 'handling_tournament_bloc.dart';

sealed class HandlingTournamentEvent extends Equatable {
  const HandlingTournamentEvent();

  @override
  List<Object> get props => [];
}

class GenerateSwissPairingsEvent extends HandlingTournamentEvent {
  final String tournamentId;
  final int roundNumber;

  const GenerateSwissPairingsEvent({required this.tournamentId, required this.roundNumber});
}

class AdvanceToNextRoundEvent extends HandlingTournamentEvent {
  final String tournamentId;
  final int roundNumber;

  const AdvanceToNextRoundEvent({required this.tournamentId, required this.roundNumber});
}

class GetTournamentStandingsEvent extends HandlingTournamentEvent {
  final String tournamentId;

  const GetTournamentStandingsEvent({required this.tournamentId});
}

