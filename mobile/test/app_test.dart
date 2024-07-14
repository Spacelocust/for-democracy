import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/main.dart';
import 'package:mobile/screens/events_screen.dart';
import 'package:mobile/screens/groups_screen.dart';
import 'package:mobile/screens/planets_screen.dart';
import 'package:mobile/states/auth_state.dart';
import 'package:provider/provider.dart';

void main() {
  group('App', () {
    testWidgets('Loads correctly', (WidgetTester tester) async {
      await dotenv.load(fileName: '.env');

      final Map<String, Function(BuildContext context, GoRouterState state)>
          views = {
        PlanetsScreen.routePath: (context, state) => const Text('Planets page'),
        EventsScreen.routePath: (context, state) => const Text('Events page'),
        GroupsScreen.routePath: (context, state) => const Text('Groups page'),
      };

      await tester.pumpWidget(
        ChangeNotifierProvider(
          create: (_) => AuthState(),
          child: ForDemocracyApp(
            goRouter: router(views),
          ),
        ),
      );

      expect(find.text('Planets'), findsOne);

      await tester.pumpAndSettle();
    });
  });
}
