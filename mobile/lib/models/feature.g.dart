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
    code: $enumDecode(_$FeatureEnumMap, json['Code']),
  );
}

Map<String, dynamic> _$FeatureToJson(Feature instance) => <String, dynamic>{
      'Code': _$FeatureEnumMap[instance.code]!,
      'Enabled': instance.enabled,
    };

const _$FeatureEnumMap = {
  feature_enum.Feature.map: 'map',
  feature_enum.Feature.planetList: 'planet_list',
};
