import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/models/user.dart';
import 'package:mobile/screens/error_screen.dart';
import 'package:mobile/screens/events_screen.dart';
import 'package:mobile/screens/groups_screen.dart';
import 'package:mobile/screens/planet_screen.dart';
import 'package:mobile/screens/planets_screen.dart';
import 'package:mobile/services/oauth_service.dart';
import 'package:mobile/states/auth_state.dart';
import 'package:mobile/states/galaxy_map_zoom.dart';
import 'package:mobile/utils/theme_colors.dart';
import 'package:mobile/widgets/layout/error_scaffold.dart';
import 'package:mobile/widgets/layout/main_scaffold.dart';
import 'package:mobile/widgets/page/bottom_sheet_page.dart';
import 'package:mobile/widgets/planet/galaxy_map.dart';
import 'package:provider/provider.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();

final _router = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: PlanetsScreen.routePath,
  errorBuilder: (context, state) => ErrorScaffold(
    body: ErrorScreen(error: state.error),
  ),
  routes: [
    ShellRoute(
      builder: (context, state, child) {
        return MainScaffold(body: child);
      },
      routes: [
        GoRoute(
          name: PlanetsScreen.routeName,
          path: PlanetsScreen.routePath,
          builder: (context, state) => const PlanetsScreen(),
          routes: [
            GoRoute(
              parentNavigatorKey: _rootNavigatorKey,
              name: PlanetScreen.routeName,
              path: PlanetScreen.routePath,
              pageBuilder: (BuildContext context, GoRouterState state) {
                return BottomSheetPage(
                  isScrollControlled: true,
                  child: PlanetScreen(
                    planetId: int.parse(
                      state.pathParameters['planetId']!,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
        GoRoute(
          name: EventsScreen.routeName,
          path: EventsScreen.routePath,
          builder: (context, state) => const EventsScreen(),
        ),
        GoRoute(
          name: GroupsScreen.routeName,
          path: GroupsScreen.routePath,
          builder: (context, state) => const GroupsScreen(),
        ),
      ],
    ),
  ],
);

Future main() async {
  await dotenv.load(fileName: '.env');
  WidgetsFlutterBinding.ensureInitialized();

  User? user;

  try {
    user = await OAuthService.getMe();
  } catch (e) {
    user = null;
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthState(user: user),
        ),
        ChangeNotifierProvider(
          create: (_) => GalaxyMapZoom(
            zoomFactor: GalaxyMap.initialZoomFactor,
          ),
        ),
      ],
      child: const ForDemocracyApp(),
    ),
  );
}

class ForDemocracyApp extends StatelessWidget {
  const ForDemocracyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      routerConfig: _router,
      supportedLocales: AppLocalizations.supportedLocales,
      theme: ThemeData(
        colorScheme: const ColorScheme.dark(
          primary: ThemeColors.primary,
          secondary: ThemeColors.primary,
          background: ThemeColors.surface,
          surfaceTint: ThemeColors.surface,
        ),
        fontFamily: 'Reddit Mono',
        useMaterial3: true,
      ),
      title: 'For Democracy',
    );
  }
}
