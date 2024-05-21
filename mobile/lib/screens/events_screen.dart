import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class EventsScreen extends StatefulWidget {
  static const String routeName = '/events';

  const EventsScreen({super.key});

  @override
  State<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(AppLocalizations.of(context)!.events),
    );
  }
}
