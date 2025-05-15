import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:topdeck_app_flutter/model/entities/friend_request.dart';
import 'package:topdeck_app_flutter/model/user.dart';
import 'package:topdeck_app_flutter/network/service/impl/friend_service_impl.dart';
import 'package:topdeck_app_flutter/repositories/friend_repository.dart';

/// Implementation of the FriendRepository
class FriendRepositoryImpl implements FriendRepository {
  final FriendServiceImpl _friendService;
  final _supabase = Supabase.instance.client;

  /// Constructor
  FriendRepositoryImpl({required FriendServiceImpl friendService})
      : _friendService = friendService;

  @override
  Future<void> sendFriendRequest(String recipientId) async {
    try {
      print('Sending friend request to: $recipientId');
      final response = await _friendService.sendFriendRequest(recipientId);
      print('Friend request response: $response');
    } catch (e) {
      print('Error sending friend request: $e');
      rethrow;
    }
  }

  @override
  Future<void> acceptFriendRequest(String friendId) async {
    try {
      await _friendService.acceptFriendRequest(friendId);
    } catch (e) {
      rethrow;
    }
  }
  
  @override
  Future<void> declineFriendRequest(String friendId) async {
    try {
      // Implementare nel service quando disponibile
      throw UnimplementedError('Decline friend request not implemented yet');
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<FriendRequest>> getPendingFriendRequests() async {
    try {
      final requestsData = await _friendService.getFriendRequests();
      return requestsData.map((data) {
        // Convertiamo i campi della tabella friends al modello FriendRequest
        final Map<String, dynamic> convertedData = {
          'id': data['id'],
          'sender_id': data['user_id'],
          'recipient_id': data['friend_id'],
          'status': data['status'],
          'created_at': data['created_at']
        };
        return FriendRequest.fromJson(convertedData);
      }).toList();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<UserProfile>> getFriends() async {
    try {
      final friendsData = await _friendService.getFriends();
      final currentUserId = _supabase.auth.currentUser?.id;
      
      return friendsData.map((data) {
        final userId = data['user_id'] == currentUserId
            ? data['friend_id']
            : data['user_id'];
        
        // Se il server restituisce anche i dettagli dell'utente
        if (data['profiles'] != null) {
          return UserProfile.fromJson(data['profiles']);
        }
        
        // Altrimenti creo un profilo minimo con l'ID disponibile
        return UserProfile(
          id: userId,
          username: data['username'] ?? 'User',
          avatarUrl: data['avatar_url'],
          displayName: data['display_name'],
        );
      }).toList();
    } catch (e) {
      rethrow;
    }
  }
  
  // Implementazione dei metodi di BaseRepository
  
  @override
  Future<FriendRequest> create(FriendRequest entity) async {
    await sendFriendRequest(entity.recipientId);
    return entity;
  }

  @override
  Future<void> delete(String id) async {
    // Non implementato - le richieste non vengono eliminate ma declinate
    throw UnimplementedError('Delete not supported for friend requests');
  }

  @override
  Future<FriendRequest?> get(String id) async {
    // Recupero di una singola richiesta di amicizia dal server
    // Al momento non supportato dal service
    throw UnimplementedError('Get single friend request not implemented');
  }

  @override
  Future<List<FriendRequest>> getAll() async {
    // Recupera tutte le richieste di amicizia
    try {
      final requestsData = await _friendService.getFriendRequests();
      return requestsData.map((data) {
        // Convertiamo i campi della tabella friends al modello FriendRequest
        final Map<String, dynamic> convertedData = {
          'id': data['id'],
          'sender_id': data['user_id'],
          'recipient_id': data['friend_id'],
          'status': data['status'],
          'created_at': data['created_at']
        };
        return FriendRequest.fromJson(convertedData);
      }).toList();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<FriendRequest> update(FriendRequest entity) async {
    // Aggiorna lo stato di una richiesta di amicizia
    if (entity.status == FriendRequestStatus.accepted) {
      await acceptFriendRequest(entity.senderId);
    } else if (entity.status == FriendRequestStatus.declined) {
      await declineFriendRequest(entity.senderId);
    }
    return entity;
  }
} 