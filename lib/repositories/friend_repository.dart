import 'package:topdeck_app_flutter/model/entities/friend_request.dart';
import 'package:topdeck_app_flutter/model/user.dart';
import 'package:topdeck_app_flutter/repositories/base_repository.dart';

/// Repository interface for friend-related operations
abstract class FriendRepository extends BaseRepository<FriendRequest> {
  /// Sends a friend request to another user
  Future<void> sendFriendRequest(String recipientId);
  
  /// Accepts a friend request from another user
  Future<void> acceptFriendRequest(String friendId);
  
  /// Declines a friend request from another user
  Future<void> declineFriendRequest(String friendId);
  
  /// Gets all pending friend requests for the current user
  Future<List<FriendRequest>> getPendingFriendRequests();
  
  /// Gets all friends of the current user
  Future<List<UserProfile>> getFriends();
} 