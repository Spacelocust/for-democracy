import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ErrorMessage extends StatelessWidget {
  final VoidCallback onPressed;

  final String errorMessage;

  const ErrorMessage({
    super.key,
    required this.onPressed,
    required this.errorMessage,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              errorMessage,
              style: const TextStyle(color: Colors.red),
            ),
            TextButton(
              onPressed: onPressed,
              child: Text(AppLocalizations.of(context)!.retry),
            ),
          ],
        ),
      ),
    );
  }
}
