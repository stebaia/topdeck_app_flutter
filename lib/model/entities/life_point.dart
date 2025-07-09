import 'package:json_annotation/json_annotation.dart';

part 'life_point.g.dart';

@JsonSerializable()
class LifePoint {
  
  @JsonKey(name: 'id')
  final int? id;
  @JsonKey(name: 'life')
  final int life;
  @JsonKey(name: 'room_id')
  final int roomId;
  @JsonKey(name: 'player_id')
  final String playerId;
  @JsonKey(name: 'created_at')
  final DateTime? createdAt;
  @JsonKey(name: 'updated_at')
  final DateTime? updatedAt;

  LifePoint({
    this.id,
    required this.life, 
    required this.roomId, 
    required this.playerId,
    this.createdAt,
    this.updatedAt,
  });

  factory LifePoint.fromJson(Map<String, dynamic> json) => _$LifePointFromJson(json);
  @override
  Map<String, dynamic> toJson() => _$LifePointToJson(this);

  LifePoint copyWith({
    int? id,
    int? life,
    int? roomId,
    String? playerId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => LifePoint(
    id: id ?? this.id,
    life: life ?? this.life, 
    roomId: roomId ?? this.roomId, 
    playerId: playerId ?? this.playerId,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );

  @override
  String toString() {
    return 'LifePoint(id: $id, life: $life, roomId: $roomId, playerId: $playerId, createdAt: $createdAt, updatedAt: $updatedAt)';
  }
}