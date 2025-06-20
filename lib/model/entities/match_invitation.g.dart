// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'match_invitation.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserProfileForInvitation _$UserProfileForInvitationFromJson(
        Map<String, dynamic> json) =>
    UserProfileForInvitation(
      id: json['id'] as String,
      username: json['username'] as String?,
      nome: json['nome'] as String?,
      cognome: json['cognome'] as String?,
      avatarUrl: json['avatar_url'] as String?,
    );

Map<String, dynamic> _$UserProfileForInvitationToJson(
        UserProfileForInvitation instance) =>
    <String, dynamic>{
      'id': instance.id,
      'username': instance.username,
      'nome': instance.nome,
      'cognome': instance.cognome,
      'avatar_url': instance.avatarUrl,
    };

MatchInvitation _$MatchInvitationFromJson(Map<String, dynamic> json) =>
    MatchInvitation(
      id: json['id'] as String,
      senderId: json['sender_id'] as String?,
      receiverId: json['receiver_id'] as String?,
      format: json['format'] as String,
      yugiohFormat: json['yugioh_format'] as String?,
      message: json['message'] as String?,
      status: $enumDecode(_$MatchInvitationStatusEnumMap, json['status']),
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
      invitationDate: json['invitation_date'] as String?,
      invitationTime: json['invitation_time'] as String?,
      invitationDateTime: json['invitation_datetime'] as String?,
      formattedDate: json['formatted_date'] as String?,
      formattedTime: json['formatted_time'] as String?,
      senderProfile: json['sender_profile'] == null
          ? null
          : UserProfileForInvitation.fromJson(
              json['sender_profile'] as Map<String, dynamic>),
      receiverProfile: json['receiver_profile'] == null
          ? null
          : UserProfileForInvitation.fromJson(
              json['receiver_profile'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$MatchInvitationToJson(MatchInvitation instance) =>
    <String, dynamic>{
      'id': instance.id,
      'sender_id': instance.senderId,
      'receiver_id': instance.receiverId,
      'format': instance.format,
      'yugioh_format': instance.yugiohFormat,
      'message': instance.message,
      'status': _$MatchInvitationStatusEnumMap[instance.status]!,
      'created_at': instance.createdAt?.toIso8601String(),
      'invitation_date': instance.invitationDate,
      'invitation_time': instance.invitationTime,
      'invitation_datetime': instance.invitationDateTime,
      'formatted_date': instance.formattedDate,
      'formatted_time': instance.formattedTime,
      'sender_profile': instance.senderProfile,
      'receiver_profile': instance.receiverProfile,
    };

const _$MatchInvitationStatusEnumMap = {
  MatchInvitationStatus.pending: 'pending',
  MatchInvitationStatus.accepted: 'accepted',
  MatchInvitationStatus.declined: 'declined',
};
