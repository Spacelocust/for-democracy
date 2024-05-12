import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/screens/events_screen.dart';
import 'package:mobile/screens/groups_screen.dart';
import 'package:mobile/screens/planets_screen.dart';
import 'package:mobile/utils/theme_colors.dart';
import 'package:mobile/widgets/layout/main_scaffold.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

final _router = GoRouter(
  initialLocation: '/planets',
  routes: [
    ShellRoute(
      builder: (context, state, child) {
        return MainScaffold(body: child);
      },
      routes: [
        GoRoute(
          path: '/planets',
          builder: (context, state) => const PlanetsScreen(),
        ),
        GoRoute(
          path: '/events',
          builder: (context, state) => const EventsScreen(),
        ),
        GoRoute(
          path: '/groups',
          builder: (context, state) => const GroupsScreen(),
        ),
      ],
    ),
  ],
);

Future main() async {
  await dotenv.load(fileName: '.env');

  runApp(const ForDemocracyApp());
}

class ForDemocracyApp extends StatelessWidget {
  const ForDemocracyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'For Democracy',
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      theme: ThemeData(
        primaryColor: ThemeColors.primary,
        secondaryHeaderColor: ThemeColors.secondary,
        colorScheme: ColorScheme.fromSwatch(
          primarySwatch: ThemeColors.primaryMaterial,
          accentColor: ThemeColors.secondary,
        ),
        useMaterial3: true,
      ),
      routerConfig: _router,
    );
  }
}
