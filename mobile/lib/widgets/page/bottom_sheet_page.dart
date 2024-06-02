import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/screens/planets_screen.dart';

class BottomSheetPage<T> extends Page<T> {
  final Widget child;

  final bool isScrollControlled;

  const BottomSheetPage({
    required this.child,
    this.isScrollControlled = false,
    super.key,
  });

  @override
  Route<T> createRoute(BuildContext context) {
    return ModalBottomSheetRoute<T>(
      enableDrag: true,
      isDismissible: true,
      isScrollControlled: isScrollControlled,
      showDragHandle: true,
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
