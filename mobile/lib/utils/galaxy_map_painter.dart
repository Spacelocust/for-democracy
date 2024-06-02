import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mobile/models/planet.dart';
import 'package:mobile/utils/canvas.dart';

class GalaxyMapPainter extends CustomPainter {
  /// The information about the background picture to use for the galaxy map.
  final PictureInfo pictureInfo;

  const GalaxyMapPainter({
    required this.pictureInfo,
  });

  @override
  void paint(Canvas canvas, Size size) async {
    var canvasPaint = Paint()..color = Colors.black;

    canvas
      ..translate(
        size.width / 2 - pictureInfo.size.width / 2,
        size.height / 2 - pictureInfo.size.height / 2,
      )
      ..drawPaint(canvasPaint)
      ..drawPicture(pictureInfo.picture);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    if (oldDelegate is GalaxyMapPainter) {
      return pictureInfo != oldDelegate.pictureInfo;
    }

    return true;
  }

  @override
  bool hitTest(Offset position) {
    return false;
  }
}

class GalaxyMapPlanetsWaypointsPainter extends CustomPainter {
  /// The list of planets with their waypoints to display on the galaxy map.
  final List<Planet> planets;

  const GalaxyMapPlanetsWaypointsPainter({
    required this.planets,
  });

  @override
  void paint(Canvas canvas, Size size) async {
    double toX = size.width / 2;
    double toY = size.height / 2;

    for (var planet in planets) {
      double planetX = planet.scaleXTo(toX);
      // Note : because the origin (top-left) is 0.0, we need to subtract the y value from the height of the canvas or the lines will be drawn upside down
      double planetY = size.height - planet.scaleYTo(toY);
      Paint paint = Paint()
        ..color = planet.color.withOpacity(0.8)
        ..strokeWidth = 1;

      for (var waypoint in planet.waypoints) {
        double waypointX = waypoint.scaleXTo(toX);
        double waypointY = size.height - waypoint.scaleYTo(toY);

        drawDashedLine(
          canvas: canvas,
          p1: Offset(planetX, planetY),
          p2: Offset(waypointX, waypointY),
          pattern: [2, 2],
          paint: paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    if (oldDelegate is GalaxyMapPlanetsWaypointsPainter) {
      return !listEquals(planets, oldDelegate.planets);
    }

    return true;
  }

  @override
  bool hitTest(Offset position) {
    return false;
  }
}
