// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tournament_match.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TournamentMatch _$TournamentMatchFromJson(Map<String, dynamic> json) =>
    TournamentMatch(
      id: json['id'] as String,
      tournamentId: json['tournament_id'] as String,
      player1Id: json['player1_id'] as String?,
      player2Id: json['player2_id'] as String?,
      winnerId: json['winner_id'] as String?,
      round: (json['round'] as num).toInt(),
      date:
          json['date'] == null ? null : DateTime.parse(json['date'] as String),
      matchStatus:
          $enumDecodeNullable(_$MatchStatusEnumMap, json['match_status']) ??
              MatchStatus.pending,
      resultScore: json['result_score'] as String?,
      tableNumber: (json['table_number'] as num?)?.toInt(),
      isBye: json['is_bye'] as bool? ?? false,
      startedAt: json['started_at'] == null
          ? null
          : DateTime.parse(json['started_at'] as String),
      finishedAt: json['finished_at'] == null
          ? null
          : DateTime.parse(json['finished_at'] as String),
    );

Map<String, dynamic> _$TournamentMatchToJson(TournamentMatch instance) =>
    <String, dynamic>{
      'id': instance.id,
      'tournament_id': instance.tournamentId,
      'player1_id': instance.player1Id,
      'player2_id': instance.player2Id,
      'winner_id': instance.winnerId,
      'round': instance.round,
      'date': instance.date?.toIso8601String(),
      'match_status': _$MatchStatusEnumMap[instance.matchStatus]!,
      'result_score': instance.resultScore,
      'table_number': instance.tableNumber,
      'is_bye': instance.isBye,
      'started_at': instance.startedAt?.toIso8601String(),
      'finished_at': instance.finishedAt?.toIso8601String(),
    };

const _$MatchStatusEnumMap = {
  MatchStatus.pending: 'pending',
  MatchStatus.inProgress: 'in_progress',
  MatchStatus.finished: 'finished',
  MatchStatus.disputed: 'disputed',
};
