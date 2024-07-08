import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/screens/planet_screen.dart';
import 'package:mobile/services/events_service.dart';
import 'package:mobile/widgets/components/list_item.dart';
import 'package:mobile/widgets/components/spinner.dart';
import 'package:mobile/widgets/layout/error_message.dart';

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
            return Spinner(
              semanticsLabel: AppLocalizations.of(context)!.eventsScreenLoading,
            );
          }

          // Error state
          if (snapshot.hasError || !snapshot.hasData) {
            return ErrorMessage(
              onPressed: fetchEvents,
              errorMessage: AppLocalizations.of(context)!.eventsScreenError,
            );
          }

          // Success state
          final events = snapshot.data!;
          final List<Widget> eventsList = [
            // Defences
            ListTile(
              title: Text(
                AppLocalizations.of(context)!.eventsOngoingDefences,
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            ...events.defences.map(
              (defence) => GestureDetector(
                onTap: () {
                  context.go(
                    context.namedLocation(
                      PlanetScreen.routeName,
                      pathParameters: {
                        'planetId': defence.planet!.id.toString()
                      },
                    ),
                  );
                },
                child: ListItem(
                  title: defence.planet!.name,
                ),
              ),
            ),
            if (events.defences.isEmpty)
              ListTile(
                  title: Text(
                AppLocalizations.of(context)!.eventsNoDefences,
                textAlign: TextAlign.center,
              )),
            // Liberations
            ListTile(
              title: Text(
                AppLocalizations.of(context)!.eventsOngoingLiberations,
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            ...events.liberations.map(
              (liberation) => GestureDetector(
                onTap: () {
                  context.go(
                    context.namedLocation(
                      PlanetScreen.routeName,
                      pathParameters: {
                        'planetId': liberation.planet!.id.toString()
                      },
                    ),
                  );
                },
                child: ListItem(
                  title: liberation.planet!.name,
                ),
              ),
            ),
            if (events.liberations.isEmpty)
              ListTile(
                title: Text(
                  AppLocalizations.of(context)!.eventsNoLiberations,
                  textAlign: TextAlign.center,
                ),
              ),
          ];

          return ListView.builder(
            itemCount: eventsList.length,
            itemBuilder: (context, index) {
              return eventsList[index];
            },
          );
        },
      ),
    );
  }
}
