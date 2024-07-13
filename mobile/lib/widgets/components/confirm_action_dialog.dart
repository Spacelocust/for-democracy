import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ConfirmActionDialog extends StatefulWidget {
  final Widget? title;

  final Widget? content;

  final Function? onCancel;

  final Function onConfirm;

  final String? actionText;

  const ConfirmActionDialog({
    super.key,
    this.title,
    this.content,
    this.onCancel,
    this.actionText,
    required this.onConfirm,
  });

  @override
  State<ConfirmActionDialog> createState() => _ConfirmActionDialogState();
}

class _ConfirmActionDialogState extends State<ConfirmActionDialog> {
  bool _confirmating = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: widget.title ??
          Text(AppLocalizations.of(context)!.confirmationRequired),
      content: widget.content ??
          Text(AppLocalizations.of(context)!.actionConfirmation),
      actions: [
        TextButton(
          onPressed: _confirmating
              ? null
              : () {
                  if (widget.onCancel != null) {
                    widget.onCancel!();
                  }

                  Navigator.of(context).pop();
                },
          child: Text(AppLocalizations.of(context)!.cancel),
        ),
        OutlinedButton(
          onPressed: _confirmating
              ? null
              : () async {
                  setState(() {
                    _confirmating = true;
                  });

                  try {
                    await widget.onConfirm();

                    if (!context.mounted) {
                      return;
                    }
                  } finally {
                    setState(() {
                      _confirmating = false;
                    });
                  }
                },
          child:
              Text(widget.actionText ?? AppLocalizations.of(context)!.delete),
        ),
      ],
    );
  }
}
