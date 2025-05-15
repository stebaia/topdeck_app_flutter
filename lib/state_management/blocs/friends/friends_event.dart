import 'package:equatable/equatable.dart';

/// Eventi per il bloc degli amici
abstract class FriendsEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

/// Evento per caricare le richieste di amicizia
class LoadFriendRequestsEvent extends FriendsEvent {}

/// Evento per caricare la lista degli amici
class LoadFriendsEvent extends FriendsEvent {}

/// Evento per inviare una richiesta di amicizia
class SendFriendRequestEvent extends FriendsEvent {
  /// ID dell'utente a cui inviare la richiesta
  final String recipientId;
  
  /// Costruttore
  SendFriendRequestEvent(this.recipientId);
  
  @override
  List<Object?> get props => [recipientId];
}

/// Evento per accettare una richiesta di amicizia
class AcceptFriendRequestEvent extends FriendsEvent {
  /// ID dell'utente che ha inviato la richiesta
  final String friendId;
  
  /// Costruttore
  AcceptFriendRequestEvent(this.friendId);
  
  @override
  List<Object?> get props => [friendId];
}

/// Evento per rifiutare una richiesta di amicizia
class DeclineFriendRequestEvent extends FriendsEvent {
  /// ID dell'utente che ha inviato la richiesta
  final String friendId;
  
  /// Costruttore
  DeclineFriendRequestEvent(this.friendId);
  
  @override
  List<Object?> get props => [friendId];
} 