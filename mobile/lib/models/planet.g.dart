// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'planet.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Planet _$PlanetFromJson(Map<String, dynamic> json) {
  $checkKeys(
    json,
    requiredKeys: const [
      'ID',
      'Name',
      'Disabled',
      'Regeneration',
      'PositionX',
      'PositionY',
      'HelldiversID'
    ],
  );
  return Planet(
    id: (json['ID'] as num).toInt(),
    name: json['Name'] as String,
    maxHealth: (json['MaxHealth'] as num?)?.toInt(),
    disabled: json['Disabled'] as bool,
    regeneration: (json['Regeneration'] as num).toInt(),
    positionX: (json['PositionX'] as num).toDouble(),
    positionY: (json['PositionY'] as num).toDouble(),
    helldiversID: (json['HelldiversID'] as num).toInt(),
  );
}

Map<String, dynamic> _$PlanetToJson(Planet instance) => <String, dynamic>{
      'ID': instance.id,
      'Name': instance.name,
      'MaxHealth': instance.maxHealth,
      'Disabled': instance.disabled,
      'Regeneration': instance.regeneration,
      'PositionX': instance.positionX,
      'PositionY': instance.positionY,
      'HelldiversID': instance.helldiversID,
    };
