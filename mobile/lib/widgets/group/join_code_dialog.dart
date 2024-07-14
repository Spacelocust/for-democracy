import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/screens/group_screen.dart';
import 'package:mobile/services/groups_service.dart';
import 'package:mobile/utils/snackbar.dart';
import 'package:mobile/widgets/components/text_style_arame.dart';

class JoinCodeDialog extends StatefulWidget {
  const JoinCodeDialog({
    super.key,
  });

  @override
  State<JoinCodeDialog> createState() => _JoinCodeDialogState();
}

class _JoinCodeDialogState extends State<JoinCodeDialog> {
  final _formKey = GlobalKey<FormState>();

  final _codeController = TextEditingController();

  bool _submitting = false;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        AppLocalizations.of(context)!.groupJoin,
        style: const TextStyleArame(),
      ),
      content: Form(
        key: _formKey,
        child: TextFormField(
          controller: _codeController,
          enabled: !_submitting,
          decoration: InputDecoration(
            labelText: AppLocalizations.of(context)!.groupCode,
            hintText: AppLocalizations.of(context)!.groupCodeHint,
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return AppLocalizations.of(context)!.groupCodeEmpty;
            }

            return null;
          },
        ),
      ),
      actions: <Widget>[
        TextButton(
          style: TextButton.styleFrom(
            textStyle: Theme.of(context).textTheme.labelLarge,
          ),
          onPressed: _submitting
              ? null
              : () {
                  Navigator.of(context).pop();
                },
          child: Text(AppLocalizations.of(context)!.close),
        ),
        OutlinedButton.icon(
          onPressed: _submitting
              ? null
              : () async {
                  if (_formKey.currentState!.validate()) {
                    setState(() {
                      _submitting = true;
                    });

                    showSnackBar(
                      context,
                      AppLocalizations.of(context)!.groupJoining,
                      showCloseIcon: false,
                      duration: const Duration(
                        // Their phone will run out of battery before this finishes
                        days: 365,
                      ),
                    );

                    try {
                      final groupUser = await GroupsService.joinGroupWithCode(
                        _codeController.text,
                      );

                      if (!context.mounted) {
                        return;
                      }

                      showSnackBar(
                        context,
                        AppLocalizations.of(context)!.groupJoined,
                      );

                      Navigator.of(context).pop();

                      context.go(
                        context.namedLocation(
                          GroupScreen.routeName,
                          pathParameters: {
                            'groupId': groupUser.groupId.toString(),
                          },
                        ),
                      );
                    } on DioException catch (e) {
                      if (!context.mounted) {
                        return;
                      }

                      if (e.response?.statusCode == 400) {
                        showSnackBar(
                          context,
                          AppLocalizations.of(context)!.groupInvalidCode,
                        );
                      } else {
                        showSnackBar(
                          context,
                          AppLocalizations.of(context)!.groupCannotJoin,
                        );
                      }
                    } catch (e) {
                      if (!context.mounted) {
                        return;
                      }

                      showSnackBar(
                        context,
                        AppLocalizations.of(context)!.somethingWentWrong,
                      );
                    } finally {
                      setState(() {
                        _submitting = false;
                      });
                    }
                  }
                },
          icon: const Icon(Icons.group_add),
          label: Text(AppLocalizations.of(context)!.join),
        ),
      ],
    );
  }
}
