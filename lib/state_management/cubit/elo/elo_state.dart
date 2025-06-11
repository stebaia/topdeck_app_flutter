import 'package:equatable/equatable.dart';
import '../../../model/entities/user_profile_extended.dart';

/// Base state for ELO operations
abstract class EloState extends Equatable {
  const EloState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class EloInitial extends EloState {}

/// Loading state
class EloLoading extends EloState {}

/// Profile loaded successfully
class EloProfileLoaded extends EloState {
  final UserProfileExtended profile;

  const EloProfileLoaded(this.profile);

  @override
  List<Object?> get props => [profile];
}

/// Leaderboard loaded successfully
class EloLeaderboardLoaded extends EloState {
  final Map<String, dynamic> leaderboardData;

  const EloLeaderboardLoaded(this.leaderboardData);

  @override
  List<Object?> get props => [leaderboardData];
}

/// Match created successfully
class EloMatchCreated extends EloState {
  final Map<String, dynamic> matchResult;

  const EloMatchCreated(this.matchResult);

  @override
  List<Object?> get props => [matchResult];
}

/// Tournament completed successfully
class EloTournamentCompleted extends EloState {
  final Map<String, dynamic> tournamentResult;

  const EloTournamentCompleted(this.tournamentResult);

  @override
  List<Object?> get props => [tournamentResult];
}

/// Match history loaded successfully
class EloMatchHistoryLoaded extends EloState {
  final Map<String, dynamic> matchHistory;

  const EloMatchHistoryLoaded(this.matchHistory);

  @override
  List<Object?> get props => [matchHistory];
}

/// User statistics loaded successfully
class EloStatisticsLoaded extends EloState {
  final Map<String, dynamic> statistics;

  const EloStatisticsLoaded(this.statistics);

  @override
  List<Object?> get props => [statistics];
}

/// Error state
class EloError extends EloState {
  final String message;

  const EloError(this.message);

  @override
  List<Object?> get props => [message];
} 