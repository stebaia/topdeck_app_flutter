// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_elo.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserElo _$UserEloFromJson(Map<String, dynamic> json) => UserElo(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      format: json['format'] as String,
      elo: (json['elo'] as num).toInt(),
      matchesPlayed: (json['matches_played'] as num).toInt(),
      wins: (json['wins'] as num).toInt(),
      losses: (json['losses'] as num).toInt(),
      draws: (json['draws'] as num).toInt(),
      winRate: (json['win_rate'] as num).toDouble(),
      peakElo: (json['peak_elo'] as num).toInt(),
      lastMatchDate: json['last_match_date'] == null
          ? null
          : DateTime.parse(json['last_match_date'] as String),
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] == null
          ? null
          : DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$UserEloToJson(UserElo instance) => <String, dynamic>{
      'id': instance.id,
      'user_id': instance.userId,
      'format': instance.format,
      'elo': instance.elo,
      'matches_played': instance.matchesPlayed,
      'wins': instance.wins,
      'losses': instance.losses,
      'draws': instance.draws,
      'win_rate': instance.winRate,
      'peak_elo': instance.peakElo,
      'last_match_date': instance.lastMatchDate?.toIso8601String(),
      'created_at': instance.createdAt?.toIso8601String(),
      'updated_at': instance.updatedAt?.toIso8601String(),
    };
