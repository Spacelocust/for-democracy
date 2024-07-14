import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:mobile/enum/faction.dart';
import 'package:mobile/models/planet.dart';
import 'package:mobile/models/statistic.dart';
import 'package:mobile/screens/group_new_screen.dart';
import 'package:mobile/screens/groups_screen.dart';
import 'package:mobile/services/planets_service.dart';
import 'package:mobile/states/groups_filters_state.dart';
import 'package:mobile/utils/theme_colors.dart';
import 'package:mobile/widgets/components/countdown.dart';
import 'package:mobile/widgets/components/progress.dart';
import 'package:mobile/widgets/components/spinner.dart';
import 'package:mobile/widgets/components/text_style_arame.dart';
import 'package:mobile/widgets/layout/error_message.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

/// Note : This screen is not directly used in the GoRouter configuration. It is displayed using the [PlanetScreen.show] method.
class PlanetScreen extends StatefulWidget {
  final int planetId;

  const PlanetScreen({
    super.key,
    required this.planetId,
  });

  @override
  State<PlanetScreen> createState() => _PlanetScreenState();

  static void show(BuildContext context, int planetId) {
    showModalBottomSheet(
      context: context,
      enableDrag: true,
      isDismissible: true,
      isScrollControlled: true,
      showDragHandle: true,
      useRootNavigator: true,
      builder: (context) {
        return PlanetScreen(planetId: planetId);
      },
    );
  }
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
                  child: Spinner(
                    semanticsLabel:
                        AppLocalizations.of(context)!.planetScreenLoading,
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
                    width: MediaQuery.of(context).size.width,
                    bottom: 5,
                    right: 0,
                    child: SingleChildScrollView(
                      clipBehavior: Clip.none,
                      padding: const EdgeInsets.only(
                        left: 36,
                      ),
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          OutlinedButton.icon(
                            onPressed: () {
                              context
                                ..pop()
                                ..read<GroupsFiltersState>()
                                    .setPlanet(planet.id);

                              context.go(
                                context.namedLocation(GroupsScreen.routeName),
                              );
                            },
                            label:
                                Text(AppLocalizations.of(context)!.findGroup),
                            icon: const Icon(Icons.search),
                          ),
                          const SizedBox(width: 5),
                          ElevatedButton.icon(
                            onPressed: () {
                              context
                                ..pop()
                                ..go(
                                  context.namedLocation(
                                    GroupNewScreen.routeName,
                                    queryParameters: {
                                      "planetId": planet.id.toString(),
                                    },
                                  ),
                                );
                            },
                            label:
                                Text(AppLocalizations.of(context)!.createGroup),
                            icon: const Icon(Icons.add),
                          ),
                        ],
                      ),
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

  @override
  Widget build(BuildContext context) {
    List<Widget> columns = [];

    // Display event header if the planet has liberation or defence
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
                style: const TextStyleArame(),
              ),
              if (planet.hasDefence)
                Countdown(
                  dateStart: planet.defence!.endAt,
                  style: const TextStyleArame(),
                ),
            ],
          ),
        ),
        const SizedBox(height: columnSpacing),
      ];
    }

    // Title of the planet view
    columns = [
      ...columns,
      _PlanetViewTitle(planet: planet),
    ];

    // Display chips if the planet has effects
    if (planet.effects!.isNotEmpty) {
      columns = [
        ...columns,
        const SizedBox(height: columnSpacing),
        _PlanetViewChips(planet: planet),
        const SizedBox(height: columnSpacing),
      ];
    }

    columns = [
      ...columns,
      // Background image of the planet
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
                highlightColor: ThemeColors.primary,
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
      // Planet progress bar for defence
      if (planet.hasDefence) _ProgressDefence(planet: planet),
      // Planet progress bar for liberation
      if (planet.hasLiberation) _ProgressLiberation(planet: planet),
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
      SizedBox(
        width: MediaQuery.of(context).size.width / 3,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            if (planet.players != null)
              Row(
                children: [
                  Text(
                    NumberFormat.compact().format(planet.players!),
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
                    planet: planet,
                  ),
                );
              },
              icon: const Icon(
                Icons.insert_chart_outlined,
                size: 30,
              ),
            )
          ],
        ),
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
    String subTitle = AppLocalizations.of(context)!
        .planetUnderControl(planet.owner.translatedName(context))
        .toUpperCase();

    if (planet.hasDefence) {
      color = planet.defence!.enemyFaction.color;
      logo = planet.defence!.enemyFaction.logo;
      subTitle = AppLocalizations.of(context)!
          .planetUnderAttack(
              planet.defence!.enemyFaction.translatedName(context))
          .toUpperCase();
    }

    return Expanded(
      flex: 2,
      child: Row(
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
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  planet.name.toUpperCase(),
                  style: TextStyleArame(
                    fontSize:
                        Theme.of(context).textTheme.headlineSmall!.fontSize,
                    decoration: TextDecoration.underline,
                    decorationThickness: 2.2,
                    decorationColor: color,
                  ),
                ),
                Text(
                  subTitle,
                  softWrap: true,
                  style: TextStyleArame(
                    fontSize: Theme.of(context).textTheme.titleSmall!.fontSize,
                    color: color,
                  ),
                ),
              ],
            ),
          )
        ],
      ),
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
      children: planet.effects!.fold(
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
                        Tooltip(
                          message: AppLocalizations.of(context)!
                              .planetProgressPerHour,
                          child: _FactionImpactPercentage(
                            value: planet.defence!.impactPerHour,
                            faction: planet.owner,
                          ),
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        Tooltip(
                          message: AppLocalizations.of(context)!
                              .planetProgressPerHour,
                          child: _FactionImpactPercentage(
                            value: planet.defence!.getEnemyImpactPerHour(),
                            faction: planet.defence!.enemyFaction,
                          ),
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
                Tooltip(
                  message:
                      AppLocalizations.of(context)!.planetDefenceInProgress,
                  child: Row(
                    children: [
                      Text(
                        "${(planet.defence!.getHealthPercentage() * 100).toStringAsFixed(3)}%",
                        style: TextStyleArame(
                          fontSize:
                              Theme.of(context).textTheme.titleMedium!.fontSize,
                        ),
                      ),
                      const SizedBox(
                        width: 5,
                      ),
                      Text(
                        AppLocalizations.of(context)!.defended,
                        style: TextStyleArame(
                          fontSize:
                              Theme.of(context).textTheme.titleMedium!.fontSize,
                          letterSpacing: 0,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  width: 5,
                ),
                Icon(
                  size: 25,
                  planet.defence!.getHealthPercentage() >
                          planet.defence!.getEnemyHealthPercentage()
                      ? Icons.keyboard_double_arrow_up
                      : Icons.keyboard_double_arrow_down,
                  color: planet.defence!.getHealthPercentage() >
                          planet.defence!.getEnemyHealthPercentage()
                      ? Colors.green
                      : Colors.red,
                ),
                Text(
                  planet.defence!.getHealthPercentage() >
                          planet.defence!.getEnemyHealthPercentage()
                      ? AppLocalizations.of(context)!.winning
                      : AppLocalizations.of(context)!.losing,
                  style: TextStyleArame(
                    fontSize: Theme.of(context).textTheme.titleMedium!.fontSize,
                    color: planet.defence!.getHealthPercentage() >
                            planet.defence!.getEnemyHealthPercentage()
                        ? Colors.green
                        : Colors.red,
                    letterSpacing: 0,
                  ),
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
                Tooltip(
                  message: AppLocalizations.of(context)!
                      .planetProgressRequiredPerHour,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _FactionImpactPercentage(
                        value: planet.defence!.getRequiredImpactPerHour(),
                        faction: planet.owner,
                      ),
                      const SizedBox(
                        width: 5,
                      ),
                      Text(
                        AppLocalizations.of(context)!.required,
                        style: TextStyleArame(
                          fontSize:
                              Theme.of(context).textTheme.titleMedium!.fontSize,
                          color: planet.owner.color,
                          letterSpacing: 0,
                        ),
                      ),
                    ],
                  ),
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
                    Tooltip(
                      message: AppLocalizations.of(context)!
                          .planetLiberationInProgress,
                      child: Row(
                        children: [
                          Text(
                            "${(planet.getLiberationPercentage() * 100).toStringAsFixed(3)}%",
                            style: TextStyleArame(
                              fontSize: Theme.of(context)
                                  .textTheme
                                  .titleMedium!
                                  .fontSize,
                            ),
                          ),
                          const SizedBox(
                            width: 5,
                          ),
                          Text(
                            AppLocalizations.of(context)!.liberated,
                            style: TextStyleArame(
                              fontSize: Theme.of(context)
                                  .textTheme
                                  .titleMedium!
                                  .fontSize,
                              letterSpacing: 0,
                            ),
                          ),
                        ],
                      ),
                    )
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
                      Tooltip(
                        message:
                            AppLocalizations.of(context)!.planetProgressPerHour,
                        child: _FactionImpactPercentage(
                          value: planet.liberation!.impactPerHour +
                              planet.liberation!.regenerationPerHour,
                          faction: Faction.humans,
                        ),
                      ),
                      Tooltip(
                        message:
                            AppLocalizations.of(context)!.planetProgressPerHour,
                        child: _FactionImpactPercentage(
                          value: planet.liberation!.regenerationPerHour,
                          faction: planet.owner,
                          precision: 1,
                        ),
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
        Text(
          "${value.toStringAsFixed(precision)}%",
          style: TextStyleArame(
            fontSize: Theme.of(context).textTheme.titleMedium!.fontSize,
            color: faction.color,
          ),
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
        style: TextStyleArame(
          color: color,
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
          AppLocalizations.of(context)!.holding,
          style: TextStyleArame(
            color: color,
            fontSize: Theme.of(context).textTheme.titleSmall!.fontSize,
          ),
        ),
      ];
    }

    return Tooltip(
      message: AppLocalizations.of(context)!.planetLiberationPerHour,
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
  final Planet planet;

  const _PlanetEventDialog({
    required this.planet,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        AppLocalizations.of(context)!.planetStatistics,
        style: const TextStyleArame(),
      ),
      content: _PlanetViewStatistic(
        statistic: planet.statistic,
      ),
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
      ],
    );
  }
}

class _PlanetViewStatistic extends StatelessWidget {
  final Statistic statistic;

  const _PlanetViewStatistic({required this.statistic});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
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
