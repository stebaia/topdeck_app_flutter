import 'package:auto_route/auto_route.dart';
import 'package:topdeck_app_flutter/routers/app_router.gr.dart';
import 'package:topdeck_app_flutter/routers/auth_guard.dart';

@AutoRouterConfig(
  replaceInRouteName: 'Page,Route,Tab',
)
class AppRouter extends RootStackRouter {
  AppRouter({super.navigatorKey});

  @override
  List<AutoRoute> get routes => [
        // Core route (initial route that handles authentication redirection)
        AutoRoute(
          page: CorePageRoute.page,
          path: '/',
          initial: true,
        ),

        // Unauthenticated routes
        AutoRoute(page: LoginPageRoute.page, path: '/login'),
        AutoRoute(page: RegisterPageRoute.page, path: '/register'),
        AutoRoute(
            page: CompleteGoogleProfilePageRoute.page,
            path: '/complete-google-profile'),

        // Authenticated routes (protected by AuthGuard)
        AutoRoute(page: HomePageRoute.page, path: '/home', guards: [
          AuthGuard()
        ], children: [
          AutoRoute(page: HomeTabRoute.page, path: 'home'),
          AutoRoute(page: StatisticsTabRoute.page, path: 'statistics'),
          AutoRoute(page: FriendsTabRoute.page, path: 'friends'),
          AutoRoute(page: ProfileTabRoute.page, path: 'profile'),
        ]),
        AutoRoute(
            page: RecoveryPasswordPageRoute.page, path: '/recovery-password'),

        // Decks page
        AutoRoute(
          page: DecksPageRoute.page,
          path: '/decks',
          guards: [AuthGuard()],
        ),

        // Match creation wizard routes
        AutoRoute(
          page: FormatSelectionPageRoute.page,
          path: '/match-wizard/format',
          guards: [AuthGuard()],
        ),
        AutoRoute(
          page: MatchInvitationDetailPageRoute.page,
          path: '/match-wizard/invitation',
          guards: [AuthGuard()],
        ),
        AutoRoute(
          page: DeckSelectionWizardPageRoute.page,
          path: '/match-wizard/deck',
          guards: [AuthGuard()],
        ),
        AutoRoute(
          page: DeckSelectionPageRoute.page,
          path: '/match-wizard/deck-selection',
          guards: [AuthGuard()],
        ),
        AutoRoute(
          page: OpponentSearchPageRoute.page,
          path: '/match-wizard/opponent',
          guards: [AuthGuard()],
        ),
        AutoRoute(
          page: MatchResultsPageRoute.page,
          path: '/match-wizard/results',
          guards: [AuthGuard()],
        ),

        // Match pages
        AutoRoute(
          page: MatchDetailPageRoute.page,
          path: '/match/detail',
          guards: [AuthGuard()],
        ),
        AutoRoute(
          page: MatchResultPageRoute.page,
          path: '/match/result',
          guards: [AuthGuard()],
        ),

        // Life Counter page
        AutoRoute(
          page: LifeCounterPageRoute.page,
          path: '/match/life-counter',
          guards: [AuthGuard()],
        ),

        // Offline Life Counter page
        AutoRoute(
          page: OfflineLifeCounterPageRoute.page,
          path: '/offline-life-counter',
          guards: [AuthGuard()],
        ),

        // Test Real-time page
        AutoRoute(
          page: TestRealtimePageRoute.page,
          path: '/test-realtime',
          guards: [AuthGuard()],
        ),

        // User profile page
        AutoRoute(
          page: UserProfilePageRoute.page,
          path: '/user/:userId',
          guards: [AuthGuard()],
        ),
        AutoRoute(
          page: ConfirmNewPasswordPageRoute.page,
          path: '/confirm-new-password',
        ),
      ];
}
