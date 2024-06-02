import 'package:flutter/material.dart';
import 'dart:ui' as ui;

TransformationController getTransformationControllerForSize(
  Size size, {
  double zoomFactor = 1.0,
  double margin = 0.0,
}) {
  double xTranslate = margin + ((size.width / 2 - margin * 2) / 2);
  double yTranslate = margin + ((size.height / 4 - margin * 2) / 2);

  var transformationController = TransformationController();

  transformationController.value
    ..setEntry(0, 0, zoomFactor)
    ..setEntry(1, 1, zoomFactor)
    ..setEntry(2, 2, zoomFactor)
    ..setEntry(0, 3, -xTranslate)
    ..setEntry(1, 3, -yTranslate);

  return transformationController;
}

void drawDashedLine({
  required Canvas canvas,
  required Offset p1,
  required Offset p2,
  required Iterable<double> pattern,
  required Paint paint,
}) {
  assert(pattern.length.isEven);
  final distance = (p2 - p1).distance;
  final normalizedPattern = pattern.map((width) => width / distance).toList();
  final points = <Offset>[];

  double t = 0;
  int i = 0;

  while (t < 1) {
    points.add(Offset.lerp(p1, p2, t)!);
    t += normalizedPattern[i++]; // dashWidth
    points.add(Offset.lerp(p1, p2, t.clamp(0, 1))!);
    t += normalizedPattern[i++]; // dashSpace
    i %= normalizedPattern.length;
  }

  canvas.drawPoints(ui.PointMode.lines, points, paint);
}
