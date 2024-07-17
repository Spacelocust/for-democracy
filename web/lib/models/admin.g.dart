// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Admin _$AdminFromJson(Map<String, dynamic> json) {
  $checkKeys(
    json,
    requiredKeys: const ['Id', 'Username'],
  );
  return Admin(
    id: (json['Id'] as num).toInt(),
    username: json['Username'] as String,
  );
}

Map<String, dynamic> _$AdminToJson(Admin instance) => <String, dynamic>{
      'Id': instance.id,
      'Username': instance.username,
    };
