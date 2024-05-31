import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/enum/faction.dart';
import 'package:mobile/models/planet.dart';
import 'package:mobile/screens/planet_screen.dart';
import 'package:mobile/widgets/base/list_item.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class PlanetListItem extends ListItem {
  const PlanetListItem({super.key, required this.planet});

  final Planet planet;

  bool get hasLiberation => planet.liberation != null;

  bool get hasDefence => planet.defence != null;

  Widget getTitle(BuildContext context) {
    Text title = Text(
      planet.name,
      style: Theme.of(context).textTheme.titleMedium,
    );

    if (!hasLiberation && !hasDefence) {
      return title;
    }

    List<Widget> children = [];

    if (hasLiberation) {
      children.add(Text(
        AppLocalizations.of(context)!.planetLiberationInProgress,
        style: Theme.of(context).textTheme.bodySmall,
      ));
    } else if (hasDefence) {
      children.add(Text(
        AppLocalizations.of(context)!.planetDefenceInProgress,
        style: Theme.of(context).textTheme.bodySmall,
      ));
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

    if (hasDefence) {
      players = planet.defence!.players;
    } else if (hasLiberation) {
      players = planet.liberation!.players;
    }

    if (players != null) {
      return Text(
        AppLocalizations.of(context)!.playerCount(players),
        style: Theme.of(context).textTheme.bodySmall,
      );
    }

    return null;
  }

  Text getSubtitle(BuildContext context) {
    String subtitle = AppLocalizations.of(context)!.planetUnderControl;

    if (hasDefence) {
      subtitle =
          "${AppLocalizations.of(context)!.planetUnderAttack(planet.defence!.enemyFaction.translatedName(context))} ${AppLocalizations.of(context)!.planetLongPressSeeEvent}";
    } else if (hasLiberation) {
      subtitle =
          "${AppLocalizations.of(context)!.planetBeingLiberated(planet.owner.translatedName(context))} ${AppLocalizations.of(context)!.planetLongPressSeeEvent}";
    } else if (planet.owner != Faction.humans) {
      subtitle = AppLocalizations.of(context)!
          .planetOccupied(planet.owner.translatedName(context));
    }

    return Text(subtitle);
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CachedNetworkImage(
        imageUrl: planet.imageUrl,
        imageBuilder: (context, imageProvider) => CircleAvatar(
          backgroundImage: imageProvider,
        ),
        placeholder: (context, url) => const CircleAvatar(
          child: CircularProgressIndicator(),
        ),
        errorWidget: (context, url, error) => const CircleAvatar(
          child: Icon(Icons.error),
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
