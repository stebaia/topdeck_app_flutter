import 'package:json_annotation/json_annotation.dart';
import 'package:uuid/uuid.dart';
import '../base_model.dart';

part 'deck.g.dart';

/// Formats supported for decks
enum DeckFormat {
  @JsonValue('advanced')
  advanced,
  @JsonValue('goat')
  goat,
  @JsonValue('edison')
  edison,
  @JsonValue('hat')
  hat,
  @JsonValue('custom')
  custom
}

/// Deck model representing a deck in the Supabase decks table
@JsonSerializable()
class Deck extends BaseModel {
  /// The user ID who owns this deck
  @JsonKey(name: 'user_id')
  final String userId;
  
  /// The name of the deck
  final String name;
  
  /// The format of the deck
  final DeckFormat format;
  
  /// Whether the deck is shared publicly
  final bool? shared;
  
  /// Creation timestamp
  @JsonKey(name: 'created_at')
  final DateTime? createdAt;

  /// Constructor
  const Deck({
    required super.id,
    required this.userId,
    required this.name,
    required this.format,
    this.shared = false,
    this.createdAt,
  });

  /// Creates a new Deck instance with a generated UUID
  factory Deck.create({
    required String userId,
    required String name,
    required DeckFormat format,
    bool shared = false,
  }) {
    return Deck(
      id: const Uuid().v4(),
      userId: userId,
      name: name,
      format: format,
      shared: shared,
      createdAt: DateTime.now(),
    );
  }

  /// Creates a deck from JSON
  factory Deck.fromJson(Map<String, dynamic> json) => _$DeckFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$DeckToJson(this);

  @override
  Deck copyWith({
    String? id,
    String? userId,
    String? name,
    DeckFormat? format,
    bool? shared,
    DateTime? createdAt,
  }) {
    return Deck(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      format: format ?? this.format,
      shared: shared ?? this.shared,
      createdAt: createdAt ?? this.createdAt,
    );
  }
} 