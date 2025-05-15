import 'package:json_annotation/json_annotation.dart';
import 'package:uuid/uuid.dart';
import '../base_model.dart';
import '../user.dart';

part 'friend_request.g.dart';

/// Status delle richieste di amicizia
enum FriendRequestStatus {
  @JsonValue('pending')
  pending,
  @JsonValue('accepted')
  accepted,
  @JsonValue('declined')
  declined
}

/// Modello per le richieste di amicizia
@JsonSerializable()
class FriendRequest extends BaseModel {
  /// ID dell'utente che invia la richiesta
  @JsonKey(name: 'sender_id')
  final String senderId;
  
  /// ID dell'utente che riceve la richiesta
  @JsonKey(name: 'recipient_id')
  final String recipientId;
  
  /// Stato della richiesta
  final FriendRequestStatus status;
  
  /// Data di creazione
  @JsonKey(name: 'created_at')
  final DateTime? createdAt;
  
  /// Info sull'utente mittente (opzionale, per UI)
  @JsonKey(includeIfNull: false, ignore: true)
  final UserProfile? sender;
  
  /// Info sull'utente destinatario (opzionale, per UI)
  @JsonKey(includeIfNull: false, ignore: true)
  final UserProfile? recipient;

  /// Costruttore
  const FriendRequest({
    required super.id,
    required this.senderId,
    required this.recipientId,
    required this.status,
    this.createdAt,
    this.sender,
    this.recipient,
  });

  /// Crea una nuova richiesta di amicizia con ID generato
  factory FriendRequest.create({
    required String senderId,
    required String recipientId,
    FriendRequestStatus status = FriendRequestStatus.pending,
  }) {
    return FriendRequest(
      id: const Uuid().v4(),
      senderId: senderId,
      recipientId: recipientId,
      status: status,
      createdAt: DateTime.now(),
    );
  }

  /// Crea una richiesta di amicizia da JSON
  factory FriendRequest.fromJson(Map<String, dynamic> json) => _$FriendRequestFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$FriendRequestToJson(this);

  @override
  FriendRequest copyWith({
    String? id,
    String? senderId,
    String? recipientId,
    FriendRequestStatus? status,
    DateTime? createdAt,
    UserProfile? sender,
    UserProfile? recipient,
  }) {
    return FriendRequest(
      id: id ?? this.id,
      senderId: senderId ?? this.senderId,
      recipientId: recipientId ?? this.recipientId,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      sender: sender ?? this.sender,
      recipient: recipient ?? this.recipient,
    );
  }
} 