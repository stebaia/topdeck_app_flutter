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
      print('Repository: Fetching pending friend requests');
      final requestsData = await _friendService.getFriendRequests();
      print('Repository: Got ${requestsData.length} requests, beginning conversion');
      
      final requests = requestsData.map((data) {
        print('Converting request: $data');
        // Verifica la presenza di ogni campo richiesto
        if (data['id'] == null) print('WARNING: Missing id in friend request data');
        if (data['user_id'] == null) print('WARNING: Missing user_id in friend request data');
        if (data['friend_id'] == null) print('WARNING: Missing friend_id in friend request data');
        if (data['status'] == null) print('WARNING: Missing status in friend request data');
        
        // Convertiamo i campi della tabella friends al modello FriendRequest
        final Map<String, dynamic> convertedData = {
          'id': data['id'],
          'sender_id': data['user_id'],
          'recipient_id': data['friend_id'],
          'status': data['status'],
          'created_at': data['created_at']
        };
        
        print('Converted to: $convertedData');
        try {
          final request = FriendRequest.fromJson(convertedData);
          print('Successfully converted to FriendRequest: ${request.id}');
          return request;
        } catch (e) {
          print('ERROR: Failed to convert to FriendRequest: $e');
          rethrow;
        }
      }).toList();
      
      print('Repository: Returning ${requests.length} friend requests');
      return requests;
    } catch (e) {
      print('Repository ERROR: Failed to get pending friend requests: $e');
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
      print('Repository: getAll - Fetching all friend requests');
      final requestsData = await _friendService.getFriendRequests();
      print('Repository: getAll - Got ${requestsData.length} requests');
      
      final requests = requestsData.map((data) {
        print('getAll - Converting request: $data');
        
        // Convertiamo i campi della tabella friends al modello FriendRequest
        final Map<String, dynamic> convertedData = {
          'id': data['id'],
          'sender_id': data['user_id'],
          'recipient_id': data['friend_id'],
          'status': data['status'],
          'created_at': data['created_at']
        };
        
        try {
          return FriendRequest.fromJson(convertedData);
        } catch (e) {
          print('ERROR in getAll: Failed to convert to FriendRequest: $e');
          rethrow;
        }
      }).toList();
      
      print('Repository: getAll - Returning ${requests.length} friend requests');
      return requests;
    } catch (e) {
      print('Repository ERROR in getAll: $e');
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