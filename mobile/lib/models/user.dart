import 'package:json_annotation/json_annotation.dart';

part 'user.g.dart';

@JsonSerializable()
class User {
  @JsonKey(required: true, name: 'SteamId')
  final String steamId;

  @JsonKey(required: true, name: 'Username')
  final String username;

  @JsonKey(required: true, name: 'AvatarUrl')
  final String avatarUrl;

  User({
    required this.steamId,
    required this.username,
    required this.avatarUrl,
  });

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);

  Map<String, dynamic> toJson() => _$UserToJson(this);
}
