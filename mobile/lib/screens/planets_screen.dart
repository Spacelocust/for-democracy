import 'dart:developer';
import 'package:eventflux/eventflux.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:http/http.dart';
import 'package:mobile/enum/feature.dart';
import 'package:mobile/models/planet.dart';
import 'package:mobile/services/feature_service.dart';
import 'package:mobile/services/planets_service.dart';
import 'package:mobile/widgets/base/list_item.dart';
import 'package:mobile/widgets/components/spinner.dart';
import 'package:mobile/widgets/layout/error_message.dart';
import 'package:mobile/widgets/planet/galaxy_map.dart';
import 'package:mobile/widgets/planet/list_item.dart';
import 'package:mobile/widgets/sector/list_item.dart';

class PlanetsScreen extends StatefulWidget {
  static const String routePath = '/planets';

  static const String routeName = 'planets';

  const PlanetsScreen({super.key});

  @override
  State<PlanetsScreen> createState() => _PlanetsScreenState();
}

class _PlanetsScreenState extends State<PlanetsScreen> {
  static const double yPadding = 16;

  static const double xPadding = 8;

  Future<List<Feature>>? _featuresFuture;
  Future<List<Planet>>? _planetsFuture;

  @override
  void initState() {
    super.initState();
    fetchFeatures();
    fetchPlanets();
  }

  void fetchFeatures() {
    setState(() {
      _featuresFuture = FeatureService.getFeatures();
    });
  }

  void fetchPlanets() {
    setState(() {
      _planetsFuture = PlanetsService.getPlanets();
    });
  }

  @override
  Widget build(BuildContext context) {
    // For testing features

    final features = [Feature.map, Feature.planetList];

    if (features.isEmpty) {
      return const Placeholder();
    }

    var tabLabels = [];

    if (features.contains(Feature.map)) {
      tabLabels.add(AppLocalizations.of(context)!.map);
    }

    if (features.contains(Feature.planetList)) {
      tabLabels.add(AppLocalizations.of(context)!.list);
    }

    return DefaultTabController(
      length: tabLabels.length,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.only(
              top: yPadding,
              left: xPadding,
              right: xPadding,
              bottom: yPadding,
            ),
            child: TabBar(
              tabs: [
                ...tabLabels.map((label) => Tab(text: label)),
              ],
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Planet>>(
              future: _planetsFuture,
              builder: (context, snapshot) {
                // Loading state
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Spinner(
                    semanticsLabel:
                        AppLocalizations.of(context)!.planetsScreenLoading,
                  );
                }

                // Error state
                if (snapshot.hasError || !snapshot.hasData) {
                  return ErrorMessage(
                    onPressed: () {
                      fetchPlanets();
                    },
                    errorMessage:
                        AppLocalizations.of(context)!.planetsScreenError,
                  );
                }

                return _View(
                  initialPlanets: snapshot.data!,
                  // Success state
                  final planets = context.read<PlanetsState>().planets.isEmpty
                      ? snapshot.data!
                      : context.read<PlanetsState>().planets
                    ..sort((a, b) => a.sector.name.compareTo(b.sector.name));
                  int? lastSectorId;

                  final listItems = planets.fold<List<ListItem>>(
                    [],
                    (previousValue, planet) {
                      if (lastSectorId != planet.sector.id) {
                        lastSectorId = planet.sector.id;

                        previousValue.add(
                          SectorListItem(sector: planet.sector),
                        );
                      }

                      previousValue.add(
                        PlanetListItem(planet: planet),
                      );

                      return previousValue;
                    },
                  );

                  var tabChildren = [];

                  if (features.contains(Feature.map)) {
                    tabChildren.add(GalaxyMap(
                      planets: planets,
                    ));
                  }

                  if (features.contains(Feature.planetList)) {
                    tabChildren.add(Container(
                      padding: const EdgeInsets.only(
                        left: xPadding,
                        right: xPadding,
                        bottom: yPadding,
                      ),
                      child: ListView.separated(
                        separatorBuilder: (context, index) => const SizedBox(
                          height: 8,
                        ),
                        itemCount: listItems.length,
                        itemBuilder: (context, index) {
                          final item = listItems[index];

                          return item.build(context);
                        },
                      ),
                    ));
                  }

                  return TabBarView(
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      ...tabChildren,
                      if (listItems.isEmpty)
                        ListTile(
                          title: Text(
                            AppLocalizations.of(context)!.planetsNoPlanets,
                            textAlign: TextAlign.center,
                          ),
                        ),
                    ],
                  );
                ),
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _View extends StatefulWidget {
  final List<Planet> initialPlanets;

  const _View({
    required this.initialPlanets,
  });

  @override
  State<_View> createState() => _ViewState();
}

class _ViewState extends State<_View> {
  late EventFlux _planetsStream;

  late List<Planet> planets;

  @override
  void initState() {
    super.initState();
    initPlanets();
    startStream();
  }

  @override
  void dispose() {
    try {
      _planetsStream.disconnect();
    } on ClientException catch (e) {
      log('Error while disconnecting planets stream');
      log(e.message.toString());
    } finally {
      super.dispose();
    }
  }

  void initPlanets() {
    planets = widget.initialPlanets;
  }

  void startStream() {
    _planetsStream = PlanetsService.getPlanetsStream(
      onSuccess: (newPlanets) {
        setState(() {
          planets = newPlanets;
        });
      },
      onError: (error) {
        log('Error while getting planet stream');
        log(error.message.toString());
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final sortedPlanets = planets
      ..sort((a, b) => a.sector.name.compareTo(b.sector.name));
    int? lastSectorId;

    final listItems = sortedPlanets.fold<List<ListItem>>(
      [],
      (previousValue, planet) {
        if (lastSectorId != planet.sector.id) {
          lastSectorId = planet.sector.id;

          previousValue.add(
            SectorListItem(sector: planet.sector),
          );
        }

        previousValue.add(
          PlanetListItem(planet: planet),
        );

        return previousValue;
      },
    );

    return TabBarView(
      physics: const NeverScrollableScrollPhysics(),
      children: [
        GalaxyMap(
          planets: sortedPlanets,
        ),
        Container(
          padding: const EdgeInsets.only(
            left: _PlanetsScreenState.xPadding,
            right: _PlanetsScreenState.xPadding,
            bottom: _PlanetsScreenState.yPadding,
          ),
          child: ListView.separated(
            separatorBuilder: (context, index) => const SizedBox(
              height: 8,
            ),
            itemCount: listItems.length,
            itemBuilder: (context, index) {
              final item = listItems[index];

              return item.build(context);
            },
          ),
        ),
        if (listItems.isEmpty)
          ListTile(
            title: Text(
              AppLocalizations.of(context)!.planetsNoPlanets,
              textAlign: TextAlign.center,
            ),
          ),
      ],
    );
  }
}
