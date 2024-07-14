import 'package:app/models/group.dart';
import 'package:app/services/groups_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class GroupsDatatable extends StatefulWidget {
  const GroupsDatatable({super.key});

  @override
  State<GroupsDatatable> createState() => _GroupsDatatableState();
}

class _GroupsDatatableState extends State<GroupsDatatable> {
  late Future<List<Group>> _groupsFuture;

  @override
  void initState() {
    super.initState();
    fetchUsers();
  }

  void fetchUsers() {
    setState(() {
      _groupsFuture = GroupsService.getGroups();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final columns = [
      l10n.id,
      l10n.code,
      l10n.name,
      l10n.planet,
      l10n.difficulty,
      l10n.public,
      l10n.startAt,
    ];

    return FutureBuilder<List<Group>>(
      future: _groupsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        }

        if (snapshot.hasError || !snapshot.hasData) {
          return Text('Error: ${snapshot.error}');
        }

        return DataTable(
          columns: [
            ...columns.map(
              (column) => DataColumn(
                label: Expanded(
                  child: Text(
                    column,
                    style: const TextStyle(fontStyle: FontStyle.italic),
                  ),
                ),
              ),
            ),
          ],
          rows: [
            ...snapshot.data!.map((group) {
              return DataRow(cells: [
                DataCell(Text(group.id.toString())),
                DataCell(Text(group.code)),
                DataCell(Text(group.name)),
                DataCell(Text(group.planet.name)),
                DataCell(Text(group.difficulty.toString())),
                DataCell(Text(group.public.toString())),
                DataCell(Text(group.startAt.toString())),
              ]);
            })
          ],
        );
      },
    );
  }
}
