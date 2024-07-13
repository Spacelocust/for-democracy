import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/enum/faction.dart';
import 'package:mobile/models/planet.dart';
import 'package:mobile/screens/planet_screen.dart';
import 'package:mobile/utils/theme_colors.dart';
import 'package:mobile/widgets/base/list_item.dart';

class PlanetListItem extends ListItem {
  const PlanetListItem({
    super.key,
    required this.planet,
  });

  final Planet planet;

  Decoration get decoration {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(100),
      boxShadow: [
        BoxShadow(
          color: planet.color.withOpacity(0.6),
          blurRadius: 8,
          spreadRadius: 4,
        ),
      ],
    );
  }

  Widget getTitle(BuildContext context) {
    Text title = Text(
      planet.name,
      style: Theme.of(context).textTheme.titleMedium,
    );

    if (!planet.hasLiberationOrDefence) {
      return title;
    }

    List<Widget> children = [];

    if (planet.hasLiberation) {
      children.add(
        Text(
          AppLocalizations.of(context)!.planetLiberationInProgress,
          style: Theme.of(context).textTheme.bodySmall!.copyWith(
                color: ThemeColors.primary,
              ),
        ),
      );
    } else if (planet.hasDefence) {
      children.add(
        Text(
          AppLocalizations.of(context)!.planetDefenceInProgress,
        ),
      );
    }

    children.add(title);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: children,
    );
  }

  Text? getTrailing(BuildContext context) {
    int? players;

    if (planet.hasDefence) {
      players = planet.defence!.players;
    } else if (planet.hasLiberation) {
      players = planet.liberation!.players;
    }

    if (players != null) {
      return Text(
        AppLocalizations.of(context)!.playerCount(players),
      );
    }

    return null;
  }

  Text getSubtitle(BuildContext context) {
    String subtitle = AppLocalizations.of(context)!
        .planetUnderControl(planet.owner.translatedName(context));

    if (planet.hasDefence) {
      subtitle =
          "${AppLocalizations.of(context)!.planetUnderAttack(planet.defence!.enemyFaction.translatedName(context))} ${AppLocalizations.of(context)!.planetLongPressSeeEvent}";
    } else if (planet.hasLiberation) {
      subtitle =
          "${AppLocalizations.of(context)!.planetBeingLiberated(planet.owner.translatedName(context))} ${AppLocalizations.of(context)!.planetLongPressSeeEvent}";
    } else if (planet.owner != Faction.humans) {
      subtitle = AppLocalizations.of(context)!
          .planetOccupied(planet.owner.translatedName(context));
    }

    return Text(
      subtitle,
      style: Theme.of(context).textTheme.bodySmall,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        clipBehavior: Clip.hardEdge,
        decoration: decoration,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(100),
          child: CachedNetworkImage(
            width: 55,
            height: 55,
            imageUrl: planet.imageUrl,
            placeholder: (context, url) => const SizedBox(
              width: 55,
              height: 55,
            ),
            errorWidget: (context, url, error) => const Icon(Icons.error),
          ),
        ),
      ),
      title: getTitle(context),
      trailing: getTrailing(context),
      subtitle: getSubtitle(context),
      onTap: () => context.go(context.namedLocation(
        PlanetScreen.routeName,
        pathParameters: {'planetId': planet.id.toString()},
      )),
    );
  }
}
