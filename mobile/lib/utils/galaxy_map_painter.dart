import 'package:flutter/material.dart';
import 'dart:ui' as ui;

class GalaxyMapPainter extends CustomPainter {
  final ui.Image image;

  final Size imageSize;

  const GalaxyMapPainter({
    required this.image,
    required this.imageSize,
  });

  @override
  void paint(Canvas canvas, Size size) async {
    var middleOffset = Offset(
      size.width / 2 - imageSize.width / 2,
      size.height / 2 - imageSize.height / 2,
    );
    var canvasPaint = Paint();
    canvasPaint.color = Colors.black;

    canvas.drawPaint(canvasPaint);
    canvas.drawImage(image, middleOffset, Paint());
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
