// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:auto_route/auto_route.dart' as _i14;
import 'package:flutter/material.dart' as _i15;
import 'package:topdeck_app_flutter/model/entities/deck.dart' as _i16;
import 'package:topdeck_app_flutter/ui/auth/login_page.dart' as _i7;
import 'package:topdeck_app_flutter/ui/auth/profile_page.dart' as _i10;
import 'package:topdeck_app_flutter/ui/auth/register_page.dart' as _i12;
import 'package:topdeck_app_flutter/ui/core/core_page.dart' as _i1;
import 'package:topdeck_app_flutter/ui/home/home_page.dart' as _i5;
import 'package:topdeck_app_flutter/ui/home/tabs/friends_tab.dart' as _i4;
import 'package:topdeck_app_flutter/ui/home/tabs/home_tab.dart' as _i6;
import 'package:topdeck_app_flutter/ui/home/tabs/profile_tab.dart' as _i11;
import 'package:topdeck_app_flutter/ui/home/tabs/tournaments_tab.dart' as _i13;
import 'package:topdeck_app_flutter/ui/screens/match_wizard/deck_selection_page.dart'
    as _i2;
import 'package:topdeck_app_flutter/ui/screens/match_wizard/format_selection_page.dart'
    as _i3;
import 'package:topdeck_app_flutter/ui/screens/match_wizard/match_results_page.dart'
    as _i8;
import 'package:topdeck_app_flutter/ui/screens/match_wizard/opponent_search_page.dart'
    as _i9;

/// generated route for
/// [_i1.CorePage]
class CorePageRoute extends _i14.PageRouteInfo<void> {
  const CorePageRoute({List<_i14.PageRouteInfo>? children})
    : super(CorePageRoute.name, initialChildren: children);

  static const String name = 'CorePageRoute';

  static _i14.PageInfo page = _i14.PageInfo(
    name,
    builder: (data) {
      return const _i1.CorePage();
    },
  );
}

/// generated route for
/// [_i2.DeckSelectionPage]
class DeckSelectionPageRoute
    extends _i14.PageRouteInfo<DeckSelectionPageRouteArgs> {
  DeckSelectionPageRoute({
    _i15.Key? key,
    required _i16.DeckFormat format,
    List<_i14.PageRouteInfo>? children,
  }) : super(
         DeckSelectionPageRoute.name,
         args: DeckSelectionPageRouteArgs(key: key, format: format),
         initialChildren: children,
       );

  static const String name = 'DeckSelectionPageRoute';

  static _i14.PageInfo page = _i14.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<DeckSelectionPageRouteArgs>();
      return _i2.DeckSelectionPage(key: args.key, format: args.format);
    },
  );
}

class DeckSelectionPageRouteArgs {
  const DeckSelectionPageRouteArgs({this.key, required this.format});

  final _i15.Key? key;

  final _i16.DeckFormat format;

  @override
  String toString() {
    return 'DeckSelectionPageRouteArgs{key: $key, format: $format}';
  }
}

/// generated route for
/// [_i3.FormatSelectionPage]
class FormatSelectionPageRoute extends _i14.PageRouteInfo<void> {
  const FormatSelectionPageRoute({List<_i14.PageRouteInfo>? children})
    : super(FormatSelectionPageRoute.name, initialChildren: children);

  static const String name = 'FormatSelectionPageRoute';

  static _i14.PageInfo page = _i14.PageInfo(
    name,
    builder: (data) {
      return const _i3.FormatSelectionPage();
    },
  );
}

/// generated route for
/// [_i4.FriendsTab]
class FriendsTabRoute extends _i14.PageRouteInfo<void> {
  const FriendsTabRoute({List<_i14.PageRouteInfo>? children})
    : super(FriendsTabRoute.name, initialChildren: children);

  static const String name = 'FriendsTabRoute';

  static _i14.PageInfo page = _i14.PageInfo(
    name,
    builder: (data) {
      return const _i4.FriendsTab();
    },
  );
}

/// generated route for
/// [_i5.HomePage]
class HomePageRoute extends _i14.PageRouteInfo<void> {
  const HomePageRoute({List<_i14.PageRouteInfo>? children})
    : super(HomePageRoute.name, initialChildren: children);

  static const String name = 'HomePageRoute';

  static _i14.PageInfo page = _i14.PageInfo(
    name,
    builder: (data) {
      return const _i5.HomePage();
    },
  );
}

/// generated route for
/// [_i6.HomeTab]
class HomeTabRoute extends _i14.PageRouteInfo<void> {
  const HomeTabRoute({List<_i14.PageRouteInfo>? children})
    : super(HomeTabRoute.name, initialChildren: children);

  static const String name = 'HomeTabRoute';

  static _i14.PageInfo page = _i14.PageInfo(
    name,
    builder: (data) {
      return const _i6.HomeTab();
    },
  );
}

/// generated route for
/// [_i7.LoginPage]
class LoginPageRoute extends _i14.PageRouteInfo<void> {
  const LoginPageRoute({List<_i14.PageRouteInfo>? children})
    : super(LoginPageRoute.name, initialChildren: children);

  static const String name = 'LoginPageRoute';

  static _i14.PageInfo page = _i14.PageInfo(
    name,
    builder: (data) {
      return const _i7.LoginPage();
    },
  );
}

/// generated route for
/// [_i8.MatchResultsPage]
class MatchResultsPageRoute
    extends _i14.PageRouteInfo<MatchResultsPageRouteArgs> {
  MatchResultsPageRoute({
    _i15.Key? key,
    required _i16.DeckFormat format,
    required String playerDeckId,
    required String opponentId,
    List<_i14.PageRouteInfo>? children,
  }) : super(
         MatchResultsPageRoute.name,
         args: MatchResultsPageRouteArgs(
           key: key,
           format: format,
           playerDeckId: playerDeckId,
           opponentId: opponentId,
         ),
         initialChildren: children,
       );

  static const String name = 'MatchResultsPageRoute';

  static _i14.PageInfo page = _i14.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<MatchResultsPageRouteArgs>();
      return _i8.MatchResultsPage(
        key: args.key,
        format: args.format,
        playerDeckId: args.playerDeckId,
        opponentId: args.opponentId,
      );
    },
  );
}

class MatchResultsPageRouteArgs {
  const MatchResultsPageRouteArgs({
    this.key,
    required this.format,
    required this.playerDeckId,
    required this.opponentId,
  });

  final _i15.Key? key;

  final _i16.DeckFormat format;

  final String playerDeckId;

  final String opponentId;

  @override
  String toString() {
    return 'MatchResultsPageRouteArgs{key: $key, format: $format, playerDeckId: $playerDeckId, opponentId: $opponentId}';
  }
}

/// generated route for
/// [_i9.OpponentSearchPage]
class OpponentSearchPageRoute
    extends _i14.PageRouteInfo<OpponentSearchPageRouteArgs> {
  OpponentSearchPageRoute({
    _i15.Key? key,
    required _i16.DeckFormat format,
    required String selectedDeckId,
    List<_i14.PageRouteInfo>? children,
  }) : super(
         OpponentSearchPageRoute.name,
         args: OpponentSearchPageRouteArgs(
           key: key,
           format: format,
           selectedDeckId: selectedDeckId,
         ),
         initialChildren: children,
       );

  static const String name = 'OpponentSearchPageRoute';

  static _i14.PageInfo page = _i14.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<OpponentSearchPageRouteArgs>();
      return _i9.OpponentSearchPage(
        key: args.key,
        format: args.format,
        selectedDeckId: args.selectedDeckId,
      );
    },
  );
}

class OpponentSearchPageRouteArgs {
  const OpponentSearchPageRouteArgs({
    this.key,
    required this.format,
    required this.selectedDeckId,
  });

  final _i15.Key? key;

  final _i16.DeckFormat format;

  final String selectedDeckId;

  @override
  String toString() {
    return 'OpponentSearchPageRouteArgs{key: $key, format: $format, selectedDeckId: $selectedDeckId}';
  }
}

/// generated route for
/// [_i10.ProfilePage]
class ProfilePageRoute extends _i14.PageRouteInfo<void> {
  const ProfilePageRoute({List<_i14.PageRouteInfo>? children})
    : super(ProfilePageRoute.name, initialChildren: children);

  static const String name = 'ProfilePageRoute';

  static _i14.PageInfo page = _i14.PageInfo(
    name,
    builder: (data) {
      return const _i10.ProfilePage();
    },
  );
}

/// generated route for
/// [_i11.ProfileTab]
class ProfileTabRoute extends _i14.PageRouteInfo<void> {
  const ProfileTabRoute({List<_i14.PageRouteInfo>? children})
    : super(ProfileTabRoute.name, initialChildren: children);

  static const String name = 'ProfileTabRoute';

  static _i14.PageInfo page = _i14.PageInfo(
    name,
    builder: (data) {
      return const _i11.ProfileTab();
    },
  );
}

/// generated route for
/// [_i12.RegisterPage]
class RegisterPageRoute extends _i14.PageRouteInfo<void> {
  const RegisterPageRoute({List<_i14.PageRouteInfo>? children})
    : super(RegisterPageRoute.name, initialChildren: children);

  static const String name = 'RegisterPageRoute';

  static _i14.PageInfo page = _i14.PageInfo(
    name,
    builder: (data) {
      return const _i12.RegisterPage();
    },
  );
}

/// generated route for
/// [_i13.TournamentsTab]
class TournamentsTabRoute extends _i14.PageRouteInfo<void> {
  const TournamentsTabRoute({List<_i14.PageRouteInfo>? children})
    : super(TournamentsTabRoute.name, initialChildren: children);

  static const String name = 'TournamentsTabRoute';

  static _i14.PageInfo page = _i14.PageInfo(
    name,
    builder: (data) {
      return const _i13.TournamentsTab();
    },
  );
}
