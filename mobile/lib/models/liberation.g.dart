// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'liberation.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Liberation _$LiberationFromJson(Map<String, dynamic> json) {
  $checkKeys(
    json,
    requiredKeys: const [
      'ID',
      'Health',
      'RegenerationPerHour',
      'ImpactPerHour',
      'HelldiversID'
    ],
  );
  return Liberation(
    id: (json['ID'] as num).toInt(),
    health: (json['Health'] as num).toInt(),
    players: (json['Players'] as num).toInt(),
    regenerationPerHour: (json['RegenerationPerHour'] as num).toDouble(),
    impactPerHour: (json['ImpactPerHour'] as num).toDouble(),
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
      'RegenerationPerHour': instance.regenerationPerHour,
      'ImpactPerHour': instance.impactPerHour,
      'Players': instance.players,
      'Planet': instance.planet,
      'HelldiversID': instance.helldiversID,
    };
