import 'package:json_annotation/json_annotation.dart';

part 'mission.g.dart';

@JsonSerializable()
class Mission {
  @JsonKey(required: true, name: 'ID')
  final int id;

  @JsonKey(required: true, name: 'Name')
  final String name;

  Mission({
    required this.id,
    required this.name,
  });

  factory Mission.fromJson(Map<String, dynamic> json) =>
      _$MissionFromJson(json);

  Map<String, dynamic> toJson() => _$MissionToJson(this);
}
