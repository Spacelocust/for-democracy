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
    enabled: json['Enabled'] as bool? ?? false,
    code: json['Code'] as String,
  );
}

Map<String, dynamic> _$FeatureToJson(Feature instance) => <String, dynamic>{
      'Code': instance.code,
      'Enabled': instance.enabled,
    };
