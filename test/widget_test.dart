import 'package:flutter_test/flutter_test.dart';

import 'package:calorie_tracker_app/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const NutriScanApp());
    await tester.pump();

    // Verify that the app renders without crashing.
    expect(find.text('NutriScan'), findsWidgets);
  });
}

