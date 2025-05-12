import 'package:auto_route/auto_route.dart';
import 'package:topdeck_app_flutter/routers/app_router.gr.dart';
import 'package:topdeck_app_flutter/routers/auth_guard.dart';

@AutoRouterConfig(
  replaceInRouteName: 'Page,Route',
)
class AppRouter extends RootStackRouter{
  
  AppRouter({super.navigatorKey});
  
  @override
  List<AutoRoute> get routes => [
    // Core route (initial route that handles authentication redirection)
    AutoRoute(
      page: CoreRoute.page, 
      path: '/',
      initial: true,
    ),
    
    // Unauthenticated routes
    AutoRoute(page: LoginRoute.page, path: '/login'),
    AutoRoute(page: RegisterRoute.page, path: '/register'),
    
    // Authenticated routes (protected by AuthGuard)
    AutoRoute(
      page: HomeRoute.page, 
      path: '/home',
      guards: [AuthGuard()],
    ),
    AutoRoute(
      page: ProfileRoute.page, 
      path: '/profile',
      guards: [AuthGuard()],
    ),
  ];
}

