import 'dart:developer';

import 'package:eventflux/eventflux.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:http/http.dart';
import 'package:intl/intl.dart';
import 'package:mobile/screens/planet_screen.dart';
import 'package:mobile/services/events_service.dart';
import 'package:mobile/widgets/components/helldivers_list_item.dart';
import 'package:mobile/widgets/components/spinner.dart';
import 'package:mobile/widgets/components/text_style_arame.dart';
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
          return _View(
            initialEvents: snapshot.data!,
          );
        },
      ),
    );
  }
}

class _View extends StatefulWidget {
  final Events initialEvents;

  const _View({
    required this.initialEvents,
  });

  @override
  State<_View> createState() => _ViewState();
}

class _ViewState extends State<_View> {
  late EventFlux _eventsStream;

  late Events events;

  @override
  void initState() {
    super.initState();
    initEvents();
    startStream();
  }

  @override
  void dispose() {
    try {
      _eventsStream.disconnect();
    } on ClientException catch (e) {
      log('Error while disconnecting events stream');
      log(e.message.toString());
    } finally {
      super.dispose();
    }
  }

  void initEvents() {
    events = widget.initialEvents;
  }

  void startStream() {
    _eventsStream = EventsService.getEventsStream(
      onSuccess: (newEvents) {
        setState(() {
          events = newEvents;
        });
      },
      onError: (error) {
        log('Error while getting events stream');
        log(error.message.toString());
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final TextStyle textStyle = TextStyle(
      color: Colors.white,
      fontSize: Theme.of(context).textTheme.titleMedium?.fontSize,
    );
    final List<Widget> eventsList = [
      // Title
      ListTile(
        title: Text(
          AppLocalizations.of(context)!.events,
          style: TextStyleArame(
            fontSize: Theme.of(context).textTheme.headlineMedium!.fontSize,
          ),
        ),
      ),
      // Defences
      ListTile(
        title: Text(
          "${AppLocalizations.of(context)!.eventsOngoingDefences} (${events.defences.length})",
          style: const TextStyleArame(),
        ),
      ),
      ...events.defences.map(
        (defence) => HelldiversListTile(
          title: Text(
            defence.planet!.name,
            style: textStyle,
          ),
          trailing: RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: NumberFormat.compact().format(defence.players),
                  style: textStyle,
                ),
                const WidgetSpan(
                  alignment: PlaceholderAlignment.baseline,
                  baseline: TextBaseline.alphabetic,
                  child: SizedBox(width: 10),
                ),
                const WidgetSpan(
                  child: Image(
                    image: AssetImage("assets/images/helldivers-player.png"),
                    width: 20,
                    height: 20,
                  ),
                ),
              ],
            ),
          ),
          onTap: () {
            PlanetScreen.show(
              context,
              defence.planet!.id,
            );
          },
        ),
      ),
      if (events.defences.isEmpty)
        ListTile(
            title: Text(
          AppLocalizations.of(context)!.eventsNoDefences,
          textAlign: TextAlign.center,
        )),
      const SizedBox(height: 0),
      // Liberations
      ListTile(
        title: Text(
          "${AppLocalizations.of(context)!.eventsOngoingLiberations} (${events.liberations.length})",
          style: const TextStyleArame(),
        ),
      ),
      ...events.liberations.map(
        (liberation) => HelldiversListTile(
          title: Text(
            liberation.planet!.name,
            style: textStyle,
          ),
          trailing: RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: NumberFormat.compact().format(liberation.players),
                  style: textStyle,
                ),
                const WidgetSpan(
                  alignment: PlaceholderAlignment.baseline,
                  baseline: TextBaseline.alphabetic,
                  child: SizedBox(width: 10),
                ),
                const WidgetSpan(
                  child: Image(
                    image: AssetImage("assets/images/helldivers-player.png"),
                    width: 20,
                    height: 20,
                  ),
                ),
              ],
            ),
          ),
          onTap: () {
            PlanetScreen.show(
              context,
              liberation.planet!.id,
            );
          },
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

    return ListView.separated(
      separatorBuilder: (context, index) => const SizedBox(height: 16),
      itemCount: eventsList.length,
      itemBuilder: (context, index) {
        return eventsList[index];
      },
    );
  }
}
