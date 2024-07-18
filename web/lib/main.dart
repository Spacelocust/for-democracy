import 'package:app/screens/edit_feature.dart';
import 'package:app/screens/error_screen.dart';
import 'package:app/screens/home_screen.dart';
import 'package:app/screens/login_screen.dart';
import 'package:app/services/api_service.dart';
import 'package:app/widgets/layout/error_scaffold.dart';
import 'package:app/widgets/layout/main_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();

/// The views that will be used by the router
final Map<String, Function(BuildContext context, GoRouterState state)> _views =
    {
  LoginScreen.routePath: (context, state) => LoginScreen(key: UniqueKey()),
  HomeScreen.routePath: (context, state) => HomeScreen(key: UniqueKey()),
  EditFeatureScreen.routePath: (context, state) => EditFeatureScreen(
        key: UniqueKey(),
        featureCode: state.pathParameters['featureCode']!,
      ),
};

/// The router configuration
GoRouter router(
  Map<String, Function(BuildContext context, GoRouterState state)> views,
) {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: LoginScreen.routePath,
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
            name: LoginScreen.routeName,
            path: LoginScreen.routePath,
            builder: (context, state) =>
                views[LoginScreen.routePath]!(context, state),
          ),
          GoRoute(
            name: HomeScreen.routeName,
            path: HomeScreen.routePath,
            builder: (context, state) =>
                views[HomeScreen.routePath]!(context, state),
          ),
          // GoRoute(
          //   name: EditFeatureScreen.routeName,
          //   path: EditFeatureScreen.routePath,
          //   builder: (context, state) =>
          //       views[EditFeatureScreen.routePath]!(context, state),
          // ),
        ],
      ),
    ],
  );
}

void main() async {
  await dotenv.load(fileName: '.env');

  try {
    APIService.prepareJar();
  } catch (e) {
    print('Failed to prepare jar: $e');
  }

  runApp(
    AdminApp(
      goRouter: router(_views),
    ),
  );
}

class AdminApp extends StatelessWidget {
  final GoRouter? goRouter;

  const AdminApp({super.key, this.goRouter});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      routerConfig: goRouter,
      supportedLocales: AppLocalizations.supportedLocales,
      title: 'For Democracy admin',
    );
  }
}
