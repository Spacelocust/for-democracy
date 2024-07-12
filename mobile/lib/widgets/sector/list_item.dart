import 'package:flutter/material.dart';
import 'package:mobile/models/sector.dart';
import 'package:mobile/widgets/base/list_item.dart';
import 'package:mobile/widgets/components/text_arame.dart';

class SectorListItem extends ListItem {
  const SectorListItem({super.key, required this.sector});

  final Sector sector;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(
          height: 16,
        ),
        ListTile(
          title: TextArame(
            text: sector.name,
          ),
        ),
      ],
    );
  }
}
