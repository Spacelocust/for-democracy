import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:mobile/models/planet.dart';
import 'package:mobile/services/planets_service.dart';

class PlanetsScreen extends StatefulWidget {
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
    return FutureBuilder<List<Planet>>(
      future: _planetsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(
              semanticsLabel: AppLocalizations.of(context)!.planetScreenLoading,
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
          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(snapshot.data![index].name),
              );
            },
          );
        }
      },
    );
  }
}
