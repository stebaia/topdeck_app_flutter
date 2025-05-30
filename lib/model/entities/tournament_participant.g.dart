// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tournament_participant.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TournamentParticipant _$TournamentParticipantFromJson(
        Map<String, dynamic> json) =>
    TournamentParticipant(
      id: json['id'] as String,
      tournamentId: json['tournament_id'] as String,
      userId: json['user_id'] as String,
      joinedAt: json['joined_at'] == null
          ? null
          : DateTime.parse(json['joined_at'] as String),
    );

Map<String, dynamic> _$TournamentParticipantToJson(
        TournamentParticipant instance) =>
    <String, dynamic>{
      'id': instance.id,
      'tournament_id': instance.tournamentId,
      'user_id': instance.userId,
      'joined_at': instance.joinedAt?.toIso8601String(),
    };
