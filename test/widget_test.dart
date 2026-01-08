import 'package:flutter_test/flutter_test.dart';
import 'package:enough/app/enough_app.dart';
import 'package:enough/core/services/day_guard_service.dart';

void main() {
  testWidgets('ENOUGH app launches without errors', (WidgetTester tester) async {
    final dayGuard = DayGuardService();
    
    await tester.pumpWidget(EnoughApp(dayGuard: dayGuard));
    await tester.pumpAndSettle();
    
    // Entry screen should show
    expect(find.text('You can stop now.'), findsOneWidget);
  });
}
