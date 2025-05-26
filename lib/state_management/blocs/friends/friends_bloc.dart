import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:topdeck_app_flutter/repositories/friend_repository.dart';
import 'package:topdeck_app_flutter/repositories/impl/friend_repository_impl.dart';
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
    on<RemoveFriendEvent>(_onRemoveFriend);
    on<DebugFriendshipsEvent>(_onDebugFriendships);
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
      
      // Ricarica anche la lista degli amici
      add(LoadFriendsEvent());
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
  
  /// Gestisce l'evento RemoveFriendEvent
  Future<void> _onRemoveFriend(
    RemoveFriendEvent event,
    Emitter<FriendsState> emit,
  ) async {
    emit(FriendsLoading());
    try {
      await _friendRepository.removeFriend(event.friendId);
      emit(FriendRemoved(event.friendId));
      
      // Ricarica la lista degli amici dopo la rimozione
      add(LoadFriendsEvent());
    } catch (e) {
      emit(FriendsError('Impossibile rimuovere l\'amicizia: ${e.toString()}'));
    }
  }
  
  /// Gestisce l'evento DebugFriendshipsEvent
  Future<void> _onDebugFriendships(
    DebugFriendshipsEvent event,
    Emitter<FriendsState> emit,
  ) async {
    print('FriendsBloc: Starting friendship debug');
    emit(FriendsLoading());
    try {
      print('FriendsBloc: Calling repository debug function');
      
      if (_friendRepository is FriendRepositoryImpl) {
        final debugData = await (_friendRepository as FriendRepositoryImpl).debugAllFriendships();
        print('FriendsBloc: Received debug data');
        
        // Stampare informazioni rilevanti
        print('FriendsBloc DEBUG: Total records: ${debugData['summary']['total']}');
        print('FriendsBloc DEBUG: Incoming: ${debugData['summary']['incoming']}');
        print('FriendsBloc DEBUG: Outgoing: ${debugData['summary']['outgoing']}');
        print('FriendsBloc DEBUG: Accepted: ${debugData['summary']['accepted']}');
        
        emit(FriendshipsDebugLoaded(debugData));
        print('FriendsBloc: Emitted FriendshipsDebugLoaded state');
      } else {
        throw Exception('Repository implementation does not support debugging');
      }
    } catch (e) {
      print('FriendsBloc ERROR: Failed to debug friendships: $e');
      emit(FriendsError('Failed to debug friendships: ${e.toString()}'));
      print('FriendsBloc: Emitted FriendsError state');
    }
  }
} 