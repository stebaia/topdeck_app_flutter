part of 'dependency_injector.dart';

final List<RepositoryProvider> _repositories = [
  RepositoryProvider<DeckRepository>(
    create: (context) => Provider.of<DeckRepository>(context, listen: false),
  ),
  RepositoryProvider<TournamentRepository>(
    create: (context) => Provider.of<TournamentRepository>(context, listen: false),
  ),
  RepositoryProvider<TournamentParticipantRepository>(
    create: (context) => Provider.of<TournamentParticipantRepository>(context, listen: false),
  ),
  RepositoryProvider<TournamentInvitationRepository>(
    create: (context) => Provider.of<TournamentInvitationRepository>(context, listen: false),
  ),
];
