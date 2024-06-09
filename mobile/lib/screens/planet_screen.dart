import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:mobile/enum/faction.dart';
import 'package:mobile/models/planet.dart';
import 'package:mobile/models/statistic.dart';
import 'package:mobile/screens/groups_screen.dart';
import 'package:mobile/services/planets_service.dart';
import 'package:mobile/utils/theme_colors.dart';
import 'package:mobile/widgets/components/countdown.dart';
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
      initialChildSize: 0.7,
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
          image: AssetImage(
            "assets/images/${planet.hasLiberation ? "liberation" : "defence"}.png",
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                planet.hasLiberation
                    ? AppLocalizations.of(context)!.liberation
                    : AppLocalizations.of(context)!.defence,
                style: const TextStyle(
                  fontFamily: "Arame",
                  fontSize: 20,
                ),
              ),
              if (planet.hasDefence)
                Countdown(
                  dateStart: planet.defence!.endAt,
                  style: TextStyle(
                    fontFamily: "Arame",
                    fontSize: Theme.of(context).textTheme.titleLarge!.fontSize,
                  ),
                ),
            ],
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
      _BoxDecoration(
        borderColor: Colors.grey,
        child: _BoxDecoration(
          child: CachedNetworkImage(
            imageUrl: planet.backgroundUrl,
            fit: BoxFit.cover,
            placeholder: (context, url) => SizedBox(
              width: double.infinity,
              height: 110,
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
        ),
      ),
      const SizedBox(height: 5),

      /// Planet progress bar for defence
      if (planet.hasDefence) _ProgressDefence(planet: planet),

      /// Planet progress bar for liberation
      if (planet.hasLiberation) _ProgressLiberation(planet: planet),

      /// Planet statistics
      // _PlanetViewStatistic(statistic: planet.statistic),
    ];

    return SingleChildScrollView(
      controller: scrollController,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
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

    titleRow = [
      ...titleRow,
      Row(
        children: [
          if (planet.players != null)
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
                  progress: 0.57,
                  daysLeft: 3,
                ),
              );
            },
            icon: const Icon(Icons.info),
          )
        ],
      ),
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: titleRow,
    );
  }
}

class _EventHeader extends StatelessWidget {
  final Widget child;
  final AssetImage image;

  const _EventHeader({required this.child, required this.image});

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
          Expanded(child: child),
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
    Color color = planet.owner.color;
    String logo = planet.owner.logo;
    String controlTitle = planet.owner.translatedName(context);

    if (planet.hasDefence) {
      color = planet.defence!.enemyFaction.color;
      logo = planet.defence!.enemyFaction.logo;
      controlTitle = planet.defence!.enemyFaction.translatedName(context);
    }

    return Row(
      children: [
        Image(
          image: AssetImage(logo),
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
                decorationColor: color,
              ),
            ),
            Text(
              "$controlTitle control".toUpperCase(),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontFamily: "Arame",
                fontSize: Theme.of(context).textTheme.titleSmall!.fontSize,
                color: color,
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

  const _ProgressDefence({required this.planet});

  @override
  Widget build(BuildContext context) {
    return _BoxDecoration(
      borderColor: Colors.grey,
      child: Column(
        children: [
          _BoxDecoration(
            borderColor: planet.defence!.enemyFaction.color,
            child: Container(
              color: Colors.black,
              child: Row(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(right: 5),
                      child: Column(
                        children: [
                          _ProgressBar(
                            value: planet.defence!.getHealthPercentage(),
                            faction: planet.owner,
                          ),
                          const SizedBox(
                            height: 5,
                          ),
                          _ProgressBar(
                            value: planet.defence!.getEnemyHealthPercentage(),
                            faction: planet.defence!.enemyFaction,
                            angle: 45.0,
                          ),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.only(left: 5),
                    decoration: const BoxDecoration(
                      border: Border(
                        left: BorderSide(color: Colors.grey, width: 3),
                      ),
                    ),
                    child: Column(
                      children: [
                        _FactionImpactPercentage(
                          value: planet.defence!.getRequiredImpactPerHour(),
                          faction: planet.owner,
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        _FactionImpactPercentage(
                          value: planet.defence!.getEnemyImpactPerHour(),
                          faction: planet.defence!.enemyFaction,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(
            height: 5,
          ),
          _BoxDecoration(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  children: [
                    _TextArame(
                      text:
                          "${(planet.defence!.getHealthPercentage() * 100).toStringAsFixed(3)}%",
                      size: "medium",
                    ),
                    const SizedBox(
                      width: 5,
                    ),
                    const _TextArame(
                      text: "defenced",
                      size: "medium",
                      letterSpacing: 0,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(
            height: 5,
          ),
          _BoxDecoration(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _FactionImpactPercentage(
                      value: planet.defence!.getRequiredImpactPerHour(),
                      faction: planet.owner,
                    ),
                    _TextArame(
                      color: planet.owner.color,
                      text: " required",
                      size: "medium",
                      letterSpacing: 0,
                    ),
                  ],
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}

/// Progress bar for liberation
class _ProgressLiberation extends StatelessWidget {
  final Planet planet;

  const _ProgressLiberation({required this.planet});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _BoxDecoration(
          borderColor: Colors.grey,
          child: Column(
            children: [
              _BoxDecoration(
                borderColor: planet.owner.color,
                child: Container(
                  color: planet.owner.color,
                  child: _ProgressBar(
                    value: planet.getLiberationPercentage(),
                    faction: Faction.humans,
                    backgroundColor: planet.owner.color,
                    reverse: planet.liberation!.impactPerHour < 0,
                  ),
                ),
              ),
              const SizedBox(
                height: 5,
              ),
              _BoxDecoration(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Row(
                      children: [
                        _TextArame(
                          text:
                              "${(planet.getLiberationPercentage() * 100).toStringAsFixed(3)}%",
                          size: "medium",
                        ),
                        const SizedBox(
                          width: 5,
                        ),
                        const _TextArame(
                          text: "liberated",
                          size: "medium",
                          letterSpacing: 0,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(
          height: 5,
        ),
        _BoxDecoration(
          borderColor: Colors.grey,
          child: Row(
            children: [
              Expanded(
                child: _BoxDecoration(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _FactionImpactPercentage(
                        value: planet.liberation!.impactPerHour +
                            planet.liberation!.regenerationPerHour,
                        faction: Faction.humans,
                      ),
                      _FactionImpactPercentage(
                        value: planet.liberation!.regenerationPerHour,
                        faction: planet.owner,
                        precision: 1,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(
                width: 5,
              ),
              _BoxDecoration(
                  child:
                      _ImpactPerHour(value: planet.liberation!.impactPerHour))
            ],
          ),
        )
      ],
    );
  }
}

class _FactionImpactPercentage extends StatelessWidget {
  final double value;

  final Faction faction;

  final int precision;

  const _FactionImpactPercentage(
      {required this.value, required this.faction, this.precision = 3});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Image(
          image: AssetImage(faction.logo),
          width: 25,
          height: 25,
        ),
        const SizedBox(width: 5),
        _TextArame(
          text: "${value.toStringAsFixed(precision)}%",
          color: faction.color,
          size: "medium",
        ),
        Text(
          "/h",
          style: TextStyle(
            color: faction.color,
            fontWeight: FontWeight.bold,
            fontSize: Theme.of(context).textTheme.titleMedium!.fontSize,
          ),
        ),
      ],
    );
  }
}

class _ImpactPerHour extends StatelessWidget {
  final double value;

  const _ImpactPerHour({required this.value});

  @override
  Widget build(BuildContext context) {
    List<Widget> status = [];

    Color color = Colors.green;
    IconData icon = Icons.trending_up;

    if (value < 0) {
      color = Colors.red;
      icon = Icons.trending_down;
    }

    status = [
      Text(
        "$value%",
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontFamily: "Arame",
          letterSpacing: 1.5,
          fontSize: Theme.of(context).textTheme.titleMedium!.fontSize,
        ),
      ),
      Text(
        "/h",
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.5,
          fontSize: Theme.of(context).textTheme.titleMedium!.fontSize,
        ),
      ),
    ];

    if (value == 0) {
      color = Colors.grey;
      icon = Icons.trending_flat;

      status = [
        Text(
          "Holding",
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
            fontFamily: "Arame",
            fontSize: Theme.of(context).textTheme.titleSmall!.fontSize,
          ),
        ),
      ];
    }

    return Tooltip(
      message: "Liberation change per hour",
      child: Row(
        children: [
          ...status,
          Icon(
            icon,
            color: color,
          ),
        ],
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

class _BoxDecoration extends StatelessWidget {
  final Widget child;

  final Color borderColor;

  const _BoxDecoration({required this.child, this.borderColor = Colors.white});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black,
        border: Border.all(
          color: borderColor,
          width: 2,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(5),
        child: child,
      ),
    );
  }
}

class _ProgressBar extends StatelessWidget {
  final double value;

  final double angle;

  final bool reverse;

  final Faction faction;

  final Color backgroundColor;

  const _ProgressBar({
    required this.value,
    required this.faction,
    this.angle = -45.0,
    this.backgroundColor = Colors.black,
    this.reverse = false,
  });

  @override
  Widget build(BuildContext context) {
    Color color = faction.color;
    Color secondaryColor = faction.secondaryColor;

    /// Step down the color for the secondary color
    if (faction == Faction.humans) {
      color = faction.secondaryColor;
      secondaryColor = const Color(0xff07daff);
    }
    return Container(
      color: backgroundColor,
      width: double.infinity,
      child: StripedProgressIndicator(
        value: value,
        stripeWidth: 20,
        stripeSpacing: 15,
        stripeColor: reverse ? ThemeColors.darken(color, 20) : color,
        backgroundColor:
            reverse ? ThemeColors.darken(secondaryColor, 20) : secondaryColor,
        angle: angle,
        reverse: reverse,
      ),
    );
  }
}

class _TextArame extends StatelessWidget {
  final String text;

  final Color color;

  final String size;

  final double letterSpacing;

  const _TextArame(
      {required this.text,
      this.color = Colors.white,
      this.size = "large",
      this.letterSpacing = 1.5});

  @override
  Widget build(BuildContext context) {
    double? fontSize = Theme.of(context).textTheme.titleLarge!.fontSize ?? 20;

    if (size == "medium") {
      fontSize = Theme.of(context).textTheme.titleMedium!.fontSize ?? 16;
    }

    if (size == "small") {
      fontSize = Theme.of(context).textTheme.titleSmall!.fontSize ?? 14;
    }

    return Text(
      text,
      style: TextStyle(
        fontWeight: FontWeight.bold,
        fontFamily: "Arame",
        color: color,
        letterSpacing: letterSpacing,
        fontSize: fontSize,
      ),
    );
  }
}
