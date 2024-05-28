import 'package:flutter/material.dart';

/// Square avatar widget.
class SquareAvatar extends StatelessWidget {
  final Image avatar;

  final void Function()? onTap;

  final double size;

  const SquareAvatar(
      {super.key, required this.avatar, this.size = 40, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: DecoratedBox(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: avatar.image,
          ),
          borderRadius: BorderRadius.circular(5.0),
        ),
        child: SizedBox(width: size, height: size),
      ),
    );
  }
}
