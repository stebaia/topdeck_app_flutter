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
  
  // Tournament bloc
  BlocProvider<TournamentBloc>(
    create: (context) => TournamentBloc(
      tournamentRepository: context.read<TournamentRepository>(),
    ),
  ),
  
  // Tournament operations bloc
  BlocProvider<TournamentOperationsBloc>(
    create: (context) => TournamentOperationsBloc(
      tournamentRepository: context.read<TournamentRepository>(),
      participantRepository: context.read<TournamentParticipantRepository>(),
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
    create: (context) => MatchListBloc(
      matchRepository: context.read<MatchRepository>(),
    ),
  ),
  BlocProvider<InvitationListBloc>(
    create: (context) => InvitationListBloc(
      context.read<MatchInvitationRepository>(),
    ),
  ),

  // Room bloc
  BlocProvider<RoomBloc>(
    create: (context) => RoomBloc(
      roomRepository: context.read<RoomRepository>(),
    ),
  ),

  // Theme cubit
  BlocProvider<ThemeCubit>(
    create: (context) => ThemeCubit()..loadTheme(),
  ),

  // ELO cubit
  BlocProvider<EloCubit>(
    create: (context) => EloCubit(
      eloRepository: context.read<EloRepository>(),
    ),
  ),

];
