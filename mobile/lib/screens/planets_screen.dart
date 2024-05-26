import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:mobile/models/planet.dart';
import 'package:mobile/services/planets_service.dart';
import 'package:mobile/services/secure_storage_service.dart';
import 'package:mobile/widgets/base/list_item.dart';
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
    return Container(
      padding: const EdgeInsets.only(
        top: 16,
        left: 8,
        right: 8,
        bottom: 16,
      ),
      child: DefaultTabController(
        length: 2,
        child: Column(
          children: [
            TabBar(
              tabs: [
                Tab(text: AppLocalizations.of(context)!.map),
                Tab(text: AppLocalizations.of(context)!.list),
              ],
            ),
            const SizedBox(height: 16),
            FutureBuilder<List<Planet>>(
              future: _planetsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  // Loading state
                  return Center(
                    child: CircularProgressIndicator(
                      semanticsLabel:
                          AppLocalizations.of(context)!.planetsScreenLoading,
                    ),
                  );
                } else if (snapshot.hasError) {
                  // Error state
                  return Center(
                    child: Column(
                      children: [
                        Text(
                          AppLocalizations.of(context)!.planetsScreenError,
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
                  // Success state
                  final planets = snapshot.data!.toList()
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

                  return Expanded(
                    child: TabBarView(
                      children: [
                        const Text('TODO: Map view'),
                        ListView.builder(
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
                      ],
                    ),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
