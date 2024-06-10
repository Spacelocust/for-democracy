import 'package:flutter/material.dart';

class Spinner extends StatelessWidget {
  const Spinner({super.key, required this.semanticsLabel});

  final String semanticsLabel;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Stack(
        children: [
          CircularProgressIndicator(
            semanticsLabel: semanticsLabel,
            strokeAlign: 3,
            color: Colors.white,
            backgroundColor: Colors.white.withOpacity(0.5),
          ),
          const CircularProgressIndicator(
            strokeWidth: 3,
          ),
        ],
      ),
    );
  }
}
