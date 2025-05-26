part of 'dependency_injector.dart';

final List<BlocProvider> _blocs = [
  BlocProvider<AuthBloc>(
    create: (context) => AuthBloc(
      authRepository: context.read<AuthRepository>(),
      profileRepository: context.read<ProfileRepository>(),
      logger: context.read<Logger>(),
    )..add(CheckAuthStatusEvent()),
  ),
  
  // User search bloc
  BlocProvider<UserSearchBloc>(
    create: (context) => UserSearchBloc(
      context.read<UserSearchRepository>(),
      context.read<FriendRepository>(),
    ),
  ),
  
  // Match wizard bloc
  BlocProvider<MatchWizardBloc>(
    create: (context) => MatchWizardBloc(
      userSearchRepository: context.read<UserSearchRepository>(),
      deckRepository: context.read<DeckRepository>(),
      matchRepository: context.read<MatchRepository>(),
    ),
  ),
  
  // Deck management cubit
  BlocProvider<DecksCubit>(
    create: (context) => DecksCubit(
      context.read<DeckRepository>(),
    ),
  ),
  
  // Match list bloc
  BlocProvider<MatchListBloc>(
    create: (context) => MatchListBloc(),
  ),
  
  // Invitation list blocs (separati per tipo)
  BlocProvider<ReceivedInvitationListBloc>(
    create: (context) => ReceivedInvitationListBloc(),
  ),
  
  BlocProvider<SentInvitationListBloc>(
    create: (context) => SentInvitationListBloc(),
  ),
];
