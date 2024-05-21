import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobile/enum/faction.dart';
import 'package:mobile/models/planet.dart';
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
    if (hasLiberation) {
      return Text(
        "${NumberFormat.decimalPattern().format(planet.liberation!.players)} players",
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
      title: getTitle(context),
      trailing: getTrailing(context),
      subtitle: getSubtitle(context),
    );
  }
}
