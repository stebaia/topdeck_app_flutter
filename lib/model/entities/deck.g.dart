// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'deck.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Map<String, dynamic> _$DeckToJson(Deck instance) => <String, dynamic>{
      'id': instance.id,
      'user_id': instance.userId,
      'name': instance.name,
      'format': _$DeckFormatEnumMap[instance.format]!,
      'shared': instance.shared,
      'created_at': instance.createdAt?.toIso8601String(),
    };

const _$DeckFormatEnumMap = {
  DeckFormat.advanced: 'advanced',
  DeckFormat.goat: 'goat',
  DeckFormat.edison: 'edison',
  DeckFormat.hat: 'hat',
  DeckFormat.custom: 'custom',
};
