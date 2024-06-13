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

  static Color darken(Color c, [int percent = 10]) {
    assert(1 <= percent && percent <= 100);
    var f = 1 - percent / 100;
    return Color.fromARGB(
      c.alpha,
      (c.red * f).round(),
      (c.green * f).round(),
      (c.blue * f).round(),
    );
  }

  static Color lighten(Color c, [int percent = 10]) {
    assert(1 <= percent && percent <= 100);
    var p = percent / 100;
    return Color.fromARGB(
      c.alpha,
      c.red + ((255 - c.red) * p).round(),
      c.green + ((255 - c.green) * p).round(),
      c.blue + ((255 - c.blue) * p).round(),
    );
  }
}
