import 'package:app/widgets/datatable/events.dart';
import 'package:app/widgets/datatable/features.dart';
import 'package:app/widgets/datatable/groups.dart';
import 'package:app/widgets/datatable/users.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class HomeScreen extends StatelessWidget {
  static const String routePath = '/home';

  static const String routeName = 'home';

  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final tabs = [
      {
        'label': AppLocalizations.of(context)!.features,
        'icon': Icons.settings,
        'widget': const FeaturesDatatable(),
      },
      {
        'label': AppLocalizations.of(context)!.events,
        'icon': Icons.event,
        'widget': const EventsDatatable(),
      },
      {
        'label': AppLocalizations.of(context)!.groups,
        'icon': Icons.group,
        'widget': const GroupsDatatable(),
      },
      {
        'label': AppLocalizations.of(context)!.users,
        'icon': Icons.person,
        'widget': const UsersDatatable(),
      },
      {
        'label': AppLocalizations.of(context)!.biomes,
        'icon': Icons.landscape,
        'widget': const Placeholder(),
      },
      {
        'label': AppLocalizations.of(context)!.defences,
        'icon': Icons.shield,
        'widget': const Placeholder(),
      },
      {
        'label': AppLocalizations.of(context)!.effects,
        'icon': Icons.star,
        'widget': const Placeholder(),
      },
      {
        'label': AppLocalizations.of(context)!.liberations,
        'icon': Icons.flag,
        'widget': const Placeholder(),
      },
      {
        'label': AppLocalizations.of(context)!.planets,
        'icon': Icons.circle,
        'widget': const Placeholder(),
      },
      {
        'label': AppLocalizations.of(context)!.sectors,
        'icon': Icons.map,
        'widget': const Placeholder(),
      },
      {
        'label': AppLocalizations.of(context)!.statistics,
        'icon': Icons.bar_chart,
        'widget': const Placeholder(),
      },
      {
        'label': AppLocalizations.of(context)!.waypoints,
        'icon': Icons.gps_fixed,
        'widget': const Placeholder(),
      },
    ];

    return DefaultTabController(
      initialIndex: 0,
      length: tabs.length,
      child: Scaffold(
        appBar: AppBar(
          bottom: TabBar(
            tabs: [
              ...tabs.map(
                (tab) => Tooltip(
                  message: tab['label'] as String,
                  child: Icon(tab['icon'] as IconData),
                ),
              ),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            ...tabs.map(
              (tab) => SingleChildScrollView(
                padding: const EdgeInsets.all(8.0),
                child: Center(child: tab['widget'] as Widget),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
