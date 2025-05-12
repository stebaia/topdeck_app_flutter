import 'package:json_annotation/json_annotation.dart';
import 'package:uuid/uuid.dart';
import '../base_model.dart';

part 'profile.g.dart';

/// Profile model representing a user profile in the Supabase profiles table
@JsonSerializable()
class Profile extends BaseModel {
  /// Username of the user
  final String username;
  
  /// First name of the user
  final String nome;
  
  /// Last name of the user
  final String cognome;
  
  /// Birth date of the user
  @JsonKey(name: 'data_di_nascita')
  final DateTime dataDiNascita;
  
  /// City of the user
  @JsonKey(name: 'città')
  final String citta;
  
  /// Province of the user
  final String provincia;
  
  /// Country of the user
  final String stato;
  
  /// Avatar URL of the user
  @JsonKey(name: 'avatar_url')
  final String? avatarUrl;
  
  /// Creation timestamp
  @JsonKey(name: 'created_at')
  final DateTime? createdAt;

  /// Constructor
  const Profile({
    required super.id,
    required this.username,
    required this.nome,
    required this.cognome,
    required this.dataDiNascita,
    required this.citta,
    required this.provincia,
    required this.stato,
    this.avatarUrl,
    this.createdAt,
  });

  /// Creates a new Profile instance with a generated UUID
  factory Profile.create({
    required String username,
    required String nome,
    required String cognome,
    required DateTime dataDiNascita,
    required String citta,
    required String provincia,
    required String stato,
    String? avatarUrl,
  }) {
    return Profile(
      id: const Uuid().v4(),
      username: username,
      nome: nome,
      cognome: cognome,
      dataDiNascita: dataDiNascita,
      citta: citta,
      provincia: provincia,
      stato: stato,
      avatarUrl: avatarUrl,
      createdAt: DateTime.now(),
    );
  }

  /// Creates a profile from JSON
  factory Profile.fromJson(Map<String, dynamic> json) => _$ProfileFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$ProfileToJson(this);

  @override
  Profile copyWith({
    String? id,
    String? username,
    String? nome,
    String? cognome,
    DateTime? dataDiNascita,
    String? citta,
    String? provincia,
    String? stato,
    String? avatarUrl,
    DateTime? createdAt,
  }) {
    return Profile(
      id: id ?? this.id,
      username: username ?? this.username,
      nome: nome ?? this.nome,
      cognome: cognome ?? this.cognome,
      dataDiNascita: dataDiNascita ?? this.dataDiNascita,
      citta: citta ?? this.citta,
      provincia: provincia ?? this.provincia,
      stato: stato ?? this.stato,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      createdAt: createdAt ?? this.createdAt,
    );
  }
} 