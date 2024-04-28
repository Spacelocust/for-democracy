import 'package:flutter/material.dart';
import 'package:mobile/widgets/layout/main_bottom_navigation_bar.dart';

class MainScaffold extends StatelessWidget {
  final Widget body;

  const MainScaffold({super.key, required this.body});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('For Democracy'),
      ),
      bottomNavigationBar: const MainBottomNavigationBar(),
      body: body,
    );
  }
}
