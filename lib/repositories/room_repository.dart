import 'package:topdeck_app_flutter/model/entities/duel_room.dart';
import 'package:topdeck_app_flutter/model/entities/life_point.dart';
import 'package:topdeck_app_flutter/network/service/room_service.dart';

class RoomRepository {
  final RoomService _roomService;
  RoomRepository({required RoomService roomService}) : _roomService = roomService;

  Future<DuelRoom> getDuelRoom(String id) async {
    return await _roomService.getDuelRoom(id);
  }

  Future<DuelRoom> getDuelRoomByMatchId(String matchId) async {
    return await _roomService.getDuelRoomByMatchId(matchId);
  }

  Future<DuelRoom> createDuelRoom(String player1Id, String player2Id) async {
    return await _roomService.createDuelRoom(player1Id, player2Id);
  }

  Future<DuelRoom> updateDuelRoom(DuelRoom duelRoom) async {
    return await _roomService.updateDuelRoom(duelRoom);
  }

  Stream<List<LifePoint>> subscribeToLifePoints(String roomId) {
    return _roomService.subscribeToLifePoints(roomId);
  }

  Future<void> updateLifePoints(String roomId, String playerId, int newLifePoints) async {
    return await _roomService.updateLifePoints(roomId, playerId, newLifePoints);
  }

  Future<List<LifePoint>> getLifePoints(String roomId) async {
    return await _roomService.getLifePoints(roomId);
  }
}