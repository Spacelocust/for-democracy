// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'feature.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Feature _$FeatureFromJson(Map<String, dynamic> json) {
  $checkKeys(
    json,
    requiredKeys: const ['Code', 'Enabled'],
  );
  return Feature(
    code: json['Code'] as String,
    enabled: json['Enabled'] as bool,
  );
}

Map<String, dynamic> _$FeatureToJson(Feature instance) => <String, dynamic>{
      'Code': instance.code,
      'Enabled': instance.enabled,
    };
