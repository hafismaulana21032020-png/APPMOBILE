import 'package:flutter_test/flutter_test.dart';

import 'package:breakfree_app/app.dart';

void main() {
  testWidgets('App renders login page smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const BreakFreeApp());

    // Verify that our brand header and greeting are rendered.
    expect(find.text('BreakFree'), findsOneWidget);
    expect(find.text('Selamat datang kembali!'), findsOneWidget);
  });
}
