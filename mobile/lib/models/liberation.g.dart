// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'liberation.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Liberation _$LiberationFromJson(Map<String, dynamic> json) {
  $checkKeys(
    json,
    requiredKeys: const ['ID', 'Health', 'StartAt', 'HelldiversID'],
  );
  return Liberation(
    id: (json['ID'] as num).toInt(),
    health: (json['Health'] as num).toInt(),
    players: (json['Players'] as num).toInt(),
    previousHealth: (json['StartAt'] as num).toInt(),
    planet: json['Planet'] == null
        ? null
        : Planet.fromJson(json['Planet'] as Map<String, dynamic>),
    helldiversID: (json['HelldiversID'] as num).toInt(),
  );
}

Map<String, dynamic> _$LiberationToJson(Liberation instance) =>
    <String, dynamic>{
      'ID': instance.id,
      'Health': instance.health,
      'StartAt': instance.previousHealth,
      'Players': instance.players,
      'Planet': instance.planet,
      'HelldiversID': instance.helldiversID,
    };
