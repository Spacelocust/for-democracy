import 'package:app/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class LoginScreen extends StatelessWidget {
  static const String routePath = '/login';

  static const String routeName = 'login';

  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Form(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TextFormField(
            decoration: const InputDecoration(
              labelText: AppLocalizations.of(context)!.username,
            ),
          ),
          TextFormField(
            decoration: const InputDecoration(
              labelText: AppLocalizations.of(context)!.password,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              context.goNamed(HomeScreen.routeName);
            },
            child: const Text(AppLocalizations.of(context)!.login),
          ),
        ],
      ),
    );
  }
}
