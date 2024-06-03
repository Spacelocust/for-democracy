import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:mobile/models/planet.dart';
import 'package:mobile/models/statistic.dart';
import 'package:mobile/screens/groups_screen.dart';
import 'package:mobile/services/planets_service.dart';
import 'package:mobile/widgets/layout/error_message.dart';
import 'package:shimmer/shimmer.dart';

class PlanetScreen extends StatefulWidget {
  static const String routePath = ":planetId";

  static const String routeName = 'planet';

  final int planetId;

  const PlanetScreen({super.key, required this.planetId});

  @override
  State<PlanetScreen> createState() => _PlanetScreenState();
}

class _PlanetScreenState extends State<PlanetScreen> {
  Future<Planet>? _planetFuture;

  @override
  void initState() {
    super.initState();
    fetchPlanet();
  }

  void fetchPlanet() {
    setState(() {
      _planetFuture = PlanetsService.getPlanet(widget.planetId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      maxChildSize: 0.8,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          padding: const EdgeInsets.only(
            top: 0,
            left: 16,
            right: 16,
            bottom: 0,
          ),
          child: FutureBuilder<Planet>(
            future: _planetFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                // Loading state
                return SingleChildScrollView(
                  controller: scrollController,
                  child: Center(
                    child: CircularProgressIndicator(
                      semanticsLabel:
                          AppLocalizations.of(context)!.planetScreenLoading,
                    ),
                  ),
                );
              }

              if (snapshot.hasError || !snapshot.hasData) {
                // Error state
                return SingleChildScrollView(
                  controller: scrollController,
                  child: ErrorMessage(
                    errorMessage:
                        AppLocalizations.of(context)!.planetScreenError,
                    onPressed: fetchPlanet,
                  ),
                );
              }

              // Success state
              Planet planet = snapshot.data!;
              List<Widget> planetViewChildren = [
                Padding(
                  padding: EdgeInsets.only(
                    bottom: planet.hasLiberationOrDefence ? 60 : 0,
                  ),
                  child: _PlanetScreenView(
                    planet: planet,
                    scrollController: scrollController,
                  ),
                ),
              ];

              if (planet.hasLiberationOrDefence) {
                planetViewChildren = [
                  ...planetViewChildren,
                  Positioned(
                    bottom: 5,
                    right: 5,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        // TODO: Proper links
                        OutlinedButton.icon(
                          onPressed: () => context.go(
                            context.namedLocation(GroupsScreen.routeName),
                          ),
                          label: Text(AppLocalizations.of(context)!.findGroup),
                          icon: const Icon(Icons.search),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton.icon(
                          onPressed: () => context.go(
                            context.namedLocation(GroupsScreen.routeName),
                          ),
                          label:
                              Text(AppLocalizations.of(context)!.createGroup),
                          icon: const Icon(Icons.add),
                        ),
                      ],
                    ),
                  ),
                ];
              }

              return Stack(
                children: planetViewChildren,
              );
            },
          ),
        );
      },
    );
  }
}

class _PlanetScreenView extends StatelessWidget {
  static const double columnSpacing = 16;

  final Planet planet;

  final ScrollController scrollController;

  const _PlanetScreenView({
    required this.planet,
    required this.scrollController,
  });

  // TODO: Add more information and complete this view
  @override
  Widget build(BuildContext context) {
    List<Widget> columns = [
      _PlanetViewTitle(planet: planet),
    ];

    if (planet.effects.isNotEmpty) {
      columns = [
        ...columns,
        _PlanetViewChips(planet: planet),
        const SizedBox(height: columnSpacing),
      ];
    }

    columns = [
      ...columns,
      CachedNetworkImage(
        imageUrl: planet.backgroundUrl,
        fit: BoxFit.cover,
        placeholder: (context, url) => SizedBox(
          width: double.infinity,
          height: 120,
          child: Shimmer.fromColors(
            baseColor: Colors.grey.shade200,
            highlightColor: Colors.yellow,
            child: Container(
              color: Colors.white,
            ),
          ),
        ),
        errorWidget: (context, url, error) => const Icon(Icons.error),
      ),
      const SizedBox(height: columnSpacing),
      _PlanetViewStatistic(statistic: planet.statistic),
    ];

    return SingleChildScrollView(
      controller: scrollController,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: columns,
      ),
    );
  }
}

class _PlanetViewTitle extends StatelessWidget {
  final Planet planet;

  const _PlanetViewTitle({required this.planet});

  @override
  Widget build(BuildContext context) {
    List<Widget> titleRow = [
      Row(
        children: [
          Image(
            image: AssetImage(planet.owner.logo),
            width: 40,
            height: 40,
          ),
          const SizedBox(width: 8),
          const Divider(
            color: Colors.white,
            height: 32,
            thickness: 2,
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                planet.name.toUpperCase(),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontFamily: "Arame",
                  fontSize: Theme.of(context).textTheme.headlineSmall!.fontSize,
                  decoration: TextDecoration.underline,
                  decorationThickness: 2.2,
                  decorationColor: planet.owner.color,
                ),
              ),
              Text(
                "${planet.owner.translatedName(context)} controlled"
                    .toUpperCase(),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontFamily: "Arame",
                  fontSize: Theme.of(context).textTheme.titleSmall!.fontSize,
                  color: planet.owner.color,
                ),
              )
            ],
          )
        ],
      ),
    ];

    if (planet.players != null) {
      titleRow = [
        ...titleRow,
        Row(
          children: [
            Text(
              AppLocalizations.of(context)!.playerCount(planet.players!),
            ),
            const SizedBox(width: 10),
            const Image(
              image: AssetImage("assets/images/helldivers-player.png"),
              width: 20,
              height: 20,
            ),
            IconButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => _PlanetEventDialog(
                    title: planet.hasLiberation
                        ? AppLocalizations.of(context)!.liberation
                        : AppLocalizations.of(context)!.defence,
                    eventId: planet.id,
                    // TODO: Proper values
                    progress: 0.57,
                    daysLeft: 3,
                  ),
                );
              },
              icon: const Icon(Icons.info),
            )
          ],
        )
      ];
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: titleRow,
    );
  }
}

class _PlanetViewChips extends StatelessWidget {
  final Planet planet;

  const _PlanetViewChips({required this.planet});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      children: planet.effects
          .map(
            (effect) => Chip(
              label: Text(effect.name),
              padding: const EdgeInsets.all(2),
            ),
          )
          .toList(),
    );
  }
}

class _PlanetEventDialog extends StatelessWidget {
  final String title;

  final int eventId;

  final double progress;

  final int daysLeft;

  const _PlanetEventDialog({
    required this.title,
    required this.eventId,
    required this.progress,
    required this.daysLeft,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: Text(AppLocalizations.of(context)!.planetEventProgress(
        progress,
        daysLeft,
      )),
      actions: <Widget>[
        TextButton(
          style: TextButton.styleFrom(
            textStyle: Theme.of(context).textTheme.labelLarge,
          ),
          child: Text(AppLocalizations.of(context)!.close),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        ElevatedButton.icon(
          style: TextButton.styleFrom(
            textStyle: Theme.of(context).textTheme.labelLarge,
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
          label: Text(AppLocalizations.of(context)!.viewEvent),
          icon: const Icon(Icons.search),
        ),
      ],
    );
  }
}

class _PlanetViewStatistic extends StatelessWidget {
  final Statistic statistic;

  const _PlanetViewStatistic({required this.statistic});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      children: [
        _PlanetStatisticItem(
          label: AppLocalizations.of(context)!.statisticMissionsWon,
          value: statistic.missionsWon,
        ),
        _PlanetStatisticItem(
          label: AppLocalizations.of(context)!.statisticMissionTime,
          value: statistic.missionTime,
          isHours: true,
        ),
        _PlanetStatisticItem(
          label: AppLocalizations.of(context)!.statisticBugKills,
          value: statistic.bugKills,
        ),
        _PlanetStatisticItem(
          label: AppLocalizations.of(context)!.statisticAutomatonKills,
          value: statistic.automatonKills,
        ),
        _PlanetStatisticItem(
          label: AppLocalizations.of(context)!.statisticIlluminateKills,
          value: statistic.illuminateKills,
        ),
        _PlanetStatisticItem(
          label: AppLocalizations.of(context)!.statisticBulletsFired,
          value: statistic.bulletsFired,
        ),
        _PlanetStatisticItem(
          label: AppLocalizations.of(context)!.statisticBulletsHit,
          value: statistic.bulletsHit,
        ),
        _PlanetStatisticItem(
          label: AppLocalizations.of(context)!.statisticTimePlayed,
          value: statistic.timePlayed,
          isHours: true,
        ),
        _PlanetStatisticItem(
          label: AppLocalizations.of(context)!.statisticDeaths,
          value: statistic.deaths,
        ),
        _PlanetStatisticItem(
          label: AppLocalizations.of(context)!.statisticRevives,
          value: statistic.revives,
        ),
      ],
    );
  }
}

class _PlanetStatisticItem extends StatelessWidget {
  final String label;

  final int value;

  final bool isHours;

  const _PlanetStatisticItem({
    required this.label,
    required this.value,
    this.isHours = false,
  });

  String valueText(BuildContext context) {
    if (!isHours) {
      return NumberFormat.compact().format(value);
    }

    return AppLocalizations.of(context)!.hours(value);
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 4,
      children: [
        Text(
          "$label :",
          style: Theme.of(context).textTheme.labelLarge,
        ),
        Text(
          valueText(context),
        ),
      ],
    );
  }
}
