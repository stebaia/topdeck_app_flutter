import 'package:json_annotation/json_annotation.dart';
import 'package:uuid/uuid.dart';
import '../base_model.dart';

part 'deck_card.g.dart';

/// DeckCard model representing a card in a deck in the Supabase deck_cards table
@JsonSerializable()
class DeckCard extends BaseModel {
  /// The deck ID this card belongs to
  @JsonKey(name: 'deck_id')
  final String deckId;
  
  /// The name of the card
  @JsonKey(name: 'card_name')
  final String cardName;
  
  /// The quantity of this card in the deck
  final int? quantity;

  /// Constructor
  const DeckCard({
    required super.id,
    required this.deckId,
    required this.cardName,
    this.quantity = 1,
  });

  /// Creates a new DeckCard instance with a generated UUID
  factory DeckCard.create({
    required String deckId,
    required String cardName,
    int quantity = 1,
  }) {
    return DeckCard(
      id: const Uuid().v4(),
      deckId: deckId,
      cardName: cardName,
      quantity: quantity,
    );
  }

  /// Creates a deck card from JSON
  factory DeckCard.fromJson(Map<String, dynamic> json) => _$DeckCardFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$DeckCardToJson(this);

  @override
  DeckCard copyWith({
    String? id,
    String? deckId,
    String? cardName,
    int? quantity,
  }) {
    return DeckCard(
      id: id ?? this.id,
      deckId: deckId ?? this.deckId,
      cardName: cardName ?? this.cardName,
      quantity: quantity ?? this.quantity,
    );
  }
} 