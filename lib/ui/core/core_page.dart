import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:auto_route/auto_route.dart';
import 'package:provider/provider.dart';
import 'package:topdeck_app_flutter/routers/app_router.gr.dart';
import 'package:topdeck_app_flutter/state_management/auth/auth_bloc.dart';
import 'package:topdeck_app_flutter/state_management/auth/auth_event.dart';
import 'package:topdeck_app_flutter/state_management/auth/auth_state.dart';

@RoutePage()
class CorePage extends StatefulWidget {
  const CorePage({super.key});

  @override
  State<CorePage> createState() => _CorePageState();
}

class _CorePageState extends State<CorePage> {
  bool _isInitialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Only run the initialization once
    if (!_isInitialized) {
      _isInitialized = true;
      _initAuthCheck();
    }
  }

  // Check if the current route is a public route that doesn't require authentication
  bool _isPublicRoute(String route) {
    final publicRoutes = ['/login', '/password-reset', '/confirm-password'];
    return publicRoutes.any((publicRoute) => route.startsWith(publicRoute));
  }

  // Check if the current route or URL contains password reset parameters
  bool _isPasswordResetDeepLink() {
    final currentRoute = context.router.current.path;

    // Check if it's a password reset route or confirm password route
    return currentRoute.contains('password-reset') ||
        currentRoute.contains('confirm-password') ||
        currentRoute.contains('confirm-new-password');
  }

  // Initialize auth check after dependencies are ready
  void _initAuthCheck() {
    try {
      // Use Provider.of with listen: false for safer provider access
      final authBloc = Provider.of<AuthBloc>(context, listen: false);

      // If we got here, providers are ready, check authentication
      authBloc.add(CheckAuthStatusEvent());
    } catch (e) {
      // Debug: print error for troubleshooting
      debugPrint('CorePage auth check error: $e');

      // If error occurred, schedule another attempt after the widget fully builds
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          Future.delayed(const Duration(milliseconds: 200), () {
            if (mounted) {
              _initAuthCheck();
            }
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        print('state: $state');
        if (state is AuthenticatedState) {
          // Check if this is a password reset deep link
          if (_isPasswordResetDeepLink()) {
            // If authenticated via password reset deep link, go to password reset page
            context.router.replaceNamed('/confirm-password');
          } else if (state is AuthPasswordResetState) {
            context.pushRoute(ConfirmNewPasswordPageRoute());
          } else {
            // If authenticated normally, redirect to home
            context.router.replaceNamed('/home');
          }
        } else if (state is UnauthenticatedState) {
          // Check if current route is public before redirecting to login
          final currentRoute = context.router.current.path;
          if (!_isPublicRoute(currentRoute)) {
            // If not authenticated and not on a public route, redirect to login
            context.router.replaceNamed('/login');
          } else if (state is AuthPasswordResetState) {
            context.pushRoute(ConfirmNewPasswordPageRoute());
          }
          // If on a public route, stay on current route
        } else if (state is AuthErrorState) {
          context.pushRoute(LoginPageRoute());
        } else if (state is AuthPasswordResetState) {
          context.pushRoute(ConfirmNewPasswordPageRoute());
        }
      },
      child: const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }
}
