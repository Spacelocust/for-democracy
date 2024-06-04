import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:mobile/models/defence.dart';
import 'package:mobile/models/liberation.dart';
import 'package:mobile/models/planet.dart';
import 'package:mobile/models/statistic.dart';
import 'package:mobile/screens/groups_screen.dart';
import 'package:mobile/services/planets_service.dart';
import 'package:mobile/widgets/components/progress.dart';
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

/// Planet screen
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
    List<Widget> columns = [];

    /// Display event header if the planet has liberation or defence
    if (planet.hasLiberationOrDefence) {
      columns = [
        ...columns,
        const SizedBox(height: columnSpacing),
        _EventHeader(
          text: planet.hasLiberation
              ? AppLocalizations.of(context)!.liberation
              : AppLocalizations.of(context)!.defence,
          image: AssetImage(
            "assets/images/${planet.hasLiberation ? "liberation" : "defence"}.png",
          ),
        ),
        const SizedBox(height: columnSpacing),
      ];
    }

    /// Title of the planet view
    columns = [
      ...columns,
      _PlanetViewTitle(planet: planet),
    ];

    /// Display chips if the planet has effects
    if (planet.effects.isNotEmpty) {
      columns = [
        ...columns,
        const SizedBox(height: columnSpacing),
        _PlanetViewChips(planet: planet),
        const SizedBox(height: columnSpacing),
      ];
    }

    columns = [
      ...columns,

      /// Background image of the planet
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

      /// Planet progress bar for defence
      if (planet.defence != null)
        _ProgressDefence(defence: planet.defence!, planet: planet),

      /// Planet progress bar for liberation
      if (planet.liberation != null)
        _ProgressLiberation(liberation: planet.liberation!, planet: planet),

      /// Planet statistics
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

/// Title of the planet view
class _PlanetViewTitle extends StatelessWidget {
  final Planet planet;

  const _PlanetViewTitle({required this.planet});

  @override
  Widget build(BuildContext context) {
    List<Widget> titleRow = [
      _TitlePlanet(planet: planet),
    ];

    if (planet.players != null) {
      titleRow = [
        ...titleRow,
        Row(
          children: [
            Text(
              AppLocalizations.of(context)!.playerCount(planet.players!),
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(width: 10),
            const Image(
              image: AssetImage("assets/images/helldivers-player.png"),
              width: 20,
              height: 20,
            ),
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

class _EventHeader extends StatelessWidget {
  final String text;
  final AssetImage image;

  const _EventHeader({required this.text, required this.image});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(4, 5, 4, 5),
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.white,
        ),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment(-0.7, 0),
          stops: [0.0, 0.5, 0.5, 1],
          colors: [
            Color(0xff2e2e2e),
            Color(0xff2e2e2e),
            Color(0xff282828),
            Color(0xff282828),
          ],
          transform: GradientRotation(0.5),
          tileMode: TileMode.repeated,
        ),
      ),
      child: Row(
        children: [
          Image(
            image: image,
            width: 20,
            height: 20,
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: const TextStyle(
              fontFamily: "Arame",
              fontSize: 20,
            ),
          ),
        ],
      ),
    );
  }
}

/// Title of the planet
class _TitlePlanet extends StatelessWidget {
  final Planet planet;

  const _TitlePlanet({required this.planet});

  @override
  Widget build(BuildContext context) {
    return Row(
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
    );
  }
}

/// Chips of the planet view (effects)
class _PlanetViewChips extends StatelessWidget {
  final Planet planet;

  const _PlanetViewChips({required this.planet});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      children: planet.effects.fold(
        [],
        (previousValue, effect) {
          if (effect.name != "None") {
            return previousValue
              ..add(
                Tooltip(
                  message: effect.description,
                  child: Chip(
                    avatar: Image(
                      image: AssetImage(
                          "assets/images/effects/${effect.name.toLowerCase().replaceAll(' ', '_')}.png"),
                    ),
                    label: Text(effect.name),
                    padding: const EdgeInsets.all(4),
                  ),
                ),
              );
          }
          return [];
        },
      ),
    );
  }
}

/// Progress bar for defence
class _ProgressDefence extends StatelessWidget {
  final Planet planet;
  final Defence defence;

  const _ProgressDefence({required this.planet, required this.defence});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black,
        border: Border.all(
          color: defence.enemyFaction.color,
          width: 2,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(5),
        child: Column(
          children: [
            Container(
              color: Colors.black,
              width: double.infinity,
              child: const StripedProgressIndicator(
                value: 1,
                stripeWidth: 20,
                stripeSpacing: 15,
                stripeColor: Color(0xff219ffb),
                backgroundColor: Color(0xff07daff),
                angle: -45.0,
              ),
            ),
            const SizedBox(height: 5),
            Container(
              color: Colors.black,
              width: double.infinity,
              child: const StripedProgressIndicator(
                value: 0.57,
                stripeWidth: 20,
                stripeSpacing: 15,
                stripeColor: Color(0xffffc000),
                backgroundColor: Color(0xffc18700),
                angle: 45.0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Progress bar for liberation
class _ProgressLiberation extends StatelessWidget {
  final Planet planet;
  final Liberation liberation;

  const _ProgressLiberation({required this.planet, required this.liberation});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black,
        border: Border.all(
          color: planet.owner.color,
          width: 2,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(5),
        child: Column(
          children: [
            Container(
              color: planet.owner.color,
              width: double.infinity,
              child: StripedProgressIndicator(
                value: liberation.getHealthPercentage(planet.maxHealth!),
                stripeWidth: 20,
                stripeSpacing: 15,
                stripeColor: const Color(0xff219ffb),
                backgroundColor: const Color(0xff07daff),
                angle: -45.0,
              ),
            ),
          ],
        ),
      ),
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
