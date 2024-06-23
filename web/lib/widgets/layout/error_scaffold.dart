import 'package:flutter/material.dart';

class ErrorScaffold extends StatelessWidget {
  final Widget body;

  const ErrorScaffold({super.key, required this.body});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('For Democracy'),
      ),
      body: body,
    );
  }
}
