import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mobile/models/stratagem.dart';
import 'package:mobile/widgets/components/helldivers_box_decoration.dart';

class StratagemImage extends StatelessWidget {
  final Stratagem stratagem;

  final Color borderColor;

  const StratagemImage({
    super.key,
    required this.stratagem,
    this.borderColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return HelldiversBoxDecoration(
      borderColor: borderColor,
      child: SvgPicture.network(
        stratagem.imageURL,
        width: 20,
        height: 20,
        semanticsLabel: stratagem.name,
        colorFilter: const ColorFilter.mode(
          Colors.white,
          BlendMode.srcIn,
        ),
      ),
    );
  }
}
