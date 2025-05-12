// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profile.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Profile _$ProfileFromJson(Map<String, dynamic> json) => Profile(
      id: json['id'] as String,
      username: json['username'] as String,
      nome: json['nome'] as String,
      cognome: json['cognome'] as String,
      dataDiNascita: DateTime.parse(json['data_di_nascita'] as String),
      citta: json['città'] as String,
      provincia: json['provincia'] as String,
      stato: json['stato'] as String,
      avatarUrl: json['avatar_url'] as String?,
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
    );

Map<String, dynamic> _$ProfileToJson(Profile instance) => <String, dynamic>{
      'id': instance.id,
      'username': instance.username,
      'nome': instance.nome,
      'cognome': instance.cognome,
      'data_di_nascita': instance.dataDiNascita.toIso8601String(),
      'città': instance.citta,
      'provincia': instance.provincia,
      'stato': instance.stato,
      'avatar_url': instance.avatarUrl,
      'created_at': instance.createdAt?.toIso8601String(),
    };
