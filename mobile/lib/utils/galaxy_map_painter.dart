import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mobile/models/planet.dart';
import 'dart:ui' as ui;

class GalaxyMapPainter extends CustomPainter {
  final PictureInfo pictureInfo;

  const GalaxyMapPainter({
    required this.pictureInfo,
  });

  @override
  void paint(Canvas canvas, Size size) async {
    var canvasPaint = Paint()..color = Colors.black;

    canvas
      ..save()
      ..translate(
        size.width / 2 - pictureInfo.size.width / 2,
        size.height / 2 - pictureInfo.size.height / 2,
      )
      ..drawPaint(canvasPaint)
      ..drawPicture(pictureInfo.picture)
      ..restore();
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

class GalaxyMapPlanetsPainter extends CustomPainter {
  final List<Planet> planets;

  final Map<int, ui.Image> planetImages;

  const GalaxyMapPlanetsPainter({
    required this.planets,
    required this.planetImages,
  });

  List<_PlanetPainter> _getPlanetPainters() {
    return planets.map((planet) {
      return _PlanetPainter(
        id: planet.id,
        highlighted: false,
        image: planetImages[planet.id]!,
        position: Offset(planet.positionX, planet.positionY),
      );
    }).toList();
  }

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.width, size.height),
        const Radius.circular(10),
      ),
      Paint()
        ..color = Colors.red
        ..style = PaintingStyle.stroke,
    );

    for (var planetPainter in _getPlanetPainters()) {
      canvas.drawImage(
        planetPainter.image,
        planetPainter.position,
        Paint(),
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    if (oldDelegate is GalaxyMapPlanetsPainter) {
      return listEquals(planets, oldDelegate.planets);
    }

    return true;
  }

  @override
  bool hitTest(Offset position) {
    return true;
  }
}

class _PlanetPainter {
  final int id;

  final bool highlighted;

  final ui.Image image;

  final Offset position;

  const _PlanetPainter({
    required this.id,
    required this.highlighted,
    required this.image,
    required this.position,
  });
}
