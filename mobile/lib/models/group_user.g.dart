// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'group_user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GroupUser _$GroupUserFromJson(Map<String, dynamic> json) {
  $checkKeys(
    json,
    requiredKeys: const ['ID', 'Owner'],
  );
  return GroupUser(
    id: (json['ID'] as num).toInt(),
    group: json['Group'] == null
        ? null
        : Group.fromJson(json['Group'] as Map<String, dynamic>),
    user: json['User'] == null
        ? null
        : User.fromJson(json['User'] as Map<String, dynamic>),
    owner: json['Owner'] as bool,
  );
}

Map<String, dynamic> _$GroupUserToJson(GroupUser instance) => <String, dynamic>{
      'ID': instance.id,
      'Group': instance.group,
      'User': instance.user,
      'Owner': instance.owner,
    };
