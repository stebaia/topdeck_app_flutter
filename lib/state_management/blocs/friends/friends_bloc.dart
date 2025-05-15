import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:topdeck_app_flutter/repositories/friend_repository.dart';
import 'package:topdeck_app_flutter/state_management/blocs/friends/friends_event.dart';
import 'package:topdeck_app_flutter/state_management/blocs/friends/friends_state.dart';

/// Bloc per la gestione delle richieste di amicizia e degli amici
class FriendsBloc extends Bloc<FriendsEvent, FriendsState> {
  final FriendRepository _friendRepository;
  
  /// Costruttore
  FriendsBloc({required FriendRepository friendRepository})
      : _friendRepository = friendRepository,
        super(FriendsInitial()) {
    on<LoadFriendRequestsEvent>(_onLoadFriendRequests);
    on<LoadFriendsEvent>(_onLoadFriends);
    on<SendFriendRequestEvent>(_onSendFriendRequest);
    on<AcceptFriendRequestEvent>(_onAcceptFriendRequest);
    on<DeclineFriendRequestEvent>(_onDeclineFriendRequest);
  }
  
  /// Gestisce l'evento LoadFriendRequestsEvent
  Future<void> _onLoadFriendRequests(
    LoadFriendRequestsEvent event,
    Emitter<FriendsState> emit,
  ) async {
    emit(FriendsLoading());
    try {
      final requests = await _friendRepository.getPendingFriendRequests();
      emit(FriendRequestsLoaded(requests));
    } catch (e) {
      emit(FriendsError('Failed to load friend requests: ${e.toString()}'));
    }
  }
  
  /// Gestisce l'evento LoadFriendsEvent
  Future<void> _onLoadFriends(
    LoadFriendsEvent event,
    Emitter<FriendsState> emit,
  ) async {
    emit(FriendsLoading());
    try {
      final friends = await _friendRepository.getFriends();
      emit(FriendsLoaded(friends));
    } catch (e) {
      emit(FriendsError('Failed to load friends: ${e.toString()}'));
    }
  }
  
  /// Gestisce l'evento SendFriendRequestEvent
  Future<void> _onSendFriendRequest(
    SendFriendRequestEvent event,
    Emitter<FriendsState> emit,
  ) async {
    emit(FriendsLoading());
    try {
      await _friendRepository.sendFriendRequest(event.recipientId);
      emit(FriendRequestSent(event.recipientId));
    } catch (e) {
      emit(FriendsError('Failed to send friend request: ${e.toString()}'));
    }
  }
  
  /// Gestisce l'evento AcceptFriendRequestEvent
  Future<void> _onAcceptFriendRequest(
    AcceptFriendRequestEvent event,
    Emitter<FriendsState> emit,
  ) async {
    emit(FriendsLoading());
    try {
      await _friendRepository.acceptFriendRequest(event.friendId);
      emit(FriendRequestAccepted(event.friendId));
      
      // Ricarica la lista delle richieste dopo aver accettato
      add(LoadFriendRequestsEvent());
    } catch (e) {
      emit(FriendsError('Failed to accept friend request: ${e.toString()}'));
    }
  }
  
  /// Gestisce l'evento DeclineFriendRequestEvent
  Future<void> _onDeclineFriendRequest(
    DeclineFriendRequestEvent event,
    Emitter<FriendsState> emit,
  ) async {
    emit(FriendsLoading());
    try {
      await _friendRepository.declineFriendRequest(event.friendId);
      emit(FriendRequestDeclined(event.friendId));
      
      // Ricarica la lista delle richieste dopo aver rifiutato
      add(LoadFriendRequestsEvent());
    } catch (e) {
      emit(FriendsError('Failed to decline friend request: ${e.toString()}'));
    }
  }
} 