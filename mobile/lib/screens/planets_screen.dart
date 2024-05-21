import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:mobile/models/planet.dart';
import 'package:mobile/services/planets_service.dart';
import 'package:mobile/widgets/base/list_item.dart';
import 'package:mobile/widgets/planet/list_item.dart';
import 'package:mobile/widgets/sector/list_item.dart';

class PlanetsScreen extends StatefulWidget {
  static const String routeName = '/planets';

  const PlanetsScreen({super.key});

  @override
  State<PlanetsScreen> createState() => _PlanetsScreenState();
}

class _PlanetsScreenState extends State<PlanetsScreen> {
  Future<List<Planet>>? _planetsFuture;

  @override
  void initState() {
    super.initState();
    fetchPlanets();
  }

  void fetchPlanets() {
    setState(() {
      _planetsFuture = null;
    });

    _planetsFuture = PlanetsService.getPlanets();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Column(children: [
        TabBar(
          tabs: [
            Tab(text: AppLocalizations.of(context)!.map),
            Tab(text: AppLocalizations.of(context)!.list),
          ],
        ),
        FutureBuilder<List<Planet>>(
          future: _planetsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(
                  semanticsLabel:
                      AppLocalizations.of(context)!.planetScreenLoading,
                ),
              );
            } else if (snapshot.hasError) {
              return Center(
                child: Column(
                  children: [
                    Text(
                      AppLocalizations.of(context)!.planetScreenError,
                      style: const TextStyle(color: Colors.red),
                    ),
                    TextButton(
                      onPressed: () => fetchPlanets(),
                      child: Text(AppLocalizations.of(context)!.retry),
                    ),
                  ],
                ),
              );
            } else {
              final planets = snapshot.data!.toList()
                ..sort((a, b) => a.sector.name.compareTo(b.sector.name));
              int? lastSectorId;

              final listItems = planets.fold<List<ListItem>>(
                [],
                (previousValue, planet) {
                  if (lastSectorId != planet.sector.id) {
                    lastSectorId = planet.sector.id;

                    previousValue.add(SectorListItem(sector: planet.sector));
                  }

                  previousValue.add(PlanetListItem(planet: planet));

                  return previousValue;
                },
              );

              return Expanded(
                child: TabBarView(
                  children: [
                    const Text('TODO: Map view'),
                    ListView.builder(
                      itemCount: listItems.length,
                      itemBuilder: (context, index) {
                        final item = listItems[index];

                        return item.build(context);
                      },
                    ),
                  ],
                ),
              );
            }
          },
        ),
      ]),
    );
  }
}
