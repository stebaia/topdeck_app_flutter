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
    print('FriendsBloc: Loading friend requests');
    emit(FriendsLoading());
    try {
      print('FriendsBloc: Calling repository.getPendingFriendRequests()');
      final requests = await _friendRepository.getPendingFriendRequests();
      print('FriendsBloc: Loaded ${requests.length} friend requests');
      for (final request in requests) {
        print('FriendsBloc: Request from ${request.senderId} to ${request.recipientId} (status: ${request.status})');
      }
      emit(FriendRequestsLoaded(requests));
      print('FriendsBloc: Emitted FriendRequestsLoaded state');
    } catch (e) {
      print('FriendsBloc ERROR: Failed to load friend requests: $e');
      emit(FriendsError('Failed to load friend requests: ${e.toString()}'));
      print('FriendsBloc: Emitted FriendsError state');
    }
  }
  
  /// Gestisce l'evento LoadFriendsEvent
  Future<void> _onLoadFriends(
    LoadFriendsEvent event,
    Emitter<FriendsState> emit,
  ) async {
    print('FriendsBloc: Loading friends list');
    emit(FriendsLoading());
    try {
      print('FriendsBloc: Calling repository.getFriends()');
      final friends = await _friendRepository.getFriends();
      print('FriendsBloc: Loaded ${friends.length} friends');
      for (final friend in friends) {
        print('FriendsBloc: Friend ${friend.id} - ${friend.username}');
      }
      emit(FriendsLoaded(friends));
      print('FriendsBloc: Emitted FriendsLoaded state');
    } catch (e) {
      print('FriendsBloc ERROR: Failed to load friends: $e');
      emit(FriendsError('Failed to load friends: ${e.toString()}'));
      print('FriendsBloc: Emitted FriendsError state');
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