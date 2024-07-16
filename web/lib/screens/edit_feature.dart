import 'package:flutter/material.dart';

class EditFeatureScreen extends StatelessWidget {
  static const String routePath = 'feature/:featureCode';

  static const String routeName = 'feature';

  final String featureCode;

  const EditFeatureScreen({super.key, required this.featureCode});

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
