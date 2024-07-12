// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'feature.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Feature _$FeatureFromJson(Map<String, dynamic> json) {
  $checkKeys(
    json,
    requiredKeys: const ['Active', 'Name'],
  );
  return Feature(
    active: json['Active'] as bool,
    name: json['Name'] as String,
  );
}

Map<String, dynamic> _$FeatureToJson(Feature instance) => <String, dynamic>{
      'Active': instance.active,
      'Name': instance.name,
    };
