import 'package:app/models/user.dart';
import 'package:app/services/users_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class UserDatatable extends StatefulWidget {
  const UserDatatable({super.key});

  @override
  State<UserDatatable> createState() => _UserDatatableState();
}

class _UserDatatableState extends State<UserDatatable> {
  late Future<List<User>> _usersFuture;

  @override
  void initState() {
    super.initState();
    fetchUsers();
  }

  void fetchUsers() {
    setState(() {
      _usersFuture = UsersService.getUsers();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final columns = [
      l10n.steamId,
      l10n.username,
      l10n.avatarUrl,
    ];

    return FutureBuilder<List<User>>(
      future: _usersFuture,
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
            ...snapshot.data!.map((user) {
              return DataRow(cells: [
                DataCell(Text(user.steamId)),
                DataCell(Text(user.username)),
                DataCell(Text(user.avatarUrl)),
              ]);
            })
          ],
        );
      },
    );
  }
}
