import 'package:json_annotation/json_annotation.dart';
import 'package:mobile/models/group.dart';
import 'package:mobile/models/user.dart';

part 'group_user.g.dart';

@JsonSerializable()
class GroupUser {
  @JsonKey(required: true, name: 'ID')
  final int id;

  @JsonKey(name: 'Group')
  final Group? group;

  @JsonKey(required: true, name: 'GroupID')
  final int groupId;

  @JsonKey(name: 'User')
  final User? user;

  @JsonKey(required: true, name: 'UserID')
  final int userId;

  @JsonKey(required: true, name: 'Owner')
  final bool owner;

  GroupUser({
    required this.id,
    this.group,
    required this.groupId,
    this.user,
    required this.userId,
    required this.owner,
  });

  factory GroupUser.fromJson(Map<String, dynamic> json) =>
      _$GroupUserFromJson(json);

  Map<String, dynamic> toJson() => _$GroupUserToJson(this);
}
