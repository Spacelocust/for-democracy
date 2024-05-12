// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'planet.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Planet _$PlanetFromJson(Map<String, dynamic> json) => Planet(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      health: (json['health'] as num?)?.toInt(),
      maxHealth: (json['maxHealth'] as num?)?.toInt(),
      players: (json['players'] as num).toInt(),
      disabled: json['disabled'] as bool,
      regeneration: (json['regeneration'] as num).toInt(),
      positionX: (json['positionX'] as num).toDouble(),
      positionY: (json['positionY'] as num).toDouble(),
      helldiversID: (json['helldiversID'] as num).toInt(),
    );

Map<String, dynamic> _$PlanetToJson(Planet instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'health': instance.health,
      'maxHealth': instance.maxHealth,
      'players': instance.players,
      'disabled': instance.disabled,
      'regeneration': instance.regeneration,
      'positionX': instance.positionX,
      'positionY': instance.positionY,
      'helldiversID': instance.helldiversID,
    };
