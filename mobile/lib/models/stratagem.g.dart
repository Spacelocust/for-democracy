// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'stratagem.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Stratagem _$StratagemFromJson(Map<String, dynamic> json) {
  $checkKeys(
    json,
    requiredKeys: const [
      'ID',
      'Name',
      'UseType',
      'Cooldown',
      'Activation',
      'ImageURL',
      'Type',
      'Keys'
    ],
  );
  return Stratagem(
    id: (json['ID'] as num).toInt(),
    codeName: json['CodeName'] as String?,
    name: json['Name'] as String,
    useCount: (json['UseCount'] as num?)?.toInt(),
    useType: $enumDecode(_$StratagemUseTypeEnumMap, json['UseType']),
    cooldown: (json['Cooldown'] as num).toInt(),
    activation: (json['Activation'] as num).toInt(),
    imageURL: json['ImageURL'] as String,
    type: $enumDecode(_$StratagemTypeEnumMap, json['Type']),
    keys: json['Keys'] as List<dynamic>,
  );
}

Map<String, dynamic> _$StratagemToJson(Stratagem instance) => <String, dynamic>{
      'ID': instance.id,
      'CodeName': instance.codeName,
      'Name': instance.name,
      'UseCount': instance.useCount,
      'UseType': _$StratagemUseTypeEnumMap[instance.useType]!,
      'Cooldown': instance.cooldown,
      'Activation': instance.activation,
      'ImageURL': instance.imageURL,
      'Type': _$StratagemTypeEnumMap[instance.type]!,
      'Keys': instance.keys,
    };

const _$StratagemUseTypeEnumMap = {
  StratagemUseType.self: 'self',
  StratagemUseType.team: 'team',
  StratagemUseType.shared: 'shared',
};

const _$StratagemTypeEnumMap = {
  StratagemType.supply: 'supply',
  StratagemType.mission: 'mission',
  StratagemType.defensive: 'defensive',
  StratagemType.offensive: 'offensive',
};
