import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/models/user.dart';
import 'package:mobile/screens/error_screen.dart';
import 'package:mobile/screens/events_screen.dart';
import 'package:mobile/screens/group_new_screen.dart';
import 'package:mobile/screens/group_screen.dart';
import 'package:mobile/screens/groups_screen.dart';
import 'package:mobile/screens/planet_screen.dart';
import 'package:mobile/screens/planets_screen.dart';
import 'package:mobile/services/oauth_service.dart';
import 'package:mobile/states/auth_state.dart';
import 'package:mobile/states/galaxy_map_zoom_state.dart';
import 'package:mobile/states/groups_filters_state.dart';
import 'package:mobile/states/planets_state.dart';
import 'package:mobile/utils/theme_colors.dart';
import 'package:mobile/widgets/layout/error_scaffold.dart';
import 'package:mobile/widgets/layout/main_scaffold.dart';
import 'package:mobile/widgets/page/bottom_sheet_page.dart';
import 'package:mobile/widgets/planet/galaxy_map.dart';
import 'package:provider/provider.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();

/// The views that will be used by the router.
final Map<String, Function(BuildContext context, GoRouterState state)> _views =
    {
  PlanetsScreen.routePath: (context, state) => const PlanetsScreen(),
  PlanetScreen.routePath: (context, state) => PlanetScreen(
        planetId: int.parse(
          state.pathParameters['planetId']!,
        ),
      ),
  EventsScreen.routePath: (context, state) => const EventsScreen(),
  GroupsScreen.routePath: (context, state) => const GroupsScreen(),
  GroupScreen.routePath: (context, state) => GroupScreen(
        groupId: int.parse(
          state.pathParameters['groupId']!,
        ),
      ),
  GroupNewScreen.routePath: (context, state) => const GroupNewScreen(),
};

/// The router configuration.
GoRouter router(
  Map<String, Function(BuildContext context, GoRouterState state)> views,
) {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: PlanetsScreen.routePath,
    errorBuilder: (context, state) => ErrorScaffold(
      body: ErrorScreen(error: state.error),
    ),
    routes: [
      ShellRoute(
        builder: (context, state, child) {
          return MainScaffold(
            body: child,
          );
        },
        routes: [
          GoRoute(
            name: PlanetsScreen.routeName,
            path: PlanetsScreen.routePath,
            builder: (context, state) => ChangeNotifierProvider(
              create: (_) => PlanetsState(planets: []),
              child: views[PlanetsScreen.routePath]!(context, state),
            ),
            routes: [
              // TODO make this page keep the current screen in the background
              GoRoute(
                parentNavigatorKey: _rootNavigatorKey,
                name: PlanetScreen.routeName,
                path: PlanetScreen.routePath,
                pageBuilder: (BuildContext context, GoRouterState state) {
                  return BottomSheetPage(
                    isScrollControlled: true,
                    child: views[PlanetScreen.routePath]!(
                      context,
                      state,
                    ),
                  );
                },
              ),
            ],
          ),
          GoRoute(
            name: EventsScreen.routeName,
            path: EventsScreen.routePath,
            builder: (context, state) =>
                views[EventsScreen.routePath]!(context, state),
          ),
          GoRoute(
            name: GroupsScreen.routeName,
            path: GroupsScreen.routePath,
            builder: (context, state) =>
                views[GroupsScreen.routePath]!(context, state),
            routes: [
              GoRoute(
                name: GroupNewScreen.routeName,
                path: GroupNewScreen.routePath,
                builder: (context, state) => views[GroupNewScreen.routePath]!(
                  context,
                  state,
                ),
              ),
              GoRoute(
                name: GroupScreen.routeName,
                path: GroupScreen.routePath,
                builder: (context, state) => views[GroupScreen.routePath]!(
                  context,
                  state,
                ),
              ),
            ],
          ),
        ],
      ),
    ],
  );
}

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
          create: (_) => GalaxyMapZoomState(
            zoomFactor: GalaxyMap.initialZoomFactor,
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => GroupsFiltersState(),
        ),
      ],
      child: ForDemocracyApp(
        goRouter: router(_views),
      ),
    ),
  );
}

class ForDemocracyApp extends StatelessWidget {
  final GoRouter? goRouter;

  const ForDemocracyApp({
    super.key,
    this.goRouter,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      routerConfig: goRouter,
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
