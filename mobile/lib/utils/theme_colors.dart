import 'package:flutter/material.dart';

abstract final class ThemeColors {
  static int defaultPrimary = 0xfffce92a;

  static MaterialColor primary = MaterialColor(
    defaultPrimary,
    {
      50: const Color(0xfffefee8),
      100: const Color(0xfffcfec3),
      200: const Color(0xfffffe89),
      300: const Color(0xfffef546),
      400: Color(defaultPrimary),
      500: const Color(0xffeccd06),
      600: const Color(0xffcba103),
      700: const Color(0xffa27306),
      800: const Color(0xff865a0d),
      900: const Color(0xff724a11),
    },
  );
}
