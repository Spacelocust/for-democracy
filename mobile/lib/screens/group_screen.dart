import 'package:flutter/material.dart';
import 'package:mobile/models/group.dart';
import 'package:mobile/services/groups_service.dart';
import 'package:mobile/widgets/components/spinner.dart';
import 'package:mobile/widgets/layout/error_message.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class GroupScreen extends StatefulWidget {
  static const String routePath = ':groupId';

  static const String routeName = 'group';

  final int groupId;

  const GroupScreen({
    super.key,
    required this.groupId,
  });

  @override
  State<GroupScreen> createState() => _GroupScreenState();
}

class _GroupScreenState extends State<GroupScreen> {
  Future<Group>? _groupFuture;

  @override
  void initState() {
    super.initState();
    fetchGroup();
  }

  void fetchGroup() {
    setState(() {
      _groupFuture = GroupsService.getGroup(widget.groupId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: FutureBuilder<Group>(
        future: _groupFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // Loading state
            return Spinner(
              semanticsLabel: AppLocalizations.of(context)!.planetScreenLoading,
            );
          }

          if (snapshot.hasError || !snapshot.hasData) {
            // Error state
            return ErrorMessage(
              errorMessage: AppLocalizations.of(context)!.planetScreenError,
              onPressed: fetchGroup,
            );
          }

          // Success state
          Group group = snapshot.data!;

          return Text(group.name);
        },
      ),
    );
  }
}
