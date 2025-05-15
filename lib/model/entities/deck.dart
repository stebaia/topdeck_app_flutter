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
@JsonSerializable(createFactory: false)
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

  /// Creates a deck from JSON with null safety
  factory Deck.fromJson(Map<String, dynamic> json) {
    // Gestisci format=null o formati non validi usando advanced come predefinito
    DeckFormat format;
    try {
      if (json['format'] == null) {
        format = DeckFormat.advanced;
        print('Warning: format is null in deck, using default: advanced');
      } else {
        format = $enumDecode(_$DeckFormatEnumMap, json['format']);
      }
    } catch (e) {
      format = DeckFormat.advanced;
      print('Error decoding format: ${json['format']}, using default: advanced');
    }
    
    // Assicurati che l'ID non sia mai null
    String id = json['id'] as String? ?? const Uuid().v4();
    
    return Deck(
      id: id,
      userId: json['user_id'] as String? ?? '',
      name: json['name'] as String? ?? 'Unnamed Deck',
      format: format,
      shared: json['shared'] as bool? ?? false,
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
    );
  }

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