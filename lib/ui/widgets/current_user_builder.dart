import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:topdeck_app_flutter/state_management/blocs/auth/auth_bloc.dart';
import 'package:topdeck_app_flutter/state_management/blocs/auth/auth_state.dart';
import 'package:topdeck_app_flutter/model/user.dart';

/// Widget helper che fornisce l'utente corrente dal AuthBloc
/// Semplifica l'accesso all'utente autenticato in tutta l'app
class CurrentUserBuilder extends StatelessWidget {
  /// Builder che riceve l'utente corrente
  final Widget Function(BuildContext context, UserProfile currentUser) builder;
  
  /// Widget da mostrare quando l'utente non è autenticato
  final Widget? unauthenticatedWidget;
  
  /// Widget da mostrare durante il caricamento
  final Widget? loadingWidget;
  
  /// Constructor
  const CurrentUserBuilder({
    Key? key,
    required this.builder,
    this.unauthenticatedWidget,
    this.loadingWidget,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        // Stato di caricamento
        if (authState is AuthLoadingState) {
          return loadingWidget ?? const Center(child: CircularProgressIndicator());
        }
        
        // Utente autenticato
        if (authState is AuthenticatedState) {
          // Converti Profile in UserProfile per compatibilità
          final currentUser = UserProfile(
            id: authState.profile.id,
            username: authState.profile.username,
            avatarUrl: authState.profile.avatarUrl,
            displayName: '${authState.profile.nome} ${authState.profile.cognome}'.trim(),
          );
          
          return builder(context, currentUser);
        }
        
        // Utente non autenticato o altri stati
        return unauthenticatedWidget ?? const Center(
          child: Text('Utente non autenticato'),
        );
      },
    );
  }
}

/// Metodo di utilità per ottenere l'utente corrente in modo sincrono
/// Restituisce null se l'utente non è autenticato
class CurrentUserHelper {
  /// Ottiene l'utente corrente dal context se disponibile
  static UserProfile? getCurrentUser(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    
    if (authState is AuthenticatedState) {
      return UserProfile(
        id: authState.profile.id,
        username: authState.profile.username,
        avatarUrl: authState.profile.avatarUrl,
        displayName: '${authState.profile.nome} ${authState.profile.cognome}'.trim(),
      );
    }
    
    return null;
  }
  
  /// Verifica se l'utente è autenticato
  static bool isAuthenticated(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    return authState is AuthenticatedState;
  }
  
  /// Ottiene l'ID dell'utente corrente
  static String? getCurrentUserId(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    
    if (authState is AuthenticatedState) {
      return authState.profile.id;
    }
    
    return null;
  }
} 