import 'package:flutter/material.dart';
import 'package:mobile/utils/theme_colors.dart';

class ListItem extends StatelessWidget {
  final String title;

  const ListItem({
    super.key,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: ThemeColors.primary[200],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4),
      ),
      child: ListTile(
        textColor: Colors.black,
        title: Text(title),
        titleTextStyle: Theme.of(context).textTheme.labelLarge,
      ),
    );
  }
}
