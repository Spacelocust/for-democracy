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
    liberation: json['Liberation'] == null
        ? null
        : Liberation.fromJson(json['Liberation'] as Map<String, dynamic>),
    defence: json['Defence'] == null
        ? null
        : Defence.fromJson(json['Defence'] as Map<String, dynamic>),
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
      'Liberation': instance.liberation,
      'Defence': instance.defence,
    };

const _$FactionEnumMap = {
  Faction.humans: 'humans',
  Faction.terminids: 'terminids',
  Faction.illuminates: 'illuminates',
  Faction.automatons: 'automatons',
};
