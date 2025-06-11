// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'match_extended.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MatchExtended _$MatchExtendedFromJson(Map<String, dynamic> json) =>
    MatchExtended(
      id: json['id'] as String,
      player1Id: json['player1_id'] as String,
      player2Id: json['player2_id'] as String?,
      winnerId: json['winner_id'] as String?,
      format: json['format'] as String,
      date:
          json['date'] == null ? null : DateTime.parse(json['date'] as String),
      tournamentId: json['tournament_id'] as String?,
      isFriendly: json['is_friendly'] as bool? ?? false,
      isBye: json['is_bye'] as bool? ?? false,
      player1EloBefore: (json['player1_elo_before'] as num?)?.toInt(),
      player2EloBefore: (json['player2_elo_before'] as num?)?.toInt(),
      player1EloAfter: (json['player1_elo_after'] as num?)?.toInt(),
      player2EloAfter: (json['player2_elo_after'] as num?)?.toInt(),
      player1EloChange: (json['player1_elo_change'] as num?)?.toInt(),
      player2EloChange: (json['player2_elo_change'] as num?)?.toInt(),
      round: (json['round'] as num?)?.toInt(),
      player1DeckId: json['player1_deck_id'] as String?,
      player2DeckId: json['player2_deck_id'] as String?,
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
    );

Map<String, dynamic> _$MatchExtendedToJson(MatchExtended instance) =>
    <String, dynamic>{
      'id': instance.id,
      'player1_id': instance.player1Id,
      'player2_id': instance.player2Id,
      'winner_id': instance.winnerId,
      'format': instance.format,
      'date': instance.date?.toIso8601String(),
      'tournament_id': instance.tournamentId,
      'is_friendly': instance.isFriendly,
      'is_bye': instance.isBye,
      'player1_elo_before': instance.player1EloBefore,
      'player2_elo_before': instance.player2EloBefore,
      'player1_elo_after': instance.player1EloAfter,
      'player2_elo_after': instance.player2EloAfter,
      'player1_elo_change': instance.player1EloChange,
      'player2_elo_change': instance.player2EloChange,
      'round': instance.round,
      'player1_deck_id': instance.player1DeckId,
      'player2_deck_id': instance.player2DeckId,
      'created_at': instance.createdAt?.toIso8601String(),
    };
