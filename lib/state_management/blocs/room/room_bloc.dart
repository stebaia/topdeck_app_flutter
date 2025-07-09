import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:topdeck_app_flutter/model/entities/life_point.dart';
import 'package:topdeck_app_flutter/repositories/room_repository.dart';
import 'package:topdeck_app_flutter/state_management/blocs/room/room_event.dart';
import 'package:topdeck_app_flutter/state_management/blocs/room/room_state.dart';

/// BLoC for managing room operations and real-time updates
class RoomBloc extends Bloc<RoomEvent, RoomState> {
  final RoomRepository _roomRepository;
  StreamSubscription<List<LifePoint>>? _lifePointsSubscription;

  /// Constructor
  RoomBloc({
    required RoomRepository roomRepository,
  }) : _roomRepository = roomRepository,
       super(RoomInitialState()) {
    on<LoadDuelRoomEvent>(_onLoadDuelRoom);
    on<LoadDuelRoomByMatchEvent>(_onLoadDuelRoomByMatch);
    on<CreateDuelRoomEvent>(_onCreateDuelRoom);
    on<UpdateDuelRoomEvent>(_onUpdateDuelRoom);
    on<SubscribeToLifePointsEvent>(_onSubscribeToLifePoints);
    on<LifePointsUpdatedEvent>(_onLifePointsUpdated);
    on<UpdateLifePointsEvent>(_onUpdateLifePoints);
    on<UnsubscribeFromLifePointsEvent>(_onUnsubscribeFromLifePoints);
    on<ResetRoomEvent>(_onReset);
  }

  Future<void> _onLoadDuelRoom(
    LoadDuelRoomEvent event,
    Emitter<RoomState> emit,
  ) async {
    emit(RoomLoadingState());

    try {
      final duelRoom = await _roomRepository.getDuelRoom(event.roomId);
      emit(DuelRoomLoadedState(duelRoom));
    } catch (e) {
      emit(RoomErrorState('Failed to load duel room: $e'));
    }
  }

  Future<void> _onLoadDuelRoomByMatch(
    LoadDuelRoomByMatchEvent event,
    Emitter<RoomState> emit,
  ) async {
    emit(RoomLoadingState());

    try {
      final duelRoom = await _roomRepository.getDuelRoomByMatchId(event.matchId);
      emit(DuelRoomLoadedState(duelRoom));
    } catch (e) {
      emit(RoomErrorState('Failed to load duel room by match: $e'));
    }
  }

  Future<void> _onCreateDuelRoom(
    CreateDuelRoomEvent event,
    Emitter<RoomState> emit,
  ) async {
    emit(RoomLoadingState());

    try {
      final duelRoom = await _roomRepository.createDuelRoom(
        event.player1Id,
        event.player2Id,
      );
      emit(DuelRoomCreatedState(duelRoom));
    } catch (e) {
      emit(RoomErrorState('Failed to create duel room: $e'));
    }
  }

  Future<void> _onUpdateDuelRoom(
    UpdateDuelRoomEvent event,
    Emitter<RoomState> emit,
  ) async {
    emit(RoomLoadingState());

    try {
      final updatedRoom = await _roomRepository.updateDuelRoom(event.duelRoom);
      emit(DuelRoomUpdatedState(updatedRoom));
    } catch (e) {
      emit(RoomErrorState('Failed to update duel room: $e'));
    }
  }

  Future<void> _onSubscribeToLifePoints(
    SubscribeToLifePointsEvent event,
    Emitter<RoomState> emit,
  ) async {
    try {
      // Cancel existing subscription if any
      await _lifePointsSubscription?.cancel();

      // Subscribe to life points stream
      _lifePointsSubscription = _roomRepository
          .subscribeToLifePoints(event.roomId)
          .listen(
        (lifePoints) {
          print('🔄 DEBUG: Real-time stream received ${lifePoints.length} life points for room ${event.roomId}');
          for (var lp in lifePoints) {
            print('   Player ${lp.playerId}: ${lp.life} LP');
          }
          // Emit the stream data as an event to be handled by the bloc
          add(LifePointsUpdatedEvent(lifePoints.map((lp) => lp.toJson()).toList()));
        },
        onError: (error) {
          print('❌ DEBUG: Real-time stream error: $error');
          emit(RoomErrorState('Life points stream error: $error'));
        },
      );

      emit(LifePointsStreamActiveState(
        roomId: event.roomId,
        lifePoints: [],
      ));
    } catch (e) {
      emit(RoomErrorState('Failed to subscribe to life points: $e'));
    }
  }

  void _onLifePointsUpdated(
    LifePointsUpdatedEvent event,
    Emitter<RoomState> emit,
  ) {
    try {
      print('📊 DEBUG: Processing LifePointsUpdatedEvent with ${event.lifePoints.length} records');
      
      // Convert JSON data back to LifePoint objects
      final lifePoints = event.lifePoints
          .map((lpJson) => LifePoint.fromJson(lpJson as Map<String, dynamic>))
          .toList();

      // Determine room ID from the life points
      final roomId = lifePoints.isNotEmpty 
          ? lifePoints.first.roomId.toString() 
          : '';

      print('🎯 DEBUG: Emitting LifePointsUpdatedState for room $roomId');
      for (var lp in lifePoints) {
        print('   Player ${lp.playerId}: ${lp.life} LP');
      }

      emit(LifePointsUpdatedState(
        roomId: roomId,
        lifePoints: lifePoints,
      ));
    } catch (e) {
      print('❌ DEBUG: Error processing life points update: $e');
      emit(RoomErrorState('Failed to process life points update: $e'));
    }
  }

  Future<void> _onUpdateLifePoints(
    UpdateLifePointsEvent event,
    Emitter<RoomState> emit,
  ) async {
    try {
      print('🔥 DEBUG: RoomBloc received UpdateLifePointsEvent - Room: ${event.roomId}, Player: ${event.playerId}, LP: ${event.newLifePoints}');
      
      await _roomRepository.updateLifePoints(
        event.roomId,
        event.playerId,
        event.newLifePoints,
      );
      
      print('✅ DEBUG: Life points updated successfully in repository');
      // Note: L'aggiornamento dovrebbe arrivare tramite il real-time stream
      
    } catch (e) {
      print('❌ DEBUG: Error updating life points: $e');
      emit(RoomErrorState('Failed to update life points: $e'));
    }
  }

  Future<void> _onUnsubscribeFromLifePoints(
    UnsubscribeFromLifePointsEvent event,
    Emitter<RoomState> emit,
  ) async {
    try {
      await _lifePointsSubscription?.cancel();
      _lifePointsSubscription = null;
      
      emit(RoomInitialState());
    } catch (e) {
      emit(RoomErrorState('Failed to unsubscribe from life points: $e'));
    }
  }

  void _onReset(
    ResetRoomEvent event,
    Emitter<RoomState> emit,
  ) {
    _lifePointsSubscription?.cancel();
    _lifePointsSubscription = null;
    emit(RoomInitialState());
  }

  @override
  Future<void> close() async {
    await _lifePointsSubscription?.cancel();
    return super.close();
  }
} 