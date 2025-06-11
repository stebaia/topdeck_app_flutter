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
      startDate: json['start_date'] == null
          ? null
          : DateTime.parse(json['start_date'] as String),
      startTime: json['start_time'] as String?,
      description: json['description'] as String?,
      currentRound: (json['current_round'] as num?)?.toInt() ?? 0,
      totalRounds: (json['total_rounds'] as num?)?.toInt(),
      roundTimerEnd: json['round_timer_end'] == null
          ? null
          : DateTime.parse(json['round_timer_end'] as String),
      roundTimeMinutes: (json['round_time_minutes'] as num?)?.toInt() ?? 50,
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
      'start_date': instance.startDate?.toIso8601String(),
      'start_time': instance.startTime,
      'description': instance.description,
      'current_round': instance.currentRound,
      'total_rounds': instance.totalRounds,
      'round_timer_end': instance.roundTimerEnd?.toIso8601String(),
      'round_time_minutes': instance.roundTimeMinutes,
    };

const _$TournamentStatusEnumMap = {
  TournamentStatus.upcoming: 'upcoming',
  TournamentStatus.ongoing: 'ongoing',
  TournamentStatus.completed: 'completed',
};
