import 'package:json_annotation/json_annotation.dart';

part 'waypoint.g.dart';

@JsonSerializable()
class Waypoint {
  @JsonKey(required: true, name: 'x')
  final double x;

  @JsonKey(required: true, name: 'y')
  final double y;

  Waypoint({
    required this.x,
    required this.y,
  });

  double scaleXTo(double to) => (x + 1) * to;

  double scaleYTo(double to) => (y + 1) * to;

  factory Waypoint.fromJson(Map<String, dynamic> json) =>
      _$WaypointFromJson(json);

  Map<String, dynamic> toJson() => _$WaypointToJson(this);
}
