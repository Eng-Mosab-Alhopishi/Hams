import 'package:flutter_test/flutter_test.dart';
import 'package:ghostdrop/app/app.dart';

void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const HamsApp());

    // Verify that our counter starts at 0.
    // Note: This test is just to ensure compilation after renaming.
  });
}
