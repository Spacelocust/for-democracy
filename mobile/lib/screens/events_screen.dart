import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:mobile/services/events_service.dart';

class EventsScreen extends StatefulWidget {
  static const String routePath = '/events';
  static const String routeName = 'events';

  const EventsScreen({super.key});

  @override
  State<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen> {
  Future<Events>? _eventsFuture;

  @override
  void initState() {
    super.initState();
    fetchEvents();
  }

  void fetchEvents() {
    setState(() {
      _eventsFuture = EventsService.getEvents();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: FutureBuilder<Events>(
        future: _eventsFuture,
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
                    AppLocalizations.of(context)!.eventsScreenError,
                    style: const TextStyle(color: Colors.red),
                  ),
                  TextButton(
                    onPressed: () => fetchEvents(),
                    child: Text(AppLocalizations.of(context)!.retry),
                  ),
                ],
              ),
            );
          } else {
            // Success state
            final events = snapshot.data;

            if (events == null) {
              return const Center();
            }

            return ListView.builder(
              itemCount: 2,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(
                    left: 8,
                    right: 8,
                  ),
                  child: Column(children: [
                    // Defences
                    ListTile(
                      title: Text('Ongoing defenses',
                          style: Theme.of(context).textTheme.headlineLarge),
                    ),
                    ...events.defences.map(
                      (defence) => ListTile(
                        title: Text(defence.planet?.name ?? ''),
                      ),
                    ),
                    // Liberations
                    ListTile(
                      title: Text('Ongoing liberations',
                          style: Theme.of(context).textTheme.headlineLarge),
                    ),
                    ...events.liberations.map(
                      (liberation) => ListTile(
                        title: Text(liberation.planet?.name ?? ''),
                      ),
                    ),
                  ]),
                );
              },
            );
          }
        },
      ),
    );
  }
}
