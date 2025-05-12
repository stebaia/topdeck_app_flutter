import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:auto_route/auto_route.dart';
import 'package:provider/provider.dart';
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
        if (state is AuthenticatedState) {
          // If authenticated, redirect to home
          context.router.replaceNamed('/home');
        } else if (state is UnauthenticatedState) {
          // If not authenticated, redirect to login
          context.router.replaceNamed('/login');
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