import 'package:app/services/events_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class EventsDatatable extends StatefulWidget {
  const EventsDatatable({super.key});

  @override
  State<EventsDatatable> createState() => _EventsDatatableState();
}

class _EventsDatatableState extends State<EventsDatatable> {
  late Future<Events> _eventsFuture;

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
    final l10n = AppLocalizations.of(context)!;

    final columns = {
      'defences': [
        l10n.id,
        l10n.planet,
        l10n.health,
        l10n.players,
        l10n.helldiversID,
        l10n.enemyFaction,
        l10n.startAt,
        l10n.endAt,
        l10n.maxHealth,
        l10n.impactPerHour,
      ],
      'liberations': [
        l10n.id,
        l10n.planet,
        l10n.health,
        l10n.players,
        l10n.helldiversID,
        l10n.regenerationPerHour,
      ],
    };

    return FutureBuilder<Events>(
      future: _eventsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        }

        if (snapshot.hasError || !snapshot.hasData) {
          return Text('Error: ${snapshot.error}');
        }

        return Column(
          children: [
            DataTable(
              columns: [
                ...columns["defences"]!.map(
                  (column) => DataColumn(
                    label: Expanded(
                      child: Text(
                        column,
                        style: const TextStyle(fontStyle: FontStyle.italic),
                      ),
                    ),
                  ),
                ),
              ],
              rows: [
                ...snapshot.data!.defences.map((defence) {
                  return DataRow(cells: [
                    DataCell(Text(defence.id.toString())),
                    DataCell(Text(defence.planet!.name)),
                    DataCell(Text(defence.health.toString())),
                    DataCell(Text(defence.players.toString())),
                    DataCell(Text(defence.helldiversID.toString())),
                    DataCell(Text(defence.enemyFaction.name)),
                    DataCell(Text(defence.startAt.toString())),
                    DataCell(Text(defence.endAt.toString())),
                    DataCell(Text(defence.maxHealth.toString())),
                    DataCell(Text(defence.impactPerHour.toString())),
                  ]);
                })
              ],
            ),
            DataTable(
              columns: [
                ...columns["liberations"]!.map(
                  (column) => DataColumn(
                    label: Expanded(
                      child: Text(
                        column,
                        style: const TextStyle(fontStyle: FontStyle.italic),
                      ),
                    ),
                  ),
                ),
              ],
              rows: [
                ...snapshot.data!.liberations.map((user) {
                  return DataRow(cells: [
                    DataCell(Text(user.id.toString())),
                    DataCell(Text(user.planet!.name)),
                    DataCell(Text(user.health.toString())),
                    DataCell(Text(user.players.toString())),
                    DataCell(Text(user.helldiversID.toString())),
                    DataCell(Text(user.regenerationPerHour.toString())),
                  ]);
                })
              ],
            ),
          ],
        );
      },
    );
  }
}
