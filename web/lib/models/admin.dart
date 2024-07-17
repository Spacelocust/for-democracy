import 'package:json_annotation/json_annotation.dart';

part 'admin.g.dart';

@JsonSerializable()
class Admin {
  @JsonKey(required: true, name: 'Id')
  final int id;

  @JsonKey(required: true, name: 'Username')
  final String username;

  Admin({
    required this.id,
    required this.username,
  });

  factory Admin.fromJson(Map<String, dynamic> json) => _$AdminFromJson(json);

  Map<String, dynamic> toJson() => _$AdminToJson(this);
}
