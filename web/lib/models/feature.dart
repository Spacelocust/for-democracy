import 'package:json_annotation/json_annotation.dart';

part 'feature.g.dart';

@JsonSerializable()
class Feature {
  @JsonKey(required: true, name: 'code')
  final String code;

  @JsonKey(required: true, name: 'active')
  final bool enabled;

  Feature({
    this.enabled = false,
    required this.code,
  });

  factory Feature.fromJson(Map<String, dynamic> json) =>
      _$FeatureFromJson(json);

  Map<String, dynamic> toJson() => _$FeatureToJson(this);
}
