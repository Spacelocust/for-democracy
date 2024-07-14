import 'package:flutter/material.dart';
import 'package:mobile/models/sector.dart';
import 'package:mobile/widgets/base/list_item.dart';
import 'package:mobile/widgets/components/text_style_arame.dart';

class SectorListItem extends ListItem {
  const SectorListItem({super.key, required this.sector});

  final Sector sector;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(
          height: 8,
        ),
        ListTile(
          title: Text(
            sector.name,
            style: const TextStyleArame(),
          ),
        ),
      ],
    );
  }
}
