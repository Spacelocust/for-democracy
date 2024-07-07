// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'group_user_mission.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GroupUserMission _$GroupUserMissionFromJson(Map<String, dynamic> json) {
  $checkKeys(
    json,
    requiredKeys: const ['ID'],
  );
  return GroupUserMission(
    id: (json['ID'] as num).toInt(),
    mission: json['Mission'] == null
        ? null
        : Mission.fromJson(json['Mission'] as Map<String, dynamic>),
    user: json['GroupUser'] == null
        ? null
        : GroupUser.fromJson(json['GroupUser'] as Map<String, dynamic>),
    stratagems: (json['Stratagems'] as List<dynamic>?)
        ?.map((e) => Stratagem.fromJson(e as Map<String, dynamic>))
        .toList(),
  );
}

Map<String, dynamic> _$GroupUserMissionToJson(GroupUserMission instance) =>
    <String, dynamic>{
      'ID': instance.id,
      'Mission': instance.mission,
      'GroupUser': instance.user,
      'Stratagems': instance.stratagems,
    };
