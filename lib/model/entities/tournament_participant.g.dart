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
      deckId: json['deck_id'] as String?,
      points: (json['points'] as num?)?.toInt(),
      matchWins: (json['match_wins'] as num?)?.toInt() ?? 0,
      matchLosses: (json['match_losses'] as num?)?.toInt() ?? 0,
      matchDraws: (json['match_draws'] as num?)?.toInt() ?? 0,
      gameWins: (json['game_wins'] as num?)?.toInt() ?? 0,
      gameLosses: (json['game_losses'] as num?)?.toInt() ?? 0,
      opponentsFaced: (json['opponents_faced'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      isDropped: json['is_dropped'] as bool? ?? false,
      droppedRound: (json['dropped_round'] as num?)?.toInt(),
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
      'deck_id': instance.deckId,
      'points': instance.points,
      'match_wins': instance.matchWins,
      'match_losses': instance.matchLosses,
      'match_draws': instance.matchDraws,
      'game_wins': instance.gameWins,
      'game_losses': instance.gameLosses,
      'opponents_faced': instance.opponentsFaced,
      'is_dropped': instance.isDropped,
      'dropped_round': instance.droppedRound,
      'joined_at': instance.joinedAt?.toIso8601String(),
    };
