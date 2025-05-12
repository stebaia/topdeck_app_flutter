import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:topdeck_app_flutter/di/dependency_injector.dart';
import 'package:topdeck_app_flutter/routers/app_router.dart';
import 'package:topdeck_app_flutter/theme/light_theme.dart';


final router = AppRouter();

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    return DependencyInjector(
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
        routeInformationParser: router.defaultRouteParser(),
        routerDelegate: router.delegate(),
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        theme: LightTheme.make,
        supportedLocales: const [
          Locale('en'),
          Locale('it'),
        ],
      ),
    );
  }
}


