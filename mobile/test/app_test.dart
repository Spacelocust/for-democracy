import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/main.dart';
import 'package:mobile/states/auth_state.dart';
import 'package:provider/provider.dart';

void main() {
  group('App', () {
    testWidgets('Loads correctly', (WidgetTester tester) async {
      await dotenv.load(fileName: '.env');

      await tester.pumpWidget(
        ChangeNotifierProvider(
          create: (_) => AuthState(),
          child: const ForDemocracyApp(),
        ),
      );

      expect(find.text('Planets'), findsOne);

      await tester.pumpAndSettle();
    });
  });
}
