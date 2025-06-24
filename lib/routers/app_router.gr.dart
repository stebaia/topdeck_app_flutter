// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:auto_route/auto_route.dart' as _i22;
import 'package:flutter/material.dart' as _i23;
import 'package:topdeck_app_flutter/model/entities/deck.dart' as _i25;
import 'package:topdeck_app_flutter/model/entities/match_invitation.dart'
    as _i24;
import 'package:topdeck_app_flutter/ui/auth/complete_google_profile_page.dart'
    as _i1;
import 'package:topdeck_app_flutter/ui/auth/confirm_new_password_page.dart'
    as _i2;
import 'package:topdeck_app_flutter/ui/auth/login_page.dart' as _i11;
import 'package:topdeck_app_flutter/ui/auth/recovery_password_page.dart'
    as _i18;
import 'package:topdeck_app_flutter/ui/auth/register_page.dart' as _i19;
import 'package:topdeck_app_flutter/ui/core/core_page.dart' as _i3;
import 'package:topdeck_app_flutter/ui/decks/decks_page.dart' as _i6;
import 'package:topdeck_app_flutter/ui/home/home_page.dart' as _i9;
import 'package:topdeck_app_flutter/ui/home/tabs/friends_tab.dart' as _i8;
import 'package:topdeck_app_flutter/ui/home/tabs/home_tab.dart' as _i10;
import 'package:topdeck_app_flutter/ui/home/tabs/profile_tab.dart' as _i17;
import 'package:topdeck_app_flutter/ui/home/tabs/tournaments_tab.dart' as _i20;
import 'package:topdeck_app_flutter/ui/match/deck_selection_page.dart' as _i4;
import 'package:topdeck_app_flutter/ui/match/match_detail_page.dart' as _i12;
import 'package:topdeck_app_flutter/ui/match/match_invitation_detail.dart'
    as _i13;
import 'package:topdeck_app_flutter/ui/match/match_result_page.dart' as _i14;
import 'package:topdeck_app_flutter/ui/screens/match_wizard/deck_selection_page.dart'
    as _i5;
import 'package:topdeck_app_flutter/ui/screens/match_wizard/format_selection_page.dart'
    as _i7;
import 'package:topdeck_app_flutter/ui/screens/match_wizard/match_results_page.dart'
    as _i15;
import 'package:topdeck_app_flutter/ui/screens/match_wizard/opponent_search_page.dart'
    as _i16;
import 'package:topdeck_app_flutter/ui/user_profile/user_profile_page.dart'
    as _i21;

/// generated route for
/// [_i1.CompleteGoogleProfilePage]
class CompleteGoogleProfilePageRoute
    extends _i22.PageRouteInfo<CompleteGoogleProfilePageRouteArgs> {
  CompleteGoogleProfilePageRoute({
    _i23.Key? key,
    required String userId,
    required String email,
    String? name,
    String? avatarUrl,
    List<_i22.PageRouteInfo>? children,
  }) : super(
         CompleteGoogleProfilePageRoute.name,
         args: CompleteGoogleProfilePageRouteArgs(
           key: key,
           userId: userId,
           email: email,
           name: name,
           avatarUrl: avatarUrl,
         ),
         initialChildren: children,
       );

  static const String name = 'CompleteGoogleProfilePageRoute';

  static _i22.PageInfo page = _i22.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<CompleteGoogleProfilePageRouteArgs>();
      return _i1.CompleteGoogleProfilePage(
        key: args.key,
        userId: args.userId,
        email: args.email,
        name: args.name,
        avatarUrl: args.avatarUrl,
      );
    },
  );
}

class CompleteGoogleProfilePageRouteArgs {
  const CompleteGoogleProfilePageRouteArgs({
    this.key,
    required this.userId,
    required this.email,
    this.name,
    this.avatarUrl,
  });

  final _i23.Key? key;

  final String userId;

  final String email;

  final String? name;

  final String? avatarUrl;

  @override
  String toString() {
    return 'CompleteGoogleProfilePageRouteArgs{key: $key, userId: $userId, email: $email, name: $name, avatarUrl: $avatarUrl}';
  }
}

/// generated route for
/// [_i2.ConfirmNewPasswordPage]
class ConfirmNewPasswordPageRoute extends _i22.PageRouteInfo<void> {
  const ConfirmNewPasswordPageRoute({List<_i22.PageRouteInfo>? children})
    : super(ConfirmNewPasswordPageRoute.name, initialChildren: children);

  static const String name = 'ConfirmNewPasswordPageRoute';

  static _i22.PageInfo page = _i22.PageInfo(
    name,
    builder: (data) {
      return const _i2.ConfirmNewPasswordPage();
    },
  );
}

/// generated route for
/// [_i3.CorePage]
class CorePageRoute extends _i22.PageRouteInfo<void> {
  const CorePageRoute({List<_i22.PageRouteInfo>? children})
    : super(CorePageRoute.name, initialChildren: children);

  static const String name = 'CorePageRoute';

  static _i22.PageInfo page = _i22.PageInfo(
    name,
    builder: (data) {
      return const _i3.CorePage();
    },
  );
}

/// generated route for
/// [_i4.DeckSelectionPage]
class DeckSelectionPageRoute
    extends _i22.PageRouteInfo<DeckSelectionPageRouteArgs> {
  DeckSelectionPageRoute({
    _i23.Key? key,
    required _i24.MatchInvitation invitation,
    List<_i22.PageRouteInfo>? children,
  }) : super(
         DeckSelectionPageRoute.name,
         args: DeckSelectionPageRouteArgs(key: key, invitation: invitation),
         initialChildren: children,
       );

  static const String name = 'DeckSelectionPageRoute';

  static _i22.PageInfo page = _i22.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<DeckSelectionPageRouteArgs>();
      return _i4.DeckSelectionPage(key: args.key, invitation: args.invitation);
    },
  );
}

class DeckSelectionPageRouteArgs {
  const DeckSelectionPageRouteArgs({this.key, required this.invitation});

  final _i23.Key? key;

  final _i24.MatchInvitation invitation;

  @override
  String toString() {
    return 'DeckSelectionPageRouteArgs{key: $key, invitation: $invitation}';
  }
}

/// generated route for
/// [_i5.DeckSelectionWizardPage]
class DeckSelectionWizardPageRoute
    extends _i22.PageRouteInfo<DeckSelectionWizardPageRouteArgs> {
  DeckSelectionWizardPageRoute({
    _i23.Key? key,
    required _i25.DeckFormat format,
    List<_i22.PageRouteInfo>? children,
  }) : super(
         DeckSelectionWizardPageRoute.name,
         args: DeckSelectionWizardPageRouteArgs(key: key, format: format),
         initialChildren: children,
       );

  static const String name = 'DeckSelectionWizardPageRoute';

  static _i22.PageInfo page = _i22.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<DeckSelectionWizardPageRouteArgs>();
      return _i5.DeckSelectionWizardPage(key: args.key, format: args.format);
    },
  );
}

class DeckSelectionWizardPageRouteArgs {
  const DeckSelectionWizardPageRouteArgs({this.key, required this.format});

  final _i23.Key? key;

  final _i25.DeckFormat format;

  @override
  String toString() {
    return 'DeckSelectionWizardPageRouteArgs{key: $key, format: $format}';
  }
}

/// generated route for
/// [_i6.DecksPage]
class DecksPageRoute extends _i22.PageRouteInfo<void> {
  const DecksPageRoute({List<_i22.PageRouteInfo>? children})
    : super(DecksPageRoute.name, initialChildren: children);

  static const String name = 'DecksPageRoute';

  static _i22.PageInfo page = _i22.PageInfo(
    name,
    builder: (data) {
      return const _i6.DecksPage();
    },
  );
}

/// generated route for
/// [_i7.FormatSelectionPage]
class FormatSelectionPageRoute extends _i22.PageRouteInfo<void> {
  const FormatSelectionPageRoute({List<_i22.PageRouteInfo>? children})
    : super(FormatSelectionPageRoute.name, initialChildren: children);

  static const String name = 'FormatSelectionPageRoute';

  static _i22.PageInfo page = _i22.PageInfo(
    name,
    builder: (data) {
      return const _i7.FormatSelectionPage();
    },
  );
}

/// generated route for
/// [_i8.FriendsTab]
class FriendsTabRoute extends _i22.PageRouteInfo<void> {
  const FriendsTabRoute({List<_i22.PageRouteInfo>? children})
    : super(FriendsTabRoute.name, initialChildren: children);

  static const String name = 'FriendsTabRoute';

  static _i22.PageInfo page = _i22.PageInfo(
    name,
    builder: (data) {
      return const _i8.FriendsTab();
    },
  );
}

/// generated route for
/// [_i9.HomePage]
class HomePageRoute extends _i22.PageRouteInfo<void> {
  const HomePageRoute({List<_i22.PageRouteInfo>? children})
    : super(HomePageRoute.name, initialChildren: children);

  static const String name = 'HomePageRoute';

  static _i22.PageInfo page = _i22.PageInfo(
    name,
    builder: (data) {
      return const _i9.HomePage();
    },
  );
}

/// generated route for
/// [_i10.HomeTab]
class HomeTabRoute extends _i22.PageRouteInfo<void> {
  const HomeTabRoute({List<_i22.PageRouteInfo>? children})
    : super(HomeTabRoute.name, initialChildren: children);

  static const String name = 'HomeTabRoute';

  static _i22.PageInfo page = _i22.PageInfo(
    name,
    builder: (data) {
      return const _i10.HomeTab();
    },
  );
}

/// generated route for
/// [_i11.LoginPage]
class LoginPageRoute extends _i22.PageRouteInfo<void> {
  const LoginPageRoute({List<_i22.PageRouteInfo>? children})
    : super(LoginPageRoute.name, initialChildren: children);

  static const String name = 'LoginPageRoute';

  static _i22.PageInfo page = _i22.PageInfo(
    name,
    builder: (data) {
      return const _i11.LoginPage();
    },
  );
}

/// generated route for
/// [_i12.MatchDetailPage]
class MatchDetailPageRoute
    extends _i22.PageRouteInfo<MatchDetailPageRouteArgs> {
  MatchDetailPageRoute({
    _i23.Key? key,
    required Map<String, dynamic> match,
    List<_i22.PageRouteInfo>? children,
  }) : super(
         MatchDetailPageRoute.name,
         args: MatchDetailPageRouteArgs(key: key, match: match),
         initialChildren: children,
       );

  static const String name = 'MatchDetailPageRoute';

  static _i22.PageInfo page = _i22.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<MatchDetailPageRouteArgs>();
      return _i12.MatchDetailPage(key: args.key, match: args.match);
    },
  );
}

class MatchDetailPageRouteArgs {
  const MatchDetailPageRouteArgs({this.key, required this.match});

  final _i23.Key? key;

  final Map<String, dynamic> match;

  @override
  String toString() {
    return 'MatchDetailPageRouteArgs{key: $key, match: $match}';
  }
}

/// generated route for
/// [_i13.MatchInvitationDetailPage]
class MatchInvitationDetailPageRoute
    extends _i22.PageRouteInfo<MatchInvitationDetailPageRouteArgs> {
  MatchInvitationDetailPageRoute({
    _i23.Key? key,
    required _i24.MatchInvitation invitation,
    required bool isReceived,
    List<_i22.PageRouteInfo>? children,
  }) : super(
         MatchInvitationDetailPageRoute.name,
         args: MatchInvitationDetailPageRouteArgs(
           key: key,
           invitation: invitation,
           isReceived: isReceived,
         ),
         initialChildren: children,
       );

  static const String name = 'MatchInvitationDetailPageRoute';

  static _i22.PageInfo page = _i22.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<MatchInvitationDetailPageRouteArgs>();
      return _i13.MatchInvitationDetailPage(
        key: args.key,
        invitation: args.invitation,
        isReceived: args.isReceived,
      );
    },
  );
}

class MatchInvitationDetailPageRouteArgs {
  const MatchInvitationDetailPageRouteArgs({
    this.key,
    required this.invitation,
    required this.isReceived,
  });

  final _i23.Key? key;

  final _i24.MatchInvitation invitation;

  final bool isReceived;

  @override
  String toString() {
    return 'MatchInvitationDetailPageRouteArgs{key: $key, invitation: $invitation, isReceived: $isReceived}';
  }
}

/// generated route for
/// [_i14.MatchResultPage]
class MatchResultPageRoute
    extends _i22.PageRouteInfo<MatchResultPageRouteArgs> {
  MatchResultPageRoute({
    _i23.Key? key,
    required Map<String, dynamic> match,
    List<_i22.PageRouteInfo>? children,
  }) : super(
         MatchResultPageRoute.name,
         args: MatchResultPageRouteArgs(key: key, match: match),
         initialChildren: children,
       );

  static const String name = 'MatchResultPageRoute';

  static _i22.PageInfo page = _i22.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<MatchResultPageRouteArgs>();
      return _i14.MatchResultPage(key: args.key, match: args.match);
    },
  );
}

class MatchResultPageRouteArgs {
  const MatchResultPageRouteArgs({this.key, required this.match});

  final _i23.Key? key;

  final Map<String, dynamic> match;

  @override
  String toString() {
    return 'MatchResultPageRouteArgs{key: $key, match: $match}';
  }
}

/// generated route for
/// [_i15.MatchResultsPage]
class MatchResultsPageRoute
    extends _i22.PageRouteInfo<MatchResultsPageRouteArgs> {
  MatchResultsPageRoute({
    _i23.Key? key,
    required _i25.DeckFormat format,
    required String playerDeckId,
    required String opponentId,
    List<_i22.PageRouteInfo>? children,
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

  static _i22.PageInfo page = _i22.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<MatchResultsPageRouteArgs>();
      return _i15.MatchResultsPage(
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

  final _i23.Key? key;

  final _i25.DeckFormat format;

  final String playerDeckId;

  final String opponentId;

  @override
  String toString() {
    return 'MatchResultsPageRouteArgs{key: $key, format: $format, playerDeckId: $playerDeckId, opponentId: $opponentId}';
  }
}

/// generated route for
/// [_i16.OpponentSearchPage]
class OpponentSearchPageRoute
    extends _i22.PageRouteInfo<OpponentSearchPageRouteArgs> {
  OpponentSearchPageRoute({
    _i23.Key? key,
    required _i25.DeckFormat format,
    required String selectedDeckId,
    List<_i22.PageRouteInfo>? children,
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

  static _i22.PageInfo page = _i22.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<OpponentSearchPageRouteArgs>();
      return _i22.WrappedRoute(
        child: _i16.OpponentSearchPage(
          key: args.key,
          format: args.format,
          selectedDeckId: args.selectedDeckId,
        ),
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

  final _i23.Key? key;

  final _i25.DeckFormat format;

  final String selectedDeckId;

  @override
  String toString() {
    return 'OpponentSearchPageRouteArgs{key: $key, format: $format, selectedDeckId: $selectedDeckId}';
  }
}

/// generated route for
/// [_i17.ProfileTab]
class ProfileTabRoute extends _i22.PageRouteInfo<void> {
  const ProfileTabRoute({List<_i22.PageRouteInfo>? children})
    : super(ProfileTabRoute.name, initialChildren: children);

  static const String name = 'ProfileTabRoute';

  static _i22.PageInfo page = _i22.PageInfo(
    name,
    builder: (data) {
      return const _i17.ProfileTab();
    },
  );
}

/// generated route for
/// [_i18.RecoveryPasswordPage]
class RecoveryPasswordPageRoute
    extends _i22.PageRouteInfo<RecoveryPasswordPageRouteArgs> {
  RecoveryPasswordPageRoute({_i23.Key? key, List<_i22.PageRouteInfo>? children})
    : super(
        RecoveryPasswordPageRoute.name,
        args: RecoveryPasswordPageRouteArgs(key: key),
        initialChildren: children,
      );

  static const String name = 'RecoveryPasswordPageRoute';

  static _i22.PageInfo page = _i22.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<RecoveryPasswordPageRouteArgs>(
        orElse: () => const RecoveryPasswordPageRouteArgs(),
      );
      return _i18.RecoveryPasswordPage(key: args.key);
    },
  );
}

class RecoveryPasswordPageRouteArgs {
  const RecoveryPasswordPageRouteArgs({this.key});

  final _i23.Key? key;

  @override
  String toString() {
    return 'RecoveryPasswordPageRouteArgs{key: $key}';
  }
}

/// generated route for
/// [_i19.RegisterPage]
class RegisterPageRoute extends _i22.PageRouteInfo<void> {
  const RegisterPageRoute({List<_i22.PageRouteInfo>? children})
    : super(RegisterPageRoute.name, initialChildren: children);

  static const String name = 'RegisterPageRoute';

  static _i22.PageInfo page = _i22.PageInfo(
    name,
    builder: (data) {
      return const _i19.RegisterPage();
    },
  );
}

/// generated route for
/// [_i20.TournamentsTab]
class TournamentsTabRoute extends _i22.PageRouteInfo<void> {
  const TournamentsTabRoute({List<_i22.PageRouteInfo>? children})
    : super(TournamentsTabRoute.name, initialChildren: children);

  static const String name = 'TournamentsTabRoute';

  static _i22.PageInfo page = _i22.PageInfo(
    name,
    builder: (data) {
      return const _i20.TournamentsTab();
    },
  );
}

/// generated route for
/// [_i21.UserProfilePage]
class UserProfilePageRoute
    extends _i22.PageRouteInfo<UserProfilePageRouteArgs> {
  UserProfilePageRoute({
    _i23.Key? key,
    required String userId,
    required String username,
    String? avatarUrl,
    String? displayName,
    List<_i22.PageRouteInfo>? children,
  }) : super(
         UserProfilePageRoute.name,
         args: UserProfilePageRouteArgs(
           key: key,
           userId: userId,
           username: username,
           avatarUrl: avatarUrl,
           displayName: displayName,
         ),
         initialChildren: children,
       );

  static const String name = 'UserProfilePageRoute';

  static _i22.PageInfo page = _i22.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<UserProfilePageRouteArgs>();
      return _i21.UserProfilePage(
        key: args.key,
        userId: args.userId,
        username: args.username,
        avatarUrl: args.avatarUrl,
        displayName: args.displayName,
      );
    },
  );
}

class UserProfilePageRouteArgs {
  const UserProfilePageRouteArgs({
    this.key,
    required this.userId,
    required this.username,
    this.avatarUrl,
    this.displayName,
  });

  final _i23.Key? key;

  final String userId;

  final String username;

  final String? avatarUrl;

  final String? displayName;

  @override
  String toString() {
    return 'UserProfilePageRouteArgs{key: $key, userId: $userId, username: $username, avatarUrl: $avatarUrl, displayName: $displayName}';
  }
}
