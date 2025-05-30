import 'dart:developer';
import 'package:auto_route/auto_route.dart';
import 'package:app_links/app_links.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:topdeck_app_flutter/app.dart';
import 'package:topdeck_app_flutter/routers/app_router.gr.dart';

final class AppLinkService extends ChangeNotifier {
  AppLinkService._();

  static final instance = AppLinkService._();

  final _appLinks = AppLinks();

  /// Initializes the [AppLinkService].
  Future<void> initialize() async {
    // * Listens to the app links and manages navigation.
    _appLinks.uriLinkStream.listen(_handleLinkData).onError((error) {
      log('$error', name: 'App Link Service');
    });
  }

  /// Call it on the app start if your app does not starts the URI stream
  /// on app launch.
  Future<void> checkInitialLink() async {
    final initialLink = await _appLinks.getInitialLink();
    if (initialLink != null) {
      _handleLinkData(initialLink);
    }
  }

  /// Handles the link navigation for app Links.
  void _handleLinkData(Uri data) async {
    log(data.toString(), name: 'App Link Service');

    final context = router.navigatorKey.currentContext!;
    context.pushRoute(ConfirmNewPasswordPageRoute());
  }
}
