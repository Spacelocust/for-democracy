import 'package:flutter/material.dart';

class GroupScreen extends StatefulWidget {
  static const String routePath = ':groupId';

  static const String routeName = 'group';

  const GroupScreen({super.key});

  @override
  State<GroupScreen> createState() => _GroupScreenState();
}

class _GroupScreenState extends State<GroupScreen> {
  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(16),
    );
  }
}
