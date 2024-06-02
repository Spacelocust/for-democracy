import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/screens/planets_screen.dart';

class DialogPage<T> extends Page<T> {
  final Widget child;

  const DialogPage({required this.child, super.key});

  @override
  Route<T> createRoute(BuildContext context) {
    return DialogRoute<T>(
      context: context,
      settings: this,
      builder: (context) => child,
    )..completed.then(
        (value) {
          if (context.canPop()) {
            context.pop();
          }

          context.goNamed(PlanetsScreen.routeName);
        },
      );
  }
}
