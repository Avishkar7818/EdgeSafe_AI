import 'package:flutter_test/flutter_test.dart';
import 'package:edgesafe_ai/main.dart'; // Ensure this points to your main.dart

void main() {
  testWidgets('App load smoke test', (WidgetTester tester) async {
    // 1. Change MyApp() to EdgeSafeApp()
    await tester.pumpWidget(const EdgeSafeApp());

    // 2. Since your app now starts at the Login Screen,
    // we should check for "EDGESAFE AI" instead of a counter.
    expect(find.text('EDGESAFE AI'), findsOneWidget);
  });
}
