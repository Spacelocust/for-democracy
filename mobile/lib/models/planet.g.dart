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
      'PositionX',
      'PositionY',
      'HelldiversID',
      'Owner',
      'InitialOwner',
      'ImageURL',
      'BackgroundURL',
      'Waypoints',
      'Statistic',
      'Effects',
      'Sector'
    ],
  );
  return Planet(
    id: (json['ID'] as num).toInt(),
    name: json['Name'] as String,
    maxHealth: (json['MaxHealth'] as num?)?.toInt(),
    disabled: json['Disabled'] as bool,
    positionX: (json['PositionX'] as num).toDouble(),
    positionY: (json['PositionY'] as num).toDouble(),
    helldiversID: (json['HelldiversID'] as num).toInt(),
    owner: $enumDecode(_$FactionEnumMap, json['Owner']),
    initialOwner: $enumDecode(_$FactionEnumMap, json['InitialOwner']),
    imageUrl: json['ImageURL'] as String,
    backgroundUrl: json['BackgroundURL'] as String,
    waypoints: (json['Waypoints'] as List<dynamic>)
        .map((e) => Waypoint.fromJson(e as Map<String, dynamic>))
        .toList(),
    statistic: Statistic.fromJson(json['Statistic'] as Map<String, dynamic>),
    liberation: json['Liberation'] == null
        ? null
        : Liberation.fromJson(json['Liberation'] as Map<String, dynamic>),
    defence: json['Defence'] == null
        ? null
        : Defence.fromJson(json['Defence'] as Map<String, dynamic>),
    effects: (json['Effects'] as List<dynamic>)
        .map((e) => Effect.fromJson(e as Map<String, dynamic>))
        .toList(),
    sector: Sector.fromJson(json['Sector'] as Map<String, dynamic>),
  );
}

Map<String, dynamic> _$PlanetToJson(Planet instance) => <String, dynamic>{
      'ID': instance.id,
      'Name': instance.name,
      'MaxHealth': instance.maxHealth,
      'Disabled': instance.disabled,
      'PositionX': instance.positionX,
      'PositionY': instance.positionY,
      'HelldiversID': instance.helldiversID,
      'Owner': _$FactionEnumMap[instance.owner]!,
      'InitialOwner': _$FactionEnumMap[instance.initialOwner]!,
      'ImageURL': instance.imageUrl,
      'BackgroundURL': instance.backgroundUrl,
      'Waypoints': instance.waypoints,
      'Statistic': instance.statistic,
      'Liberation': instance.liberation,
      'Defence': instance.defence,
      'Effects': instance.effects,
      'Sector': instance.sector,
    };

const _$FactionEnumMap = {
  Faction.humans: 'humans',
  Faction.terminids: 'terminids',
  Faction.illuminates: 'illuminates',
  Faction.automatons: 'automatons',
};
