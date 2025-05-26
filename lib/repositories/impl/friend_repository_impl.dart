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
      
      // Richiediamo i dati dei profili separatamente
      final friendRequests = <FriendRequest>[];
      
      for (final data in requestsData) {
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
          // Crea una richiesta di amicizia di base
          final request = FriendRequest.fromJson(convertedData);
          print('Successfully converted to FriendRequest: ${request.id}');
          
          // Recupera i dati del mittente dalla tabella profiles
          try {
            final senderId = data['user_id'];
            print('Attempting to find user profile for sender ID: $senderId');
            
            final senderResponse = await _supabase
                .from('profiles')
                .select()
                .eq('id', senderId)
                .single();
            
            print('Sender profile data: $senderResponse');
            
            if (senderResponse != null) {
              final senderProfile = UserProfile(
                id: senderResponse['id'],
                username: senderResponse['username'] ?? 'Utente',
                avatarUrl: senderResponse['avatar_url'],
                displayName: senderResponse['display_name'],
              );
              
              print('Created UserProfile for sender: ${senderProfile.username}');
              
              // Aggiunge il profilo alla richiesta
              final updatedRequest = request.copyWith(sender: senderProfile);
              friendRequests.add(updatedRequest);
            } else {
              // Fallback se non c'è risposta
              friendRequests.add(request);
            }
          } catch (profileError) {
            print('ERROR: Failed to fetch sender profile: $profileError');
            // Fallback in caso di errore
            friendRequests.add(request);
          }
        } catch (e) {
          print('ERROR: Failed to convert to FriendRequest: $e');
          rethrow;
        }
      }
      
      print('Repository: Returning ${friendRequests.length} friend requests');
      return friendRequests;
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
      
      print('Found ${friendsData.length} friend relationships, fetching profile details');
      
      final List<UserProfile> friends = [];
      
      for (final data in friendsData) {
        // Determina l'ID dell'amico (non l'utente corrente)
        final friendId = data['user_id'] == currentUserId
            ? data['friend_id']
            : data['user_id'];
        
        print('Looking up profile for friend ID: $friendId');
        
        try {
          // Recupera il profilo completo dell'amico
          final friendProfile = await _supabase
              .from('profiles')
              .select()
              .eq('id', friendId)
              .single();
          
          if (friendProfile != null) {
            print('Found profile: ${friendProfile['username']}');
            
            friends.add(UserProfile(
              id: friendId,
              username: friendProfile['username'] ?? 'Utente',
              avatarUrl: friendProfile['avatar_url'],
              displayName: friendProfile['display_name'],
            ));
          } else {
            // Fallback se il profilo non è stato trovato
            print('Profile not found, using minimal data');
            friends.add(UserProfile(
              id: friendId,
              username: 'Utente',
              avatarUrl: null,
              displayName: null,
            ));
          }
        } catch (profileError) {
          print('Error fetching profile data: $profileError');
          // Fallback in caso di errore
          friends.add(UserProfile(
            id: friendId,
            username: 'Utente',
            avatarUrl: null,
            displayName: null,
          ));
        }
      }
      
      print('Returning ${friends.length} friend profiles');
      return friends;
    } catch (e) {
      print('Error in getFriends: $e');
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
    // Riutilizziamo il metodo getPendingFriendRequests per evitare duplicazione
    try {
      print('Repository: getAll - Delegating to getPendingFriendRequests');
      return await getPendingFriendRequests();
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

  /// Debug utility to get all friendship data
  Future<Map<String, dynamic>> debugAllFriendships() async {
    try {
      print('Repository: Running friendship debug function');
      final debugData = await _friendService.debugGetFriends();
      print('Repository: Received debug data');
      return debugData;
    } catch (e) {
      print('Repository ERROR in debugAllFriendships: $e');
      rethrow;
    }
  }

  @override
  Future<bool> isFriendOrPending(String userId) async {
    try {
      final currentUserId = _supabase.auth.currentUser?.id;
      if (currentUserId == null) {
        throw Exception('User not authenticated');
      }
      
      // Cerca se c'è già un'amicizia accettata o una richiesta pendente
      final existingRelations = await _supabase
          .from('friends')
          .select()
          .or('and(user_id.eq.$currentUserId,friend_id.eq.$userId),and(user_id.eq.$userId,friend_id.eq.$currentUserId)')
          .or('status.eq.accepted,status.eq.pending');
      
      return existingRelations.isNotEmpty;
    } catch (e) {
      print('Error checking friendship status: $e');
      // In caso di errore, ritorna false per garantire che l'utente venga mostrato nei risultati
      return false;
    }
  }

  @override
  Future<void> removeFriend(String friendId) async {
    try {
      final currentUserId = _supabase.auth.currentUser?.id;
      if (currentUserId == null) {
        throw Exception('User not authenticated');
      }
      
      print('Removing friend with ID: $friendId');
      
      // Trova la relazione di amicizia
      final relations = await _supabase
          .from('friends')
          .select()
          .or('and(user_id.eq.$currentUserId,friend_id.eq.$friendId),and(user_id.eq.$friendId,friend_id.eq.$currentUserId)')
          .eq('status', 'accepted');
      
      if (relations.isEmpty) {
        throw Exception('Amicizia non trovata');
      }
      
      // Elimina la relazione di amicizia
      await _supabase
          .from('friends')
          .delete()
          .eq('id', relations[0]['id']);
      
      print('Friendship removed successfully');
    } catch (e) {
      print('Error removing friendship: $e');
      rethrow;
    }
  }
} 