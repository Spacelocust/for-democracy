import 'package:flutter/material.dart';

abstract final class ThemeColors {
  static int defaultPrimary = 0xfff2bb13;

  static MaterialColor primary = MaterialColor(
    defaultPrimary,
    {
      50: const Color(0xfffffeeb),
      100: const Color(0xfffdfac8),
      200: const Color(0xfffbf38c),
      300: const Color(0xfffae74f),
      400: const Color(0xfff8d827),
      500: Color(defaultPrimary),
      600: const Color(0xffd69109),
      700: const Color(0xffb2680b),
      800: const Color(0xff905010),
      900: const Color(0xff774210),
    },
  );

  static Color surface = const Color(0xff171717);
}
