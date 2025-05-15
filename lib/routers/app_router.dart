import 'package:auto_route/auto_route.dart';
import 'package:topdeck_app_flutter/routers/app_router.gr.dart';
import 'package:topdeck_app_flutter/routers/auth_guard.dart';

@AutoRouterConfig(
  replaceInRouteName: 'Page,Route,Tab',
)
class AppRouter extends RootStackRouter{
  
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
    AutoRoute(page: CompleteGoogleProfilePageRoute.page, path: '/complete-google-profile'),
    
    // Authenticated routes (protected by AuthGuard)
    AutoRoute(
      page: HomePageRoute.page, 
      path: '/home',
      guards: [AuthGuard()],
      children: [
        AutoRoute(page: HomeTabRoute.page, path: 'home'),
        AutoRoute(page: TournamentsTabRoute.page, path: 'tournaments'),
        AutoRoute(page: FriendsTabRoute.page, path: 'friends'),
        AutoRoute(page: ProfileTabRoute.page, path: 'profile'),
      ]
    ),
    
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
      page: DeckSelectionPageRoute.page,
      path: '/match-wizard/deck',
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
    
    // User profile page
    AutoRoute(
      page: UserProfilePageRoute.page,
      path: '/user/:userId',
      guards: [AuthGuard()],
    ),
  ];
}

