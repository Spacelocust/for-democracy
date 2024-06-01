// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'waypoint.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Waypoint _$WaypointFromJson(Map<String, dynamic> json) {
  $checkKeys(
    json,
    requiredKeys: const ['x', 'y'],
  );
  return Waypoint(
    x: (json['x'] as num).toDouble(),
    y: (json['y'] as num).toDouble(),
  );
}

Map<String, dynamic> _$WaypointToJson(Waypoint instance) => <String, dynamic>{
      'x': instance.x,
      'y': instance.y,
    };
