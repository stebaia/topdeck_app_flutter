import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:topdeck_app_flutter/repositories/auth_repository.dart';

/// Authentication guard for protecting routes that require authentication
class AuthGuard extends AutoRouteGuard {
  @override
  void onNavigation(NavigationResolver resolver, StackRouter router) {
    final BuildContext? context = router.navigatorKey.currentContext;
    
    // If we can't access the context, redirect to login to be safe
    if (context == null) {
      router.pushNamed('/login');
      resolver.next(false);
      return;
    }
    
    // Try-catch to handle cases where providers aren't fully initialized
    try {
      // Use Provider.of with listen: false instead of context.read
      // This accesses the provider more safely during initialization
      final AuthRepository authRepository = Provider.of<AuthRepository>(
        context, 
        listen: false
      );
      
      // Check if the user is authenticated
      if (authRepository.isAuthenticated()) {
        // User is authenticated, allow navigation
        resolver.next(true);
      } else {
        // User is not authenticated, redirect to login
        router.pushNamed('/login');
        // Block navigation to the protected route
        resolver.next(false);
      }
    } catch (e) {
      debugPrint('AuthGuard error: $e');
      // Error accessing providers - likely during initialization
      // Redirect to core route which will handle auth check when providers are ready
      router.replaceNamed('/');
      resolver.next(false);
    }
  }
} 