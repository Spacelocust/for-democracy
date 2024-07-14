import 'package:avatar_glow/avatar_glow.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mobile/enum/faction.dart';
import 'package:mobile/models/planet.dart';
import 'package:mobile/screens/planet_screen.dart';
import 'package:mobile/states/galaxy_map_zoom_state.dart';
import 'package:mobile/utils/canvas.dart';
import 'package:mobile/utils/galaxy_map_painter.dart';
import 'package:mobile/utils/images.dart';
import 'package:mobile/utils/theme_colors.dart';
import 'package:mobile/widgets/components/spinner.dart';
import 'package:mobile/widgets/layout/error_message.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

class GalaxyMap extends StatefulWidget {
  static const double initialZoomFactor = 1.5;

  /// The URL of the SVG image to be used as the background of the galaxy map.
  final String imageUrl;

  /// The minimum zoom level of the galaxy map.
  final double minZoom;

  /// The maximum zoom level of the galaxy map.
  final double maxZoom;

  /// The margins to add around the galaxy map (as a percentage of the canvas size).
  final double marginFactor;

  /// The size of the planets on the galaxy map based on [initialZoomFactor]. Will scale depending on the zoom level.
  final double planetBaseSize;

  /// The radius factor to use for the glow effect around planets (when they are being liberated or defended).
  final double planetGlowRadiusFactor;

  /// The list of planets to display on the galaxy map.
  final List<Planet> planets;

  const GalaxyMap({
    super.key,
    this.imageUrl = 'galaxy_map.svg',
    this.minZoom = 0.1,
    this.maxZoom = 5,
    this.marginFactor = 0.1,
    this.planetBaseSize = 5,
    this.planetGlowRadiusFactor = 5,
    required this.planets,
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

  void onZoomChanged(
    BuildContext context,
    TransformationController transformationController,
  ) {
    context
        .read<GalaxyMapZoomState>()
        .setZoomFactor(transformationController.value.getMaxScaleOnAxis());
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _canvasBackgroundImage,
      builder: (context, snapshot) {
        // Loading state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Spinner(
            semanticsLabel: AppLocalizations.of(context)!.galaxyMapLoading,
          );
        }

        // Error state
        if (snapshot.hasError || !snapshot.hasData) {
          return ErrorMessage(
            onPressed: fetchCanvasBackgroundImage,
            errorMessage: AppLocalizations.of(context)!.galaxyMapError,
          );
        }

        PictureInfo pictureInfo = snapshot.data!;
        Size canvasSize = pictureInfo.size;
        double margin = canvasSize.width * widget.marginFactor;
        double toX = canvasSize.width / 2;
        double toY = canvasSize.height / 2;
        TransformationController transformationController =
            getTransformationControllerForSize(
          canvasSize,
          zoomFactor: context.read<GalaxyMapZoomState>().zoomFactor,
          margin: margin,
        );

        transformationController.addListener(() {
          onZoomChanged(context, transformationController);
        });

        return InteractiveViewer(
          transformationController: transformationController,
          boundaryMargin: EdgeInsets.all(margin),
          minScale: widget.minZoom,
          maxScale: widget.maxZoom,
          constrained: false,
          child: _GalaxyMapView(
            galaxyMapPainter: CustomPaint(
              size: canvasSize,
              isComplex: false,
              painter: GalaxyMapPainter(
                pictureInfo: pictureInfo,
              ),
              foregroundPainter: GalaxyMapPlanetsWaypointsPainter(
                planets: widget.planets,
              ),
            ),
            planets: widget.planets,
            planetBaseSize: widget.planetBaseSize,
            planetGlowRadiusFactor: widget.planetGlowRadiusFactor,
            toX: toX,
            toY: toY,
          ),
        );
      },
    );
  }
}

class _GalaxyMapView extends StatelessWidget {
  final CustomPaint galaxyMapPainter;

  final List<Planet> planets;

  final double planetBaseSize;

  final double planetGlowRadiusFactor;

  final double toX;

  final double toY;

  const _GalaxyMapView({
    required this.galaxyMapPainter,
    required this.planets,
    required this.planetBaseSize,
    required this.planetGlowRadiusFactor,
    required this.toX,
    required this.toY,
  });

  @override
  Widget build(BuildContext context) {
    double planetSize = planetBaseSize *
        context.watch<GalaxyMapZoomState>().zoomFactor.clamp(1.0, 2.0);
    double planetHalfSize = planetSize / 2;

    return Stack(
      children: <Widget>[
        galaxyMapPainter,
      ].followedBy(
        planets.map(
          (planet) {
            Widget cachedImage = Container(
              clipBehavior: Clip.hardEdge,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(100),
                boxShadow: [
                  BoxShadow(
                    color: planet.color,
                    blurRadius: 0.6,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: CachedNetworkImage(
                imageUrl: planet.imageUrl,
                fit: BoxFit.cover,
                height: planetSize,
                width: planetSize,
                placeholder: (context, url) => SizedBox(
                  width: planetSize,
                  height: planetSize,
                  child: Shimmer.fromColors(
                    baseColor: Colors.grey.shade200,
                    highlightColor: ThemeColors.primary,
                    child: Container(
                      color: Colors.white,
                    ),
                  ),
                ),
                errorWidget: (context, url, error) => const Icon(
                  Icons.error,
                ),
              ),
            );

            if (planet.hasLiberationOrDefence) {
              final Color glowColor = planet.hasLiberation
                  ? Faction.humans.color
                  : planet.defence!.enemyFaction.color;

              cachedImage = AvatarGlow(
                glowColor: glowColor,
                glowRadiusFactor: planetGlowRadiusFactor,
                child: cachedImage,
              );
            }

            return Positioned(
              left: planet.scaleXTo(toX) - planetHalfSize,
              bottom: planet.scaleYTo(toY) - planetHalfSize,
              child: Semantics(
                button: true,
                label: planet.name,
                child: GestureDetector(
                  onTap: () {
                    PlanetScreen.show(
                      context,
                      planet.id,
                    );
                  },
                  child: cachedImage,
                ),
              ),
            );
          },
        ),
      ).toList(),
    );
  }
}
