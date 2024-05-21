import 'package:flutter/material.dart';
import 'package:mobile/models/sector.dart';
import 'package:mobile/widgets/base/list_item.dart';

class SectorListItem extends ListItem {
  const SectorListItem({super.key, required this.sector});

  final Sector sector;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(
        sector.name,
        style: Theme.of(context).textTheme.headlineLarge,
      ),
      subtitle: const SizedBox.shrink(),
    );
  }
}
