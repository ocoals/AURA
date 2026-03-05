import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:aura_app/app/theme.dart';

void main() {
  testWidgets('App theme loads without crashing', (WidgetTester tester) async {
    // Smoke test: verify theme and basic widget tree render without Supabase
    await tester.pumpWidget(
      MaterialApp(
        theme: appTheme,
        home: const Scaffold(body: Center(child: Text('AURA'))),
      ),
    );

    expect(find.text('AURA'), findsOneWidget);
  });
}
