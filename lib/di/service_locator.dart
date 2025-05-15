import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:topdeck_app_flutter/network/service/impl/auth_service_impl.dart';
import 'package:topdeck_app_flutter/network/service/impl/deck_card_service_impl.dart';
import 'package:topdeck_app_flutter/network/service/impl/deck_service_impl.dart';
import 'package:topdeck_app_flutter/network/service/impl/friend_service_impl.dart';
import 'package:topdeck_app_flutter/network/service/impl/match_creation_service_impl.dart';
import 'package:topdeck_app_flutter/network/service/impl/match_service_impl.dart';
import 'package:topdeck_app_flutter/network/service/impl/player_stats_service_impl.dart';
import 'package:topdeck_app_flutter/network/service/impl/profile_service_impl.dart';
import 'package:topdeck_app_flutter/network/service/impl/tournament_service_impl.dart';
import 'package:topdeck_app_flutter/network/service/impl/user_search_service_impl.dart';
import 'package:topdeck_app_flutter/repositories/auth_repository.dart';
import 'package:topdeck_app_flutter/repositories/deck_card_repository.dart';
import 'package:topdeck_app_flutter/repositories/deck_repository.dart';
import 'package:topdeck_app_flutter/repositories/friend_repository.dart';
import 'package:topdeck_app_flutter/repositories/impl/auth_repository_impl.dart';
import 'package:topdeck_app_flutter/repositories/impl/deck_card_repository_impl.dart';
import 'package:topdeck_app_flutter/repositories/impl/deck_repository_impl.dart';
import 'package:topdeck_app_flutter/repositories/impl/friend_repository_impl.dart';
import 'package:topdeck_app_flutter/repositories/impl/match_repository_impl.dart';
import 'package:topdeck_app_flutter/repositories/impl/profile_repository_impl.dart';
import 'package:topdeck_app_flutter/repositories/impl/tournament_repository_impl.dart';
import 'package:topdeck_app_flutter/repositories/impl/user_search_repository_impl.dart';
import 'package:topdeck_app_flutter/repositories/match_repository.dart';
import 'package:topdeck_app_flutter/repositories/profile_repository.dart';
import 'package:topdeck_app_flutter/repositories/tournament_repository.dart';
import 'package:topdeck_app_flutter/repositories/user_search_repository.dart';
import 'package:topdeck_app_flutter/state_management/blocs/friends/friends_bloc.dart';
import 'package:topdeck_app_flutter/state_management/blocs/user_search/user_search_bloc.dart';

/// Service locator for dependency injection
class ServiceLocator {
  /// Provider list for our repositories
  static List<Provider> getProviders() {
    return [
      // Services - all services need to be registered first
      Provider<AuthServiceImpl>(
        create: (_) => AuthServiceImpl(),
      ),
      Provider<ProfileServiceImpl>(
        create: (_) => ProfileServiceImpl(),
      ),
      Provider<DeckServiceImpl>(
        create: (_) => DeckServiceImpl(),
      ),
      Provider<DeckCardServiceImpl>(
        create: (_) => DeckCardServiceImpl(),
      ),
      Provider<MatchServiceImpl>(
        create: (_) => MatchServiceImpl(),
      ),
      Provider<TournamentServiceImpl>(
        create: (_) => TournamentServiceImpl(),
      ),
      // Nuovi servizi che utilizzano Edge Functions
      Provider<FriendServiceImpl>(
        create: (_) => FriendServiceImpl(),
      ),
      Provider<UserSearchServiceImpl>(
        create: (_) => UserSearchServiceImpl(),
      ),
      Provider<MatchCreationServiceImpl>(
        create: (_) => MatchCreationServiceImpl(),
      ),
      Provider<PlayerStatsServiceImpl>(
        create: (_) => PlayerStatsServiceImpl(),
      ),
      
      // Repositories - order matters! Dependencies must be registered first
      // ProfileRepository needs to be registered before AuthRepository
      Provider<ProfileRepository>(
        create: (context) => ProfileRepositoryImpl(
          context.read<ProfileServiceImpl>(),
        ),
      ),
      // AuthRepository depends on ProfileRepository, so register it after ProfileRepository
      Provider<AuthRepository>(
        create: (context) => AuthRepositoryImpl(
          context.read<AuthServiceImpl>(),
          context.read<ProfileRepository>(),
        ),
      ),
      // Other repositories
      Provider<DeckRepository>(
        create: (context) => DeckRepositoryImpl(
          context.read<DeckServiceImpl>(),
        ),
      ),
      Provider<DeckCardRepository>(
        create: (context) => DeckCardRepositoryImpl(
          context.read<DeckCardServiceImpl>(),
        ),
      ),
      Provider<MatchRepository>(
        create: (context) => MatchRepositoryImpl(
          context.read<MatchServiceImpl>(),
        ),
      ),
      Provider<TournamentRepository>(
        create: (context) => TournamentRepositoryImpl(
          context.read<TournamentServiceImpl>(),
        ),
      ),
      // Nuovo repository di ricerca utenti
      Provider<UserSearchRepository>(
        create: (context) => UserSearchRepositoryImpl(
          context.read<UserSearchServiceImpl>(),
        ),
      ),
      // Repository per la gestione degli amici
      Provider<FriendRepository>(
        create: (context) => FriendRepositoryImpl(
          friendService: context.read<FriendServiceImpl>(),
        ),
      ),
      
      // Blocs
      Provider<FriendsBloc>(
        create: (context) => FriendsBloc(
          friendRepository: context.read<FriendRepository>(),
        ),
        dispose: (_, bloc) => bloc.close(),
      ),
      
      // Bloc per la ricerca utenti
      Provider<UserSearchBloc>(
        create: (context) => UserSearchBloc(
          context.read<UserSearchRepository>(),
        ),
        dispose: (_, bloc) => bloc.close(),
      ),
    ];
  }
} 