import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:aura_app/app/app.dart';

void main() {
  testWidgets('App renders without crashing', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: AuraApp()));
    await tester.pump();

    // Initial route is /splash which shows 'AURA' logo
    expect(find.text('AURA'), findsOneWidget);

    // Advance past the splash timer (1s) to avoid pending timer error
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();
  });
}
