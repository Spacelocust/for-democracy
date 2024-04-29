import 'package:flutter_test/flutter_test.dart';

import 'package:mobile/main.dart';

void main() {
  group('App', () {
    testWidgets('App loads correctly', (WidgetTester tester) async {
      await tester.pumpWidget(const ForDemocracyApp());

      // Screen + Bottom Navigation Bar
      expect(find.text('Planets'), findsExactly(2));
    });
  });
}
