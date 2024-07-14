import 'package:app/models/group.dart';
import 'package:app/models/user.dart';
import 'package:json_annotation/json_annotation.dart';

part 'group_user.g.dart';

@JsonSerializable()
class GroupUser {
  @JsonKey(required: true, name: 'ID')
  final int id;

  @JsonKey(name: 'Group')
  final Group? group;

  @JsonKey(name: 'User')
  final User? user;

  @JsonKey(required: true, name: 'Owner')
  final bool owner;

  GroupUser({
    required this.id,
    this.group,
    this.user,
    required this.owner,
  });

  factory GroupUser.fromJson(Map<String, dynamic> json) =>
      _$GroupUserFromJson(json);

  Map<String, dynamic> toJson() => _$GroupUserToJson(this);
}
