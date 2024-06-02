import 'package:flutter/material.dart';

abstract final class ThemeColors {
  static const int defaultPrimary = 0xfff2bb13;

  static const MaterialColor primary = MaterialColor(
    defaultPrimary,
    {
      50: Color(0xfffffeeb),
      100: Color(0xfffdfac8),
      200: Color(0xfffbf38c),
      300: Color(0xfffae74f),
      400: Color(0xfff8d827),
      500: Color(defaultPrimary),
      600: Color(0xffd69109),
      700: Color(0xffb2680b),
      800: Color(0xff905010),
      900: Color(0xff774210),
    },
  );

  static const Color surface = Color(0xff171717);
}
