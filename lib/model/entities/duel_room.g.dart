// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'duel_room.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DuelRoom _$DuelRoomFromJson(Map<String, dynamic> json) => DuelRoom(
      roomId: (json['id'] as num).toInt(),
      player1Id: json['player1_id'] as String,
      player2Id: json['player2_id'] as String,
      isActive: json['is_active'] as bool? ?? true,
      createdAt: DateTime.parse(json['created_at'] as String),
    );

Map<String, dynamic> _$DuelRoomToJson(DuelRoom instance) => <String, dynamic>{
      'id': instance.roomId,
      'player1_id': instance.player1Id,
      'player2_id': instance.player2Id,
      'is_active': instance.isActive,
      'created_at': instance.createdAt.toIso8601String(),
    };
