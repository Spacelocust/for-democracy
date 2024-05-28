import 'package:flutter/material.dart';
import 'package:mobile/utils/galaxy_map_painter.dart';
import 'dart:ui' as ui;

import 'package:mobile/utils/images.dart';

class GalaxyMap extends StatefulWidget {
  static const String imageUrl = 'galaxy_map.png';

  static const Size canvasSize = Size(750, 750);

  const GalaxyMap({super.key});

  @override
  State<GalaxyMap> createState() => _GalaxyMapState();
}

class _GalaxyMapState extends State<GalaxyMap> {
  Future<ui.Image>? _imageFuture;

  @override
  void initState() {
    super.initState();
    fetchCanvasImage();
  }

  void fetchCanvasImage() async {
    setState(() {
      _imageFuture = loadImage(GalaxyMap.imageUrl);
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: GalaxyMap.canvasSize.height,
      width: GalaxyMap.canvasSize.width,
      child: FutureBuilder(
        future: _imageFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError || !snapshot.hasData) {
            return const Center(
              child: Text('Error loading galaxy map'),
            );
          }

          return CustomPaint(
            size: GalaxyMap.canvasSize,
            isComplex: false,
            painter: GalaxyMapPainter(
              image: snapshot.data!,
              imageSize: GalaxyMap.canvasSize,
            ),
          );
        },
      ),
    );
  }
}
