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
      'Health',
      'StartAt',
      'EndAt',
      'EnemyFaction',
      'EnemyHealth',
      'EnemyMaxHealth',
      'HelldiversID'
    ],
  );
  return Defence(
    id: (json['ID'] as num).toInt(),
    health: (json['Health'] as num).toInt(),
    startAt: DateTime.parse(json['StartAt'] as String),
    endAt: DateTime.parse(json['EndAt'] as String),
    enemyFaction: $enumDecode(_$FactionEnumMap, json['EnemyFaction']),
    enemyHealth: (json['EnemyHealth'] as num).toInt(),
    enemyMaxHealth: (json['EnemyMaxHealth'] as num).toInt(),
    planet: json['Planet'] == null
        ? null
        : Planet.fromJson(json['Planet'] as Map<String, dynamic>),
    helldiversID: (json['HelldiversID'] as num).toInt(),
  );
}

Map<String, dynamic> _$DefenceToJson(Defence instance) => <String, dynamic>{
      'ID': instance.id,
      'Health': instance.health,
      'StartAt': instance.startAt.toIso8601String(),
      'EndAt': instance.endAt.toIso8601String(),
      'EnemyFaction': _$FactionEnumMap[instance.enemyFaction]!,
      'EnemyHealth': instance.enemyHealth,
      'EnemyMaxHealth': instance.enemyMaxHealth,
      'Planet': instance.planet,
      'HelldiversID': instance.helldiversID,
    };

const _$FactionEnumMap = {
  Faction.humans: 'humans',
  Faction.terminids: 'terminids',
  Faction.automatons: 'illuminates',
  Faction.illuminates: 'automatons',
};
