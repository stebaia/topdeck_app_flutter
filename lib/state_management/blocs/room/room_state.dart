import 'package:equatable/equatable.dart';
import 'package:topdeck_app_flutter/model/entities/duel_room.dart';
import 'package:topdeck_app_flutter/model/entities/life_point.dart';

/// Base state class for room management
abstract class RoomState extends Equatable {
  @override
  List<Object?> get props => [];
}

/// Initial state
class RoomInitialState extends RoomState {}

/// Loading state
class RoomLoadingState extends RoomState {}

/// State when duel room is loaded
class DuelRoomLoadedState extends RoomState {
  final DuelRoom duelRoom;

  DuelRoomLoadedState(this.duelRoom);

  @override
  List<Object?> get props => [duelRoom];
}

/// State when duel room is created
class DuelRoomCreatedState extends RoomState {
  final DuelRoom duelRoom;

  DuelRoomCreatedState(this.duelRoom);

  @override
  List<Object?> get props => [duelRoom];
}

/// State when duel room is updated
class DuelRoomUpdatedState extends RoomState {
  final DuelRoom duelRoom;

  DuelRoomUpdatedState(this.duelRoom);

  @override
  List<Object?> get props => [duelRoom];
}

/// State when subscribed to life points stream
class LifePointsStreamActiveState extends RoomState {
  final String roomId;
  final List<LifePoint> lifePoints;

  LifePointsStreamActiveState({
    required this.roomId,
    required this.lifePoints,
  });

  @override
  List<Object?> get props => [roomId, lifePoints];
}

/// State when life points are updated via stream
class LifePointsUpdatedState extends RoomState {
  final String roomId;
  final List<LifePoint> lifePoints;

  LifePointsUpdatedState({
    required this.roomId,
    required this.lifePoints,
  });

  @override
  List<Object?> get props => [roomId, lifePoints];
}

/// Error state
class RoomErrorState extends RoomState {
  final String message;

  RoomErrorState(this.message);

  @override
  List<Object?> get props => [message];
} 