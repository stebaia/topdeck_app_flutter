part of 'dependency_injector.dart';

final List<RepositoryProvider> _repositories = [
  RepositoryProvider<DeckRepository>(
    create: (context) => context.read<DeckRepository>(),
  ),
  RepositoryProvider<EloRepository>(
    create: (context) => context.read<EloRepository>(),
  ),
  RepositoryProvider<TournamentRepository>(
    create: (context) => context.read<TournamentRepository>(),
  ),
  RepositoryProvider<TournamentParticipantRepository>(
    create: (context) => context.read<TournamentParticipantRepository>(),
  ),
  RepositoryProvider<TournamentInvitationRepository>(
    create: (context) => context.read<TournamentInvitationRepository>(),
  ),
  RepositoryProvider<MatchInvitationRepository>(
    create: (context) => context.read<MatchInvitationRepository>(),
  ),
  RepositoryProvider<RoomRepository>(
    create: (context) => context.read<RoomRepository>(),
  ),
];
