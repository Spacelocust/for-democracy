import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

const String svgBasePath = 'assets/svgs/';

Future<PictureInfo> loadSvg(String svgName) async {
  final rawSvg = await rootBundle.loadString("$svgBasePath$svgName");

  return vg.loadPicture(
    SvgStringLoader(rawSvg),
    null,
  );
}

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
