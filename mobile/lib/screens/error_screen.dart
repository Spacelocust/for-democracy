import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/screens/planets_screen.dart';

class ErrorScreen extends StatefulWidget {
  final GoException? error;

  const ErrorScreen({
    this.error,
    super.key,
  });

  @override
  State<ErrorScreen> createState() => _ErrorScreenState();
}

class _ErrorScreenState extends State<ErrorScreen> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              AppLocalizations.of(context)!.pageNotFound,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
            ),
            const SizedBox(height: 16),
            Text(
              widget.error?.toString() ??
                  AppLocalizations.of(context)!.unknownError,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.go(
                context.namedLocation(PlanetsScreen.routeName),
              ),
              child: Text(
                AppLocalizations.of(context)!.goHome,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
