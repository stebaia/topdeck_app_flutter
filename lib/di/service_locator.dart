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
import 'package:topdeck_app_flutter/network/service/impl/tournament_participant_service_impl.dart';
import 'package:topdeck_app_flutter/network/service/impl/tournament_invitation_service_impl.dart';
import 'package:topdeck_app_flutter/network/service/impl/user_search_service_impl.dart';
import 'package:topdeck_app_flutter/network/service/impl/elo_service_impl.dart';
import 'package:topdeck_app_flutter/network/service/impl/match_invitation_list_service_impl.dart';
import 'package:topdeck_app_flutter/network/service/impl/match_invitation_service_impl.dart';
import 'package:topdeck_app_flutter/repositories/auth_repository.dart';
import 'package:topdeck_app_flutter/repositories/deck_card_repository.dart';
import 'package:topdeck_app_flutter/repositories/deck_repository.dart';
import 'package:topdeck_app_flutter/repositories/friend_repository.dart';
import 'package:topdeck_app_flutter/repositories/elo_repository.dart';
import 'package:topdeck_app_flutter/repositories/match_invitation_repository.dart';
import 'package:topdeck_app_flutter/repositories/impl/auth_repository_impl.dart';
import 'package:topdeck_app_flutter/repositories/impl/deck_card_repository_impl.dart';
import 'package:topdeck_app_flutter/repositories/impl/deck_repository_impl.dart';
import 'package:topdeck_app_flutter/repositories/impl/friend_repository_impl.dart';
import 'package:topdeck_app_flutter/repositories/impl/match_repository_impl.dart';
import 'package:topdeck_app_flutter/repositories/impl/profile_repository_impl.dart';
import 'package:topdeck_app_flutter/repositories/impl/tournament_repository_impl.dart';
import 'package:topdeck_app_flutter/repositories/impl/tournament_participant_repository_impl.dart';
import 'package:topdeck_app_flutter/repositories/impl/tournament_invitation_repository_impl.dart';
import 'package:topdeck_app_flutter/repositories/impl/user_search_repository_impl.dart';
import 'package:topdeck_app_flutter/repositories/impl/match_invitation_repository_impl.dart';
import 'package:topdeck_app_flutter/repositories/match_repository.dart';
import 'package:topdeck_app_flutter/repositories/profile_repository.dart';
import 'package:topdeck_app_flutter/repositories/tournament_repository.dart';
import 'package:topdeck_app_flutter/repositories/tournament_participant_repository.dart';
import 'package:topdeck_app_flutter/repositories/tournament_invitation_repository.dart';
import 'package:topdeck_app_flutter/repositories/user_search_repository.dart';
import 'package:topdeck_app_flutter/state_management/blocs/friends/friends_bloc.dart';
import 'package:topdeck_app_flutter/state_management/blocs/tournament/tournament_bloc.dart';
import 'package:topdeck_app_flutter/state_management/blocs/user_search/user_search_bloc.dart';
import 'package:topdeck_app_flutter/state_management/cubit/elo/elo_cubit.dart';

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
      Provider<TournamentParticipantServiceImpl>(
        create: (_) => TournamentParticipantServiceImpl(),
      ),
      Provider<TournamentServiceImpl>(
        create: (context) => TournamentServiceImpl(
          context.read<TournamentParticipantServiceImpl>(),
        ),
      ),
      Provider<TournamentInvitationServiceImpl>(
        create: (_) => TournamentInvitationServiceImpl(),
      ),
      // ELO Service using Edge Functions
      Provider<EloServiceImpl>(
        create: (_) => EloServiceImpl(),
      ),
      // Altri servizi che utilizzano Edge Functions
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
      
      // Match Invitation Services
      Provider<MatchInvitationListServiceImpl>(
        create: (_) => MatchInvitationListServiceImpl(),
      ),
      Provider<MatchInvitationServiceImpl>(
        create: (_) => MatchInvitationServiceImpl(),
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
      // ELO Repository
      Provider<EloRepository>(
        create: (context) => EloRepository(
          eloService: context.read<EloServiceImpl>(),
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
      Provider<TournamentParticipantRepository>(
        create: (context) => TournamentParticipantRepositoryImpl(
          context.read<TournamentParticipantServiceImpl>(),
        ),
      ),
      Provider<TournamentRepository>(
        create: (context) => TournamentRepositoryImpl(
          context.read<TournamentServiceImpl>(),
        ),
      ),
      Provider<TournamentInvitationRepository>(
        create: (context) => TournamentInvitationRepositoryImpl(
          context.read<TournamentInvitationServiceImpl>(),
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
      
      // Repository per i match invitation
      Provider<MatchInvitationRepository>(
        create: (context) => MatchInvitationRepositoryImpl(
          context.read<MatchInvitationListServiceImpl>(),
          context.read<MatchInvitationServiceImpl>(),
        ),
      ),
      
      // Blocs & Cubits
      Provider<FriendsBloc>(
        create: (context) => FriendsBloc(
          friendRepository: context.read<FriendRepository>(),
        ),
        dispose: (_, bloc) => bloc.close(),
      ),
      
      // Bloc per la ricerca utenti

      // Bloc per i tornei
      Provider<TournamentBloc>(
        create: (context) => TournamentBloc(
          tournamentRepository: context.read<TournamentRepository>(),
        ),
        dispose: (_, bloc) => bloc.close(),
      ),

      // ELO Cubit
      Provider<EloCubit>(
        create: (context) => EloCubit(
          eloRepository: context.read<EloRepository>(),
        ),
        dispose: (_, cubit) => cubit.close(),
      ),
    ];
  }
} 