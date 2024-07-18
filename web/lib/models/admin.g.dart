// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Admin _$AdminFromJson(Map<String, dynamic> json) {
  $checkKeys(
    json,
    requiredKeys: const ['ID', 'Username'],
  );
  return Admin(
    id: (json['ID'] as num).toInt(),
    username: json['Username'] as String,
  );
}

Map<String, dynamic> _$AdminToJson(Admin instance) => <String, dynamic>{
      'ID': instance.id,
      'Username': instance.username,
    };
