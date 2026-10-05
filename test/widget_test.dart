import 'package:flutter_test/flutter_test.dart';
import 'package:enough/app/enough_app.dart';

void main() {
  testWidgets('ENOUGH app launches without errors', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const EnoughApp());
    // Entry has intentional ambient motion, so wait briefly instead of settling.
    await tester.pump(const Duration(milliseconds: 800));

    // Entry screen should show
    expect(find.text('Let it out.'), findsOneWidget);
    expect(find.text('Release gently'), findsOneWidget);
  });
}
