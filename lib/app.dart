import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:topdeck_app_flutter/l10n/app_localizations.dart';
import 'package:topdeck_app_flutter/di/dependency_injector.dart';
import 'package:topdeck_app_flutter/routers/app_router.dart';
import 'package:topdeck_app_flutter/theme/app_themes.dart';
import 'package:topdeck_app_flutter/state_management/cubit/theme/theme_cubit.dart';

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
      child: BlocBuilder<ThemeCubit, ThemeState>(
        builder: (context, themeState) {
          return MaterialApp.router(
            debugShowCheckedModeBanner: false,
            routeInformationParser: router.defaultRouteParser(),
            routerDelegate: router.delegate(),
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            theme: AppThemes.lightTheme,
            darkTheme: AppThemes.darkTheme,
            themeMode: themeState.themeMode,
            supportedLocales: const [
              Locale('en'),
              Locale('it'),
            ],
          );
        },
      ),
    );
  }
}


