import 'package:app/screens/home_screen.dart';
import 'package:app/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';

class LoginScreen extends StatelessWidget {
  static const String routePath = '/login';

  static const String routeName = 'login';

  final usernameController = TextEditingController();

  final passwordController = TextEditingController();

  LoginScreen({super.key});

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TextFormField(
            controller: usernameController,
            decoration: InputDecoration(
              labelText: AppLocalizations.of(context)!.username,
            ),
          ),
          TextFormField(
            controller: passwordController,
            decoration: InputDecoration(
              labelText: AppLocalizations.of(context)!.password,
            ),
            obscureText: true,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              AuthService.login(
                      usernameController.text, passwordController.text)
                  .then((admin) {
                if (admin != null) {
                  context.goNamed(HomeScreen.routeName);
                }
              });
            },
            child: Text(AppLocalizations.of(context)!.login),
          ),
        ],
      ),
    );
  }
}
