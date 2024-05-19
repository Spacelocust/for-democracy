// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sector.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Sector _$SectorFromJson(Map<String, dynamic> json) {
  $checkKeys(
    json,
    requiredKeys: const ['ID', 'Name'],
  );
  return Sector(
    id: (json['ID'] as num).toInt(),
    name: json['Name'] as String,
    planets: planetsFromJson(json['Planets'] as String?),
  );
}

Map<String, dynamic> _$SectorToJson(Sector instance) => <String, dynamic>{
      'ID': instance.id,
      'Name': instance.name,
      'Planets': instance.planets,
    };
