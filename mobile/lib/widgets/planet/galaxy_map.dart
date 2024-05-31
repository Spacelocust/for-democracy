import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mobile/models/planet.dart';
import 'package:mobile/utils/galaxy_map_painter.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:mobile/utils/canvas.dart';
import 'dart:ui' as ui;
import 'package:mobile/utils/planets.dart';

class GalaxyMap extends StatefulWidget {
  static const String imageUrl = 'galaxy_map.svg';
  static const double zoomFactor = 1.5;
  static const double marginFactor = 0.1;

  final List<Planet> planets;

  const GalaxyMap({super.key, required this.planets});

  @override
  State<GalaxyMap> createState() => _GalaxyMapState();
}

class _GalaxyMapState extends State<GalaxyMap> {
  Future<PictureInfo>? backgroundFuture;

  Future<Map<int, ui.Image>>? planetImagesFuture;

  @override
  void initState() {
    super.initState();
    fetchCanvasBackgroundImage();
    fetchCanvasPlanetImages();
  }

  void fetchCanvasBackgroundImage() async {
    setState(() {
      backgroundFuture = loadSvg(GalaxyMap.imageUrl);
    });
  }

  void fetchCanvasPlanetImages() async {
    setState(() {
      planetImagesFuture = getPlanetsImagesFuture(widget.planets);
    });
  }

  Future<dynamic>? get future {
    if (backgroundFuture == null || planetImagesFuture == null) {
      return null;
    }

    return Future.wait<dynamic>([
      backgroundFuture!,
      planetImagesFuture!,
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: future,
      builder: (context, snapshot) {
        // Loading state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(
              semanticsLabel: AppLocalizations.of(context)!.galaxyMapLoading,
            ),
          );
        }

        // Error state
        // TODO: make this a component ?
        if (snapshot.hasError || !snapshot.hasData) {
          return Center(
            child: Column(
              children: [
                Text(
                  AppLocalizations.of(context)!.galaxyMapError,
                  style: const TextStyle(color: Colors.red),
                ),
                TextButton(
                  onPressed: () => fetchCanvasBackgroundImage(),
                  child: Text(AppLocalizations.of(context)!.retry),
                ),
              ],
            ),
          );
        }

        PictureInfo pictureInfo = snapshot.data[0];
        Map<int, ui.Image> planetImages = snapshot.data[1];
        Size canvasSize = pictureInfo.size;
        double margin = canvasSize.width * GalaxyMap.marginFactor;

        return InteractiveViewer(
          transformationController: getTransformationControllerForSize(
            canvasSize,
            zoomFactor: GalaxyMap.zoomFactor,
            margin: margin,
          ),
          boundaryMargin: EdgeInsets.all(margin),
          minScale: 0.1,
          maxScale: 5,
          constrained: false,
          child: GestureDetector(
            onTap: () => print('Tapped'),
            child: CustomPaint(
              size: canvasSize,
              isComplex: false,
              painter: GalaxyMapPainter(
                pictureInfo: pictureInfo,
              ),
              foregroundPainter: GalaxyMapPlanetsPainter(
                planets: widget.planets,
                planetImages: planetImages,
              ),
            ),
          ),
        );
      },
    );
  }
}
