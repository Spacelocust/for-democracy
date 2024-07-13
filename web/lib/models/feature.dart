import 'package:json_annotation/json_annotation.dart';

part 'feature.g.dart';

@JsonSerializable()
class Feature {
  @JsonKey(required: true, name: 'active')
  final bool active;

  @JsonKey(required: true, name: 'name')
  final String name;

  Feature({
    this.active = false,
    required this.name,
  });

  factory Feature.fromJson(Map<String, dynamic> json) =>
      _$FeatureFromJson(json);

  Map<String, dynamic> toJson() => _$FeatureToJson(this);
}
