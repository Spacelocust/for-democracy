import 'package:flutter/material.dart';

class HelldiversBoxDecoration extends StatelessWidget {
  final Widget child;

  final Color borderColor;

  const HelldiversBoxDecoration({
    super.key,
    required this.child,
    this.borderColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black,
        border: Border.all(
          color: borderColor,
          width: 2,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(5),
        child: child,
      ),
    );
  }
}
