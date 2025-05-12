// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'match.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Match _$MatchFromJson(Map<String, dynamic> json) => Match(
      id: json['id'] as String,
      player1Id: json['player1_id'] as String?,
      player2Id: json['player2_id'] as String?,
      winnerId: json['winner_id'] as String?,
      format: json['format'] as String,
      player1DeckId: json['player1_deck_id'] as String?,
      player2DeckId: json['player2_deck_id'] as String?,
      date:
          json['date'] == null ? null : DateTime.parse(json['date'] as String),
    );

Map<String, dynamic> _$MatchToJson(Match instance) => <String, dynamic>{
      'id': instance.id,
      'player1_id': instance.player1Id,
      'player2_id': instance.player2Id,
      'winner_id': instance.winnerId,
      'format': instance.format,
      'player1_deck_id': instance.player1DeckId,
      'player2_deck_id': instance.player2DeckId,
      'date': instance.date?.toIso8601String(),
    };
