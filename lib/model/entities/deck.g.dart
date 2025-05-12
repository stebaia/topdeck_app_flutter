// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'deck.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Deck _$DeckFromJson(Map<String, dynamic> json) => Deck(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      name: json['name'] as String,
      format: $enumDecode(_$DeckFormatEnumMap, json['format']),
      shared: json['shared'] as bool? ?? false,
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
    );

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
