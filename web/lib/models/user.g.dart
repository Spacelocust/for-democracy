// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

User _$UserFromJson(Map<String, dynamic> json) {
  $checkKeys(
    json,
    requiredKeys: const ['Username', 'AvatarUrl'],
  );
  return User(
    steamId: json['SteamId'] as String,
    username: json['Username'] as String,
    avatarUrl: json['AvatarUrl'] as String,
  );
}

Map<String, dynamic> _$UserToJson(User instance) => <String, dynamic>{
      'SteamId': instance.steamId,
      'Username': instance.username,
      'AvatarUrl': instance.avatarUrl,
    };
