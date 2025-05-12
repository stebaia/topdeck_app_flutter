import 'package:auto_route/auto_route.dart';
import 'package:topdeck_app_flutter/routers/app_router.gr.dart';

@AutoRouterConfig(
  replaceInRouteName: 'Page,Route',
)
class AppRouter extends RootStackRouter{
  List<AutoRoute> get routes => [
        AutoRoute(page: HomeRoute.page, initial: true),
      
      ];
}

