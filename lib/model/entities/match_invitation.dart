import 'package:json_annotation/json_annotation.dart';
import 'package:uuid/uuid.dart';
import '../base_model.dart';
import '../user.dart';

part 'match_invitation.g.dart';

/// Status delle richieste di match
enum MatchInvitationStatus {
  @JsonValue('pending')
  pending,
  @JsonValue('accepted')
  accepted,
  @JsonValue('declined')
  declined
}

/// Profilo utente per gli inviti
@JsonSerializable()
class UserProfileForInvitation {
  /// ID dell'utente
  final String id;
  
  /// Username dell'utente
  final String? username;
  
  /// Nome dell'utente
  final String? nome;
  
  /// Cognome dell'utente
  final String? cognome;
  
  /// URL dell'avatar
  @JsonKey(name: 'avatar_url')
  final String? avatarUrl;
  


  const UserProfileForInvitation({
    required this.id,
    this.username,
    this.nome,
    this.cognome,
    this.avatarUrl,
  });

  factory UserProfileForInvitation.fromJson(Map<String, dynamic> json) => 
      _$UserProfileForInvitationFromJson(json);

  Map<String, dynamic> toJson() => _$UserProfileForInvitationToJson(this);

  /// Ottiene il nome completo
  String get fullName {
    final parts = [nome, cognome].where((part) => part != null && part.isNotEmpty);
    if (parts.isNotEmpty) {
      return parts.join(' ');
    }
    return username ?? 'Utente sconosciuto';
  }

  /// Ottiene il nome di visualizzazione
  String get displayName => username ?? fullName;
}

/// Modello per gli inviti ai match
@JsonSerializable()
class MatchInvitation extends BaseModel {
  /// ID dell'utente che invia l'invito
  @JsonKey(name: 'sender_id')
  final String? senderId;
  
  /// ID dell'utente che riceve l'invito
  @JsonKey(name: 'receiver_id')
  final String? receiverId;
  
  /// Formato del match (es. "advanced", "edison", "goat")
  final String format;
  
  /// Alias per il formato Yu-Gi-Oh (per chiarezza)
  @JsonKey(name: 'yugioh_format')
  final String? yugiohFormat;
  
  /// Messaggio opzionale per il destinatario
  final String? message;
  
  /// Stato dell'invito
  final MatchInvitationStatus status;
  
  /// Data di creazione (timestamp originale)
  @JsonKey(name: 'created_at')
  final DateTime? createdAt;
  
  /// Solo data dell'invito (YYYY-MM-DD)
  @JsonKey(name: 'invitation_date')
  final String? invitationDate;
  
  /// Solo ora dell'invito (HH:MM:SS)
  @JsonKey(name: 'invitation_time')
  final String? invitationTime;
  
  /// Data e ora completa ISO
  @JsonKey(name: 'invitation_datetime')
  final String? invitationDateTime;
  
  /// Data formattata in italiano (DD/MM/YYYY)
  @JsonKey(name: 'formatted_date')
  final String? formattedDate;
  
  /// Ora formattata in italiano (HH:MM)
  @JsonKey(name: 'formatted_time')
  final String? formattedTime;
  
  /// Profilo completo del mittente
  @JsonKey(name: 'sender_profile')
  final UserProfileForInvitation? senderProfile;
  
  /// Profilo completo del destinatario
  @JsonKey(name: 'receiver_profile')
  final UserProfileForInvitation? receiverProfile;
  
  /// Info sull'utente mittente (opzionale, per compatibilità)
  @JsonKey(includeIfNull: false, includeFromJson: false, includeToJson: false)
  final UserProfile? sender;
  
  /// Info sull'utente destinatario (opzionale, per compatibilità)
  @JsonKey(includeIfNull: false, includeFromJson: false, includeToJson: false)
  final UserProfile? recipient;

  /// Costruttore
  const MatchInvitation({
    required super.id,
    this.senderId,
    this.receiverId,
    required this.format,
    this.yugiohFormat,
    this.message,
    required this.status,
    this.createdAt,
    this.invitationDate,
    this.invitationTime,
    this.invitationDateTime,
    this.formattedDate,
    this.formattedTime,
    this.senderProfile,
    this.receiverProfile,
    this.sender,
    this.recipient,
  });

  /// Crea un nuovo invito con ID generato
  factory MatchInvitation.create({
    required String senderId,
    required String receiverId,
    required String format,
    String? message,
    MatchInvitationStatus status = MatchInvitationStatus.pending,
  }) {
    return MatchInvitation(
      id: const Uuid().v4(),
      senderId: senderId,
      receiverId: receiverId,
      format: format,
      yugiohFormat: format,
      message: message,
      status: status,
      createdAt: DateTime.now(),
    );
  }

  /// Crea un invito da JSON
  factory MatchInvitation.fromJson(Map<String, dynamic> json) => _$MatchInvitationFromJson(json);

  /// Crea un invito dai dati della edge function
  factory MatchInvitation.fromEdgeFunctionResponse(Map<String, dynamic> json) {
    // Gestisce i profili utente che potrebbero arrivare come oggetti già parsati
    UserProfileForInvitation? senderProfile;
    UserProfileForInvitation? receiverProfile;
    
    // Gestisce sender_profile
    if (json['sender_profile'] != null) {
      if (json['sender_profile'] is Map<String, dynamic>) {
        senderProfile = UserProfileForInvitation.fromJson(json['sender_profile']);
      } else if (json['sender_profile'] is UserProfileForInvitation) {
        senderProfile = json['sender_profile'];
      }
    }
    
    // Gestisce receiver_profile
    if (json['receiver_profile'] != null) {
      if (json['receiver_profile'] is Map<String, dynamic>) {
        receiverProfile = UserProfileForInvitation.fromJson(json['receiver_profile']);
      } else if (json['receiver_profile'] is UserProfileForInvitation) {
        receiverProfile = json['receiver_profile'];
      }
    }
    
    // Gestisce anche i profili nel formato vecchio (sender/receiver)
    if (senderProfile == null && json['sender'] != null) {
      if (json['sender'] is Map<String, dynamic>) {
        senderProfile = UserProfileForInvitation.fromJson(json['sender']);
      }
    }
    
    if (receiverProfile == null && json['receiver'] != null) {
      if (json['receiver'] is Map<String, dynamic>) {
        receiverProfile = UserProfileForInvitation.fromJson(json['receiver']);
      }
    }
    
    return MatchInvitation(
      id: json['id'] as String,
      senderId: json['sender_id'] as String?,
      receiverId: json['receiver_id'] as String?,
      format: json['format'] as String,
      yugiohFormat: json['yugioh_format'] as String?,
      message: json['message'] as String?,
      status: MatchInvitationStatus.values.firstWhere(
        (e) => e.toString().split('.').last == json['status'],
        orElse: () => MatchInvitationStatus.pending,
      ),
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at'] as String)
          : null,
      invitationDate: json['invitation_date'] as String?,
      invitationTime: json['invitation_time'] as String?,
      invitationDateTime: json['invitation_datetime'] as String?,
      formattedDate: json['formatted_date'] as String?,
      formattedTime: json['formatted_time'] as String?,
      senderProfile: senderProfile,
      receiverProfile: receiverProfile,
    );
  }

  @override
  Map<String, dynamic> toJson() => _$MatchInvitationToJson(this);

  @override
  MatchInvitation copyWith({
    String? id,
    String? senderId,
    String? receiverId,
    String? format,
    String? yugiohFormat,
    String? message,
    MatchInvitationStatus? status,
    DateTime? createdAt,
    String? invitationDate,
    String? invitationTime,
    String? invitationDateTime,
    String? formattedDate,
    String? formattedTime,
    UserProfileForInvitation? senderProfile,
    UserProfileForInvitation? receiverProfile,
    UserProfile? sender,
    UserProfile? recipient,
  }) {
    return MatchInvitation(
      id: id ?? this.id,
      senderId: senderId ?? this.senderId,
      receiverId: receiverId ?? this.receiverId,
      format: format ?? this.format,
      yugiohFormat: yugiohFormat ?? this.yugiohFormat,
      message: message ?? this.message,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      invitationDate: invitationDate ?? this.invitationDate,
      invitationTime: invitationTime ?? this.invitationTime,
      invitationDateTime: invitationDateTime ?? this.invitationDateTime,
      formattedDate: formattedDate ?? this.formattedDate,
      formattedTime: formattedTime ?? this.formattedTime,
      senderProfile: senderProfile ?? this.senderProfile,
      receiverProfile: receiverProfile ?? this.receiverProfile,
      sender: sender ?? this.sender,
      recipient: recipient ?? this.recipient,
    );
  }

  /// Controlla se l'invito è in attesa
  bool get isPending => status == MatchInvitationStatus.pending;

  /// Controlla se l'invito è stato accettato
  bool get isAccepted => status == MatchInvitationStatus.accepted;

  /// Controlla se l'invito è stato rifiutato
  bool get isDeclined => status == MatchInvitationStatus.declined;

  /// Ottiene il formato da visualizzare (preferisce yugiohFormat)
  String get displayFormat => yugiohFormat ?? format;

  /// Ottiene la data da visualizzare (preferisce formattedDate)
  String get displayDate => formattedDate ?? invitationDate ?? createdAt?.toLocal().toString().split(' ')[0] ?? '';

  /// Ottiene l'ora da visualizzare (preferisce formattedTime)
  String get displayTime => formattedTime ?? invitationTime ?? createdAt?.toLocal().toString().split(' ')[1].substring(0, 5) ?? '';

  /// Ottiene data e ora combinate da visualizzare
  String get displayDateTime => '${displayDate} ${displayTime}';

  /// Ottiene il profilo del mittente da visualizzare
  UserProfileForInvitation? get displaySenderProfile => senderProfile;

  /// Ottiene il profilo del destinatario da visualizzare
  UserProfileForInvitation? get displayReceiverProfile => receiverProfile;

  /// Controlla se l'invito è scaduto (più di 24 ore)
  bool get isExpired {
    if (createdAt == null) return false;
    final now = DateTime.now();
    final difference = now.difference(createdAt!);
    return difference.inHours >= 24;
  }

  /// Controlla se l'invito è di oggi
  bool get isFromToday {
    if (createdAt == null) return false;
    final now = DateTime.now();
    final inviteDate = createdAt!.toLocal();
    return now.year == inviteDate.year &&
           now.month == inviteDate.month &&
           now.day == inviteDate.day;
  }
} 