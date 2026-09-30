import 'package:flutter_test/flutter_test.dart';
import 'package:fitpulse/main.dart';

void main() {
  testWidgets('FitPulseApp smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const FitPulseApp());
    expect(find.textContaining('FitPulse'), findsOneWidget);
  });
}
