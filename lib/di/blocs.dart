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
    ),
  ),
];
