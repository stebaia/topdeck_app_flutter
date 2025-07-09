import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:topdeck_app_flutter/network/service/room_service.dart';
import 'package:topdeck_app_flutter/model/entities/duel_room.dart';
import 'package:topdeck_app_flutter/model/entities/life_point.dart';
import 'package:topdeck_app_flutter/network/supabase_config.dart';

class RoomServiceImpl extends RoomService {
  final SupabaseClient _supabase = supabase;

  // Stream controller for real-time life points updates
  final Map<int, StreamController<List<LifePoint>>> _lifePointControllers = {};
  
  // Map to keep track of real-time subscriptions
  final Map<int, RealtimeChannel> _subscriptions = {};

  @override
  Future<DuelRoom> createDuelRoom(String player1Id, String player2Id) async {
    try {
      final roomData = {
        'player1_id': player1Id,
        'player2_id': player2Id,
        'is_active': true,
      };

      // Insert room into database
      final response = await _supabase
          .from('room')
          .insert(roomData)
          .select()
          .single();

      final createdRoom = DuelRoom.fromJson(response);

      // Initialize life points for both players (starting at 8000 LP each)
      await _initializeLifePoints(createdRoom.roomId, player1Id, player2Id);

      return createdRoom;
    } catch (e) {
      throw Exception('Failed to create duel room: $e');
    }
  }

  @override
  Future<DuelRoom> getDuelRoom(String id) async {
    try {
      final roomId = int.parse(id);
      final response = await _supabase
          .from('room')
          .select()
          .eq('id', roomId)
          .single();

      return DuelRoom.fromJson(response);
    } catch (e) {
      throw Exception('Failed to get duel room: $e');
    }
  }

  @override
  Future<DuelRoom> getDuelRoomByMatchId(String matchId) async {
    try {
      final response = await _supabase
          .from('room')
          .select()
          .eq('match_id', matchId)
          .single();

      return DuelRoom.fromJson(response);
    } catch (e) {
      throw Exception('Failed to get duel room by match ID: $e');
    }
  }

  @override
  Future<DuelRoom> updateDuelRoom(DuelRoom duelRoom) async {
    try {
      final response = await _supabase
          .from('room')
          .update({
            'player1_id': duelRoom.player1Id,
            'player2_id': duelRoom.player2Id,
            'is_active': duelRoom.isActive,
          })
          .eq('id', duelRoom.roomId)
          .select()
          .single();

      return DuelRoom.fromJson(response);
    } catch (e) {
      throw Exception('Failed to update duel room: $e');
    }
  }

  @override
  Future<void> deleteDuelRoom(String id) async {
    try {
      final roomId = int.parse(id);
      
      // Stop real-time subscription if exists
      await stopRealTimeSubscription(id);
      
      // Delete life points first (due to foreign key constraint)
      await _supabase
          .from('life_points')
          .delete()
          .eq('room_id', roomId);

      // Delete the room
      await _supabase
          .from('room')
          .delete()
          .eq('id', roomId);

    } catch (e) {
      throw Exception('Failed to delete duel room: $e');
    }
  }

  /// Initialize life points for both players
  Future<void> _initializeLifePoints(int roomId, String player1Id, String player2Id) async {
    try {
      const initialLifePoints = 8000;

      final lifePointsData = [
        {
          'life': initialLifePoints,
          'room_id': roomId,
          'player_id': player1Id,
        },
        {
          'life': initialLifePoints,
          'room_id': roomId,
          'player_id': player2Id,
        },
      ];

      await _supabase
          .from('life_points')
          .insert(lifePointsData);

    } catch (e) {
      throw Exception('Failed to initialize life points: $e');
    }
  }

  /// Get current life points for a room
  Future<List<LifePoint>> getLifePoints(String roomId) async {
    try {
      final id = int.parse(roomId);
      final response = await _supabase
          .from('life_points')
          .select()
          .eq('room_id', id);

      return response.map<LifePoint>((json) => LifePoint.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to get life points: $e');
    }
  }

  /// Update life points for a specific player in REAL-TIME
  Future<void> updateLifePoints(String roomId, String playerId, int newLifePoints) async {
    try {
      final id = int.parse(roomId);
      
      // Update in database - this will automatically trigger real-time updates
      await _supabase
          .from('life_points')
          .update({
            'life': newLifePoints,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('room_id', id)
          .eq('player_id', playerId);

      print('✅ Life points updated in real-time for player $playerId in room $roomId: $newLifePoints LP');

    } catch (e) {
      throw Exception('Failed to update life points: $e');
    }
  }

  /// Start real-time subscription for life points in a room
  Stream<List<LifePoint>> subscribeToLifePoints(String roomId) {
    final id = int.parse(roomId);
    
    // Return existing stream if already subscribed
    if (_lifePointControllers.containsKey(id)) {
      print('♻️  Returning existing real-time stream for room $roomId');
      return _lifePointControllers[id]!.stream;
    }

    print('🚀 Starting real-time subscription for room $roomId');

    // Create new stream controller
    final controller = StreamController<List<LifePoint>>.broadcast(
      onCancel: () {
        print('🛑 Real-time subscription cancelled for room $roomId');
      },
    );
    _lifePointControllers[id] = controller;

    // Setup real-time subscription
    final channel = _supabase
        .channel('life_points_$id')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'life_points',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'room_id',
            value: id, // Use integer value for filter
          ),
          callback: (payload) {
            print('📡 Real-time update received for room $roomId: ${payload.eventType}');
            print('📡 Payload: ${payload.toString()}');
            _handleLifePointChange(roomId);
          },
        )
        .subscribe((status, [error]) {
          if (status == 'SUBSCRIBED') {
            print('✅ Successfully subscribed to real-time updates for room $roomId');
          } else if (status == 'CHANNEL_ERROR') {
            print('❌ Real-time subscription error for room $roomId: $error');
            controller.addError('Real-time subscription failed: $error');
          }
        });

    _subscriptions[id] = channel;

    // Load initial data
    _loadInitialLifePoints(roomId);

    return controller.stream;
  }

  /// Handle real-time life point changes
  Future<void> _handleLifePointChange(String roomId) async {
    try {
      final lifePoints = await getLifePoints(roomId);
      final id = int.parse(roomId);
      
      if (_lifePointControllers.containsKey(id)) {
        print('📊 Broadcasting life points update to subscribers: ${lifePoints.length} records');
        _lifePointControllers[id]!.add(lifePoints);
      }
    } catch (e) {
      final id = int.parse(roomId);
      if (_lifePointControllers.containsKey(id)) {
        print('❌ Error handling life point change: $e');
        _lifePointControllers[id]!.addError('Failed to load life points: $e');
      }
    }
  }

  /// Load initial life points data
  Future<void> _loadInitialLifePoints(String roomId) async {
    try {
      print('🔍 Loading initial life points for room $roomId...');
      final lifePoints = await getLifePoints(roomId);
      final id = int.parse(roomId);
      
      print('📋 Found ${lifePoints.length} life points for room $roomId:');
      for (var lp in lifePoints) {
        print('   Player ${lp.playerId}: ${lp.life} LP');
      }
      
      if (_lifePointControllers.containsKey(id)) {
        print('📤 Broadcasting initial life points to stream subscribers');
        _lifePointControllers[id]!.add(lifePoints);
      } else {
        print('⚠️  No stream controller found for room $roomId');
      }
    } catch (e) {
      final id = int.parse(roomId);
      print('❌ Error loading initial life points for room $roomId: $e');
      if (_lifePointControllers.containsKey(id)) {
        _lifePointControllers[id]!.addError('Failed to load initial life points: $e');
      }
    }
  }

  /// Stop real-time subscription for a room
  Future<void> stopRealTimeSubscription(String roomId) async {
    final id = int.parse(roomId);
    
    if (_subscriptions.containsKey(id)) {
      print('🛑 Stopping real-time subscription for room $roomId');
      await _supabase.removeChannel(_subscriptions[id]!);
      _subscriptions.remove(id);
    }

    if (_lifePointControllers.containsKey(id)) {
      await _lifePointControllers[id]!.close();
      _lifePointControllers.remove(id);
    }
  }

  /// Check if a player is in the room
  Future<bool> isPlayerInRoom(String roomId, String playerId) async {
    try {
      final room = await getDuelRoom(roomId);
      return room.player1Id == playerId || room.player2Id == playerId;
    } catch (e) {
      return false;
    }
  }

  /// Get active rooms for a player  
  Future<List<DuelRoom>> getActiveRoomsForPlayer(String playerId) async {
    try {
      final response = await _supabase
          .from('room')
          .select()
          .eq('is_active', true)
          .or('player1_id.eq.$playerId,player2_id.eq.$playerId');

      return response.map<DuelRoom>((json) => DuelRoom.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to get active rooms: $e');
    }
  }

  /// Cleanup all subscriptions (call this when disposing the service)
  Future<void> dispose() async {
    print('🧹 Cleaning up all real-time subscriptions...');
    final roomIds = List<int>.from(_subscriptions.keys);
    
    for (final roomId in roomIds) {
      await stopRealTimeSubscription(roomId.toString());
    }
    
    print('✅ All real-time subscriptions cleaned up');
  }
}