import 'package:equatable/equatable.dart';
import 'package:topdeck_app_flutter/model/entities/friend_request.dart';
import 'package:topdeck_app_flutter/model/user.dart';

/// Stati per il bloc degli amici
abstract class FriendsState extends Equatable {
  @override
  List<Object?> get props => [];
}

/// Stato iniziale
class FriendsInitial extends FriendsState {}

/// Stato di caricamento
class FriendsLoading extends FriendsState {}

/// Stato che rappresenta le richieste di amicizia caricate
class FriendRequestsLoaded extends FriendsState {
  /// Richieste di amicizia pendenti
  final List<FriendRequest> requests;
  
  /// Costruttore
  FriendRequestsLoaded(this.requests);
  
  @override
  List<Object?> get props => [requests];
}

/// Stato che rappresenta gli amici caricati
class FriendsLoaded extends FriendsState {
  /// Lista degli amici dell'utente corrente
  final List<UserProfile> friends;
  
  /// Costruttore
  FriendsLoaded(this.friends);
  
  @override
  List<Object?> get props => [friends];
}

/// Stato che rappresenta una richiesta di amicizia inviata
class FriendRequestSent extends FriendsState {
  /// ID dell'utente a cui è stata inviata la richiesta
  final String recipientId;
  
  /// Costruttore
  FriendRequestSent(this.recipientId);
  
  @override
  List<Object?> get props => [recipientId];
}

/// Stato che rappresenta una richiesta di amicizia accettata
class FriendRequestAccepted extends FriendsState {
  /// ID dell'utente la cui richiesta è stata accettata
  final String friendId;
  
  /// Costruttore
  FriendRequestAccepted(this.friendId);
  
  @override
  List<Object?> get props => [friendId];
}

/// Stato che rappresenta una richiesta di amicizia rifiutata
class FriendRequestDeclined extends FriendsState {
  /// ID dell'utente la cui richiesta è stata rifiutata
  final String friendId;
  
  /// Costruttore
  FriendRequestDeclined(this.friendId);
  
  @override
  List<Object?> get props => [friendId];
}

/// Stato che rappresenta un errore
class FriendsError extends FriendsState {
  /// Messaggio di errore
  final String message;
  
  /// Costruttore
  FriendsError(this.message);
  
  @override
  List<Object?> get props => [message];
}

/// Stato che rappresenta i dati di debug delle amicizie
class FriendshipsDebugLoaded extends FriendsState {
  /// Dati di debug
  final Map<String, dynamic> debugData;
  
  /// Costruttore
  FriendshipsDebugLoaded(this.debugData);
  
  @override
  List<Object?> get props => [debugData];
} 