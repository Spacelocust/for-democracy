// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mission.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Mission _$MissionFromJson(Map<String, dynamic> json) {
  $checkKeys(
    json,
    requiredKeys: const ['ID', 'Name', 'ObjectiveTypes', 'GroupUserMissions'],
  );
  return Mission(
    id: (json['ID'] as num).toInt(),
    name: json['Name'] as String,
  );
}

Map<String, dynamic> _$MissionToJson(Mission instance) => <String, dynamic>{
      'ID': instance.id,
      'Name': instance.name,
    };
