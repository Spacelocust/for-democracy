// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'statistic.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Statistic _$StatisticFromJson(Map<String, dynamic> json) {
  $checkKeys(
    json,
    requiredKeys: const [
      'ID',
      'PlanetID',
      'MissionsWon',
      'MissionTime',
      'BugKills',
      'AutomatonKills',
      'IlluminateKills',
      'BulletsFired',
      'BulletsHit',
      'TimePlayed',
      'Deaths',
      'Revives',
      'FriendlyKills',
      'MissionSuccessRate',
      'Accuracy'
    ],
  );
  return Statistic(
    id: (json['ID'] as num).toInt(),
    planetId: (json['PlanetID'] as num).toInt(),
    missionsWon: (json['MissionsWon'] as num).toInt(),
    missionTime: (json['MissionTime'] as num).toInt(),
    bugKills: (json['BugKills'] as num).toInt(),
    automatonKills: (json['AutomatonKills'] as num).toInt(),
    illuminateKills: (json['IlluminateKills'] as num).toInt(),
    bulletsFired: (json['BulletsFired'] as num).toInt(),
    bulletsHit: (json['BulletsHit'] as num).toInt(),
    timePlayed: (json['TimePlayed'] as num).toInt(),
    deaths: (json['Deaths'] as num).toInt(),
    revives: (json['Revives'] as num).toInt(),
    friendlyKills: (json['FriendlyKills'] as num).toInt(),
    missionSuccessRate: (json['MissionSuccessRate'] as num).toInt(),
    accuracy: (json['Accuracy'] as num).toInt(),
  );
}

Map<String, dynamic> _$StatisticToJson(Statistic instance) => <String, dynamic>{
      'ID': instance.id,
      'PlanetID': instance.planetId,
      'MissionsWon': instance.missionsWon,
      'MissionTime': instance.missionTime,
      'BugKills': instance.bugKills,
      'AutomatonKills': instance.automatonKills,
      'IlluminateKills': instance.illuminateKills,
      'BulletsFired': instance.bulletsFired,
      'BulletsHit': instance.bulletsHit,
      'TimePlayed': instance.timePlayed,
      'Deaths': instance.deaths,
      'Revives': instance.revives,
      'FriendlyKills': instance.friendlyKills,
      'MissionSuccessRate': instance.missionSuccessRate,
      'Accuracy': instance.accuracy,
    };
