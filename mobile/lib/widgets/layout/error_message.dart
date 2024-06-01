import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ErrorMessage extends StatelessWidget {
  final VoidCallback onPressed;

  const ErrorMessage({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          Text(
            AppLocalizations.of(context)!.planetScreenError,
            style: const TextStyle(color: Colors.red),
          ),
          TextButton(
            onPressed: onPressed,
            child: Text(AppLocalizations.of(context)!.retry),
          ),
        ],
      ),
    );
  }
}
