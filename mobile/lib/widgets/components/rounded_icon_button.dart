import 'package:flutter/material.dart';
import 'package:mobile/utils/theme_colors.dart';

class RoundedIconButton extends StatelessWidget {
  final Widget child;

  final Color color;

  const RoundedIconButton({
    super.key,
    required this.child,
    this.color = ThemeColors.defaultPrimary,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Ink(
        decoration: ShapeDecoration(
          color: color,
          shape: const CircleBorder(),
        ),
        child: child,
      ),
    );
  }
}
