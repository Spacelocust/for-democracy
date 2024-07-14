import 'package:flutter/material.dart';

/// Show a snackbar with a message. This clears any existing snackbars before showing the new one.
void showSnackBar(
  BuildContext context,
  String message, {
  Duration duration = const Duration(seconds: 5),
  bool showCloseIcon = true,
}) {
  ScaffoldMessenger.of(context)
    ..removeCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(message),
        duration: duration,
        showCloseIcon: showCloseIcon,
      ),
    );
}
