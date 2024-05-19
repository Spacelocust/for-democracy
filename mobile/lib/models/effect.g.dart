// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'effect.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Effect _$EffectFromJson(Map<String, dynamic> json) {
  $checkKeys(
    json,
    requiredKeys: const ['ID', 'Name'],
  );
  return Effect(
    id: (json['ID'] as num).toInt(),
    name: json['Name'] as String,
    description: json['Description'] as String?,
    planets: planetsFromJson(json['Planets'] as String?),
  );
}

Map<String, dynamic> _$EffectToJson(Effect instance) => <String, dynamic>{
      'ID': instance.id,
      'Name': instance.name,
      'Description': instance.description,
      'Planets': instance.planets,
    };
