import 'dart:developer';
import 'package:eventflux/eventflux.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:http/http.dart';
import 'package:mobile/models/planet.dart';
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

  Future<List<Planet>>? _planetsFuture;

  @override
  void initState() {
    super.initState();
    fetchPlanets();
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

                // Success state
                return _View(
                  initialPlanets: snapshot.data!,
                );
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
