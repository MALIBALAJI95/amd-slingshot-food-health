import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nourishiq/main.dart'; // Ensure pubspec name matches
import 'package:provider/provider.dart';

void main() {
  testWidgets('Predictive Meal card renders on DashboardScreen', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (context) => NourishIQState(),
        child: const NourishIQApp(),
      ),
    );

    // Verify that the title is present
    expect(find.text('NourishIQ Dashboard'), findsOneWidget);

    // Verify the "Predictive Meal" section header is present
    expect(find.text('Predictive Meal'), findsOneWidget);

    // Verify placeholder text is present when state has no recommendation
    expect(find.textContaining('Click the button below to generate'), findsOneWidget);

    // Verify the floating action button exists
    expect(find.byType(FloatingActionButton), findsOneWidget);
  });
}
