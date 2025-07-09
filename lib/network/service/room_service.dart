import 'package:topdeck_app_flutter/model/entities/duel_room.dart';
import 'package:topdeck_app_flutter/model/entities/life_point.dart';

abstract class RoomService {

  Future<DuelRoom> createDuelRoom(String player1Id, String player2Id);

  Future<DuelRoom> getDuelRoom(String id);

  Future<DuelRoom> getDuelRoomByMatchId(String matchId);

  Future<DuelRoom> updateDuelRoom(DuelRoom duelRoom);

  Future<void> deleteDuelRoom(String id);

  // Life Points management
  Future<List<LifePoint>> getLifePoints(String roomId);
  
  Future<void> updateLifePoints(String roomId, String playerId, int newLifePoints);

  // Real-time subscription
  Stream<List<LifePoint>> subscribeToLifePoints(String roomId);
  
  Future<void> stopRealTimeSubscription(String roomId);

  // Utility methods
  Future<bool> isPlayerInRoom(String roomId, String playerId);
  
  Future<List<DuelRoom>> getActiveRoomsForPlayer(String playerId);
  
  Future<void> dispose();
}