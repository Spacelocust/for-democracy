import 'package:flutter/material.dart';
import 'package:mobile/models/defence.dart';
import 'package:mobile/widgets/base/list_item.dart';

class DefenceListItem extends ListItem {
  const DefenceListItem({super.key, required this.defence});

  final Defence defence;

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
