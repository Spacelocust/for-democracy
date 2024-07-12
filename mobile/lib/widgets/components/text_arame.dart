import 'package:flutter/material.dart';

class TextArame extends StatelessWidget {
  final String text;

  final Color color;

  final String size;

  final double letterSpacing;

  const TextArame({
    super.key,
    required this.text,
    this.color = Colors.white,
    this.size = "large",
    this.letterSpacing = 1.5,
  });

  @override
  Widget build(BuildContext context) {
    double? fontSize = Theme.of(context).textTheme.titleLarge!.fontSize ?? 20;

    if (size == "medium") {
      fontSize = Theme.of(context).textTheme.titleMedium!.fontSize ?? 16;
    }

    if (size == "small") {
      fontSize = Theme.of(context).textTheme.titleSmall!.fontSize ?? 14;
    }

    return Text(
      text,
      style: TextStyle(
        fontWeight: FontWeight.bold,
        fontFamily: "Arame",
        color: color,
        letterSpacing: letterSpacing,
        fontSize: fontSize,
      ),
    );
  }
}
