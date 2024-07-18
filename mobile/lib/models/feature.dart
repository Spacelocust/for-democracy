import 'package:json_annotation/json_annotation.dart';
import 'package:mobile/enum/feature.dart' as feature_enum;

part 'feature.g.dart';

@JsonSerializable()
class Feature {
  @JsonKey(required: true, name: 'Code')
  final feature_enum.Feature code;

  @JsonKey(required: true, name: 'Enabled')
  final bool enabled;

  Feature({
    this.enabled = false,
    required this.code,
  });

  factory Feature.fromJson(Map<String, dynamic> json) =>
      _$FeatureFromJson(json);

  Map<String, dynamic> toJson() => _$FeatureToJson(this);
}
