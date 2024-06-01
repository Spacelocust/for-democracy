import 'package:avatar_glow/avatar_glow.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/models/planet.dart';
import 'package:mobile/screens/planet_screen.dart';
import 'package:mobile/utils/galaxy_map_painter.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:mobile/utils/canvas.dart';
import 'package:shimmer/shimmer.dart';

class GalaxyMap extends StatefulWidget {
  /// The URL of the SVG image to be used as the background of the galaxy map.
  final String imageUrl;

  /// The minimum zoom level of the galaxy map.
  final double minZoom;

  /// The maximum zoom level of the galaxy map.
  final double maxZoom;

  /// The initial zoom level of the galaxy map.
  final double zoomFactor;

  /// The margins to add around the galaxy map (as a percentage of the canvas size).
  final double marginFactor;

  /// The size of the planets on the galaxy map.
  final double planetSize;

  /// The list of planets to display on the galaxy map.
  final List<Planet> planets;

  const GalaxyMap({
    super.key,
    required this.planets,
    this.imageUrl = 'galaxy_map.svg',
    this.minZoom = 0.1,
    this.maxZoom = 5,
    this.zoomFactor = 1.5,
    this.marginFactor = 0.1,
    this.planetSize = 5,
  });

  @override
  State<GalaxyMap> createState() => _GalaxyMapState();
}

class _GalaxyMapState extends State<GalaxyMap> {
  Future<PictureInfo>? _canvasBackgroundImage;

  @override
  void initState() {
    super.initState();
    fetchCanvasBackgroundImage();
  }

  void fetchCanvasBackgroundImage() async {
    setState(() {
      _canvasBackgroundImage = loadSvg(widget.imageUrl);
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _canvasBackgroundImage,
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
                  onPressed: () {
                    fetchCanvasBackgroundImage();
                  },
                  child: Text(AppLocalizations.of(context)!.retry),
                ),
              ],
            ),
          );
        }

        PictureInfo pictureInfo = snapshot.data!;
        Size canvasSize = pictureInfo.size;
        double margin = canvasSize.width * widget.marginFactor;
        double toX = canvasSize.width / 2;
        double toY = canvasSize.height / 2;
        double planetHalfSize = widget.planetSize / 2;

        return InteractiveViewer(
          transformationController: getTransformationControllerForSize(
            canvasSize,
            zoomFactor: widget.zoomFactor,
            margin: margin,
          ),
          boundaryMargin: EdgeInsets.all(margin),
          minScale: widget.minZoom,
          maxScale: widget.maxZoom,
          constrained: false,
          child: Stack(
            children: <Widget>[
              CustomPaint(
                size: canvasSize,
                isComplex: true,
                painter: GalaxyMapPainter(
                  pictureInfo: pictureInfo,
                ),
              ),
            ].followedBy(
              widget.planets.map(
                (planet) {
                  Widget cachedImage = CachedNetworkImage(
                    imageUrl: planet.imageUrl,
                    fit: BoxFit.cover,
                    height: widget.planetSize,
                    width: widget.planetSize,
                    placeholder: (context, url) => SizedBox(
                      width: widget.planetSize,
                      height: widget.planetSize,
                      child: Shimmer.fromColors(
                        baseColor: Colors.grey.shade200,
                        highlightColor: Colors.yellow,
                        child: Container(
                          color: Colors.white,
                        ),
                      ),
                    ),
                    errorWidget: (context, url, error) => const Icon(
                      Icons.error,
                    ),
                  );

                  if (planet.hasLiberationOrDefence) {
                    Color color =
                        planet.hasLiberation ? Colors.green : Colors.red;

                    cachedImage = AvatarGlow(
                      glowColor: color,
                      glowRadiusFactor: 3,
                      child: cachedImage,
                    );
                  }

                  return Positioned(
                    left: planet.scaleXTo(toX) - planetHalfSize,
                    bottom: planet.scaleYTo(toY) - planetHalfSize,
                    child: GestureDetector(
                      onTap: () {
                        context.go(context.namedLocation(
                          PlanetScreen.routeName,
                          pathParameters: {'planetId': planet.id.toString()},
                        ));
                      },
                      child: cachedImage,
                    ),
                  );
                },
              ),
            ).toList(),
          ),
        );
      },
    );
  }
}
