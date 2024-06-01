import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

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
