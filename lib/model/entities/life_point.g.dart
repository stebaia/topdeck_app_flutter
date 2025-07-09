// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'life_point.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LifePoint _$LifePointFromJson(Map<String, dynamic> json) => LifePoint(
      id: (json['id'] as num?)?.toInt(),
      life: (json['life'] as num).toInt(),
      roomId: (json['room_id'] as num).toInt(),
      playerId: json['player_id'] as String,
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] == null
          ? null
          : DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$LifePointToJson(LifePoint instance) => <String, dynamic>{
      'id': instance.id,
      'life': instance.life,
      'room_id': instance.roomId,
      'player_id': instance.playerId,
      'created_at': instance.createdAt?.toIso8601String(),
      'updated_at': instance.updatedAt?.toIso8601String(),
    };
