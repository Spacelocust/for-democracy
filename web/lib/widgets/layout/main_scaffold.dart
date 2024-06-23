import 'package:flutter/material.dart';

class MainScaffold extends StatelessWidget {
  final Widget body;

  const MainScaffold({super.key, required this.body});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final breakpoints = [640, 768, 1024, 1280, 1536];

            final width = MediaQuery.of(context).size.width;

            for (var breakpoint in breakpoints.reversed) {
              if (width >= breakpoint) {
                return Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: breakpoint.toDouble(),
                    ),
                    child: body,
                  ),
                );
              }
            }

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: body,
            );
          },
        ),
      ),
    );
  }
}
