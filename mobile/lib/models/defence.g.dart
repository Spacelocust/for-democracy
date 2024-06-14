// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'defence.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Defence _$DefenceFromJson(Map<String, dynamic> json) {
  $checkKeys(
    json,
    requiredKeys: const [
      'ID',
      'StartAt',
      'EndAt',
      'EnemyFaction',
      'Health',
      'MaxHealth',
      'ImpactPerHour',
      'HelldiversID'
    ],
  );
  return Defence(
    id: (json['ID'] as num).toInt(),
    players: (json['Players'] as num).toInt(),
    startAt: DateTime.parse(json['StartAt'] as String),
    endAt: DateTime.parse(json['EndAt'] as String),
    enemyFaction: $enumDecode(_$FactionEnumMap, json['EnemyFaction']),
    health: (json['Health'] as num).toInt(),
    maxHealth: (json['MaxHealth'] as num).toInt(),
    impactPerHour: (json['ImpactPerHour'] as num).toDouble(),
    planet: json['Planet'] == null
        ? null
        : Planet.fromJson(json['Planet'] as Map<String, dynamic>),
    helldiversID: (json['HelldiversID'] as num).toInt(),
  );
}

Map<String, dynamic> _$DefenceToJson(Defence instance) => <String, dynamic>{
      'ID': instance.id,
      'Players': instance.players,
      'StartAt': instance.startAt.toIso8601String(),
      'EndAt': instance.endAt.toIso8601String(),
      'EnemyFaction': _$FactionEnumMap[instance.enemyFaction]!,
      'Health': instance.health,
      'MaxHealth': instance.maxHealth,
      'ImpactPerHour': instance.impactPerHour,
      'Planet': instance.planet,
      'HelldiversID': instance.helldiversID,
    };

const _$FactionEnumMap = {
  Faction.humans: 'humans',
  Faction.terminids: 'terminids',
  Faction.illuminates: 'illuminates',
  Faction.automatons: 'automatons',
};
