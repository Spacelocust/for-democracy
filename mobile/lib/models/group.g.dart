// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'group.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Group _$GroupFromJson(Map<String, dynamic> json) {
  $checkKeys(
    json,
    requiredKeys: const [
      'ID',
      'Name',
      'Public',
      'StartAt',
      'Difficulty',
      'Missions',
      'GroupUsers',
      'Planet'
    ],
  );
  return Group(
    id: (json['ID'] as num).toInt(),
    code: json['Code'] as String?,
    name: json['Name'] as String,
    description: json['Description'] as String?,
    public: json['Public'] as bool,
    startAt: DateTime.parse(json['StartAt'] as String),
    difficulty: $enumDecode(_$DifficultyEnumMap, json['Difficulty']),
    missions: (json['Missions'] as List<dynamic>)
        .map((e) => Mission.fromJson(e as Map<String, dynamic>))
        .toList(),
    groupUsers: (json['GroupUsers'] as List<dynamic>)
        .map((e) => GroupUser.fromJson(e as Map<String, dynamic>))
        .toList(),
    planet: Planet.fromJson(json['Planet'] as Map<String, dynamic>),
  );
}

Map<String, dynamic> _$GroupToJson(Group instance) => <String, dynamic>{
      'ID': instance.id,
      'Code': instance.code,
      'Name': instance.name,
      'Description': instance.description,
      'Public': instance.public,
      'StartAt': instance.startAt.toIso8601String(),
      'Difficulty': _$DifficultyEnumMap[instance.difficulty]!,
      'Missions': instance.missions,
      'GroupUsers': instance.groupUsers,
      'Planet': instance.planet,
    };

const _$DifficultyEnumMap = {
  Difficulty.trivial: 'trivial',
  Difficulty.easy: 'easy',
  Difficulty.medium: 'medium',
  Difficulty.challenging: 'challenging',
  Difficulty.hard: 'hard',
  Difficulty.extreme: 'extreme',
  Difficulty.suicideMission: 'suicide_mission',
  Difficulty.impossible: 'impossible',
  Difficulty.helldive: 'helldive',
};
