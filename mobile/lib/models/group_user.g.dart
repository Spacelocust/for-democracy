// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'group_user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GroupUser _$GroupUserFromJson(Map<String, dynamic> json) {
  $checkKeys(
    json,
    requiredKeys: const ['ID', 'GroupID', 'UserID', 'Owner'],
  );
  return GroupUser(
    id: (json['ID'] as num).toInt(),
    group: json['Group'] == null
        ? null
        : Group.fromJson(json['Group'] as Map<String, dynamic>),
    groupId: (json['GroupID'] as num).toInt(),
    user: json['User'] == null
        ? null
        : User.fromJson(json['User'] as Map<String, dynamic>),
    userId: (json['UserID'] as num).toInt(),
    owner: json['Owner'] as bool,
  );
}

Map<String, dynamic> _$GroupUserToJson(GroupUser instance) => <String, dynamic>{
      'ID': instance.id,
      'Group': instance.group,
      'GroupID': instance.groupId,
      'User': instance.user,
      'UserID': instance.userId,
      'Owner': instance.owner,
    };
