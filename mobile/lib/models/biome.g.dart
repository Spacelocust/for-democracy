// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'biome.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Biome _$BiomeFromJson(Map<String, dynamic> json) {
  $checkKeys(
    json,
    requiredKeys: const ['ID', 'Name'],
  );
  return Biome(
    id: (json['ID'] as num).toInt(),
    name: json['Name'] as String,
    description: json['Description'] as String?,
    planets: planetsFromJson(json['Planets'] as String?),
  );
}

Map<String, dynamic> _$BiomeToJson(Biome instance) => <String, dynamic>{
      'ID': instance.id,
      'Name': instance.name,
      'Description': instance.description,
      'Planets': instance.planets,
    };
