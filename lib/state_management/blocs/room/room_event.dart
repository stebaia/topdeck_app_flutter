import 'package:equatable/equatable.dart';
import 'package:topdeck_app_flutter/model/entities/duel_room.dart';

/// Base class for all room events
abstract class RoomEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

/// Event to load a duel room
class LoadDuelRoomEvent extends RoomEvent {
  final String roomId;

  LoadDuelRoomEvent(this.roomId);

  @override
  List<Object?> get props => [roomId];
}

/// Event to load a duel room by match ID
class LoadDuelRoomByMatchEvent extends RoomEvent {
  final String matchId;

  LoadDuelRoomByMatchEvent(this.matchId);

  @override
  List<Object?> get props => [matchId];
}

/// Event to create a new duel room
class CreateDuelRoomEvent extends RoomEvent {
  final String player1Id;
  final String player2Id;

  CreateDuelRoomEvent({
    required this.player1Id,
    required this.player2Id,
  });

  @override
  List<Object?> get props => [player1Id, player2Id];
}

/// Event to update duel room
class UpdateDuelRoomEvent extends RoomEvent {
  final DuelRoom duelRoom;

  UpdateDuelRoomEvent(this.duelRoom);

  @override
  List<Object?> get props => [duelRoom];
}

/// Event to subscribe to life points updates
class SubscribeToLifePointsEvent extends RoomEvent {
  final String roomId;

  SubscribeToLifePointsEvent(this.roomId);

  @override
  List<Object?> get props => [roomId];
}

/// Event when life points are updated via stream
class LifePointsUpdatedEvent extends RoomEvent {
  final List<dynamic> lifePoints; // Cambiato da List<LifePoint> per gestire i dati JSON

  LifePointsUpdatedEvent(this.lifePoints);

  @override
  List<Object?> get props => [lifePoints];
}

/// Event to unsubscribe from life points updates
class UnsubscribeFromLifePointsEvent extends RoomEvent {
  final String roomId;

  UnsubscribeFromLifePointsEvent(this.roomId);

  @override
  List<Object?> get props => [roomId];
}

/// Event to update life points for a specific player
class UpdateLifePointsEvent extends RoomEvent {
  final String roomId;
  final String playerId;
  final int newLifePoints;

  UpdateLifePointsEvent(this.roomId, this.playerId, this.newLifePoints);

  @override
  List<Object?> get props => [roomId, playerId, newLifePoints];
}

/// Event to reset room state
class ResetRoomEvent extends RoomEvent {} 