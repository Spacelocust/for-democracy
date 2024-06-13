import 'dart:developer';

import 'package:eventflux/eventflux.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:mobile/models/planet.dart';
import 'package:mobile/services/planets_service.dart';
import 'package:mobile/states/planets_state.dart';
import 'package:mobile/widgets/base/list_item.dart';
import 'package:mobile/widgets/layout/error_message.dart';
import 'package:mobile/widgets/planet/galaxy_map.dart';
import 'package:mobile/widgets/planet/list_item.dart';
import 'package:mobile/widgets/sector/list_item.dart';
import 'package:provider/provider.dart';

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

  Future<List<Planet>>? _planetsFuture;
  FlutterError? _error;

  late EventFlux _streamPlanets;

  @override
  void initState() {
    super.initState();
    fetchPlanets();

    startStream();
  }

  @override
  void dispose() {
    _streamPlanets.disconnect();
    super.dispose();
  }

  void startStream() {
    /// Reset error state
    setState(() {
      _error = null;
    });

    _streamPlanets = PlanetsService.getPlanetsStream(
      onSuccess: (planets) {
        context.read<PlanetsState>().setPlanets(planets);
      },
      onError: (error) {
        log('Error: $error');
        setState(() {
          _error = FlutterError(error.toString());
        });
      },
    );
  }

  void fetchPlanets() {
    setState(() {
      _planetsFuture = PlanetsService.getPlanets();
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
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
                Tab(text: AppLocalizations.of(context)!.map),
                Tab(text: AppLocalizations.of(context)!.list),
              ],
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Planet>>(
              future: _planetsFuture,
              builder: (context, snapshot) {
                // Loading state
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(
                      semanticsLabel:
                          AppLocalizations.of(context)!.planetsScreenLoading,
                    ),
                  );
                }

                // Error state
                if (snapshot.hasError || !snapshot.hasData || _error != null) {
                  return ErrorMessage(
                    onPressed: () {
                      fetchPlanets();
                      startStream();
                    },
                    errorMessage:
                        AppLocalizations.of(context)!.planetsScreenError,
                  );
                }

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

                return TabBarView(
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    GalaxyMap(
                      planets: planets,
                    ),
                    Container(
                      padding: const EdgeInsets.only(
                        left: xPadding,
                        right: xPadding,
                        bottom: yPadding,
                      ),
                      child: ListView.builder(
                        itemCount: listItems.length,
                        itemBuilder: (context, index) {
                          final item = listItems[index];

                          if (item is PlanetListItem) {
                            return Padding(
                              padding: const EdgeInsets.only(
                                left: 8,
                                right: 8,
                              ),
                              child: item.build(context),
                            );
                          }

                          return item.build(context);
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
