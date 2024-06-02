import 'dart:async';
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
