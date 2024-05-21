import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class GroupsScreen extends StatefulWidget {
  static const String routeName = '/groups';

  const GroupsScreen({super.key});

  @override
  State<GroupsScreen> createState() => _GroupsScreenState();
}

class _GroupsScreenState extends State<GroupsScreen> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(AppLocalizations.of(context)!.groups),
    );
  }
}
