// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'deck_card.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DeckCard _$DeckCardFromJson(Map<String, dynamic> json) => DeckCard(
      id: json['id'] as String,
      deckId: json['deck_id'] as String,
      cardName: json['card_name'] as String,
      quantity: (json['quantity'] as num?)?.toInt() ?? 1,
    );

Map<String, dynamic> _$DeckCardToJson(DeckCard instance) => <String, dynamic>{
      'id': instance.id,
      'deck_id': instance.deckId,
      'card_name': instance.cardName,
      'quantity': instance.quantity,
    };
