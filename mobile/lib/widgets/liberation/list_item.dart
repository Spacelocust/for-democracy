import 'package:flutter/material.dart';
import 'package:mobile/models/defence.dart';
import 'package:mobile/widgets/base/list_item.dart';

class LiberationListItem extends ListItem {
  const LiberationListItem({super.key, required this.liberation});

  final Defence liberation;

  @override
  Widget build(BuildContext context) {
    return const ListTile(
      title: Text('TODO'),
      trailing: Text('TODO'),
      subtitle: Text('TODO'),
      // onTap: () => (),
    );
  }
}
