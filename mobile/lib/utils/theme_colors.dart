import 'package:flutter/material.dart';

abstract final class ThemeColors {
  static const Map<int, Color> primaryShades = {
    50: Color(0xFFFEFEE8),
    100: Color(0xFFFCFEC3),
    200: Color(0xFFFFFE89),
    300: Color(0xFFFEF546),
    400: Color(0XFFFCE92A),
    500: Color(0XFFECCD06),
    600: Color(0XFFCBA103),
    700: Color(0XFFA27306),
    800: Color(0XFF865A0D),
    900: Color(0XFF724A11),
  };

  static const Color primary = Color(0XFFECCD06);

  static MaterialColor primaryMaterial = MaterialColor(
    primary.value,
    primaryShades,
  );

  static const Color secondary = Color(0xFF020105);
}
