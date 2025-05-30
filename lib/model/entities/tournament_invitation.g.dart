// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tournament_invitation.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TournamentInvitation _$TournamentInvitationFromJson(
        Map<String, dynamic> json) =>
    TournamentInvitation(
      id: json['id'] as String,
      tournamentId: json['tournament_id'] as String,
      senderId: json['sender_id'] as String,
      receiverId: json['receiver_id'] as String,
      message: json['message'] as String?,
      status: $enumDecodeNullable(
              _$TournamentInvitationStatusEnumMap, json['status']) ??
          TournamentInvitationStatus.pending,
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
    );

Map<String, dynamic> _$TournamentInvitationToJson(
        TournamentInvitation instance) =>
    <String, dynamic>{
      'id': instance.id,
      'tournament_id': instance.tournamentId,
      'sender_id': instance.senderId,
      'receiver_id': instance.receiverId,
      'message': instance.message,
      'status': _$TournamentInvitationStatusEnumMap[instance.status]!,
      'created_at': instance.createdAt?.toIso8601String(),
    };

const _$TournamentInvitationStatusEnumMap = {
  TournamentInvitationStatus.pending: 'pending',
  TournamentInvitationStatus.accepted: 'accepted',
  TournamentInvitationStatus.declined: 'declined',
};
