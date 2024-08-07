import 'package:flutter/material.dart';

abstract final class ThemeColors {
  static const Color softPrimary = Color(0xfffbf38c);

  static const Color defaultPrimary = Color(0xfff2bb13);

  static const Color hardPrimary = Color(0xff905010);

  static const MaterialColor primary = MaterialColor(
    0xfff2bb13,
    {
      50: Color(0xfffffeeb),
      100: Color(0xfffdfac8),
      200: softPrimary,
      300: Color(0xfffae74f),
      400: Color(0xfff8d827),
      500: defaultPrimary,
      600: Color(0xffd69109),
      700: Color(0xffb2680b),
      800: hardPrimary,
      900: Color(0xff774210),
    },
  );

  static const Color surface = Color(0xff171717);

  static Color darken(Color c, [int percent = 10]) {
    assert(1 <= percent && percent <= 100);

    var f = 1 - percent / 100;

    return Color.fromARGB(
      c.alpha,
      (c.red * f).toInt(),
      (c.green * f).toInt(),
      (c.blue * f).toInt(),
    );
  }

  static Color lighten(Color c, [int percent = 10]) {
    assert(1 <= percent && percent <= 100);

    var p = percent / 100;

    return Color.fromARGB(
      c.alpha,
      c.red + ((255 - c.red) * p).toInt(),
      c.green + ((255 - c.green) * p).toInt(),
      c.blue + ((255 - c.blue) * p).toInt(),
    );
  }
}
