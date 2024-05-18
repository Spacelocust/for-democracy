import 'package:flutter_test/flutter_test.dart';

import 'package:mobile/main.dart';

void main() {
  group('App', () {
    testWidgets('Loads correctly', (WidgetTester tester) async {
      await tester.pumpWidget(const ForDemocracyApp());

      expect(find.text('Planets'), findsOne);

      await tester.pumpAndSettle();
    });
  });
}
