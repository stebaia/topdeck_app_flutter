// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tournament.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Tournament _$TournamentFromJson(Map<String, dynamic> json) => Tournament(
      id: json['id'] as String,
      name: json['name'] as String,
      format: json['format'] as String,
      league: json['league'] as String?,
      createdBy: json['created_by'] as String?,
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
      status: $enumDecodeNullable(_$TournamentStatusEnumMap, json['status']) ??
          TournamentStatus.upcoming,
      isPublic: json['is_public'] as bool? ?? true,
      maxParticipants: (json['max_participants'] as num?)?.toInt(),
      inviteCode: json['invite_code'] as String?,
    );

Map<String, dynamic> _$TournamentToJson(Tournament instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'format': instance.format,
      'league': instance.league,
      'created_by': instance.createdBy,
      'created_at': instance.createdAt?.toIso8601String(),
      'status': _$TournamentStatusEnumMap[instance.status]!,
      'is_public': instance.isPublic,
      'max_participants': instance.maxParticipants,
      'invite_code': instance.inviteCode,
    };

const _$TournamentStatusEnumMap = {
  TournamentStatus.upcoming: 'upcoming',
  TournamentStatus.ongoing: 'ongoing',
  TournamentStatus.completed: 'completed',
};
