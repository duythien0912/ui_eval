import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:ui_eval_example/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Counter App Integration Tests', () {
    testWidgets('verify counter app loads and works', (WidgetTester tester) async {
      // Launch the app
      app.main();
      await tester.pumpAndSettle();

      // Wait for the app to load
      await Future.delayed(const Duration(seconds: 2));
      await tester.pumpAndSettle();

      // Tap on Counter App to open it
      final counterAppTile = find.text('Counter App');
      expect(counterAppTile, findsOneWidget);
      await tester.tap(counterAppTile);
      await tester.pumpAndSettle();

      // Wait for bundle to load
      await Future.delayed(const Duration(seconds: 2));
      await tester.pumpAndSettle();

      // Verify initial state - look for counter text
      expect(find.text('0'), findsOneWidget);
      
      // Find and tap increment button
      final incrementButton = find.byIcon(Icons.add);
      expect(incrementButton, findsOneWidget);
      
      await tester.tap(incrementButton);
      await tester.pumpAndSettle();
      
      // Verify count increased
      expect(find.text('1'), findsOneWidget);
      expect(find.text('0'), findsNothing);
      
      // Tap increment again
      await tester.tap(incrementButton);
      await tester.pumpAndSettle();
      
      expect(find.text('2'), findsOneWidget);
      
      // Find and tap decrement button
      final decrementButton = find.byIcon(Icons.remove);
      expect(decrementButton, findsOneWidget);
      
      await tester.tap(decrementButton);
      await tester.pumpAndSettle();
      
      expect(find.text('1'), findsOneWidget);
      
      // Find and tap reset button
      final resetButton = find.text('Reset');
      expect(resetButton, findsOneWidget);
      
      await tester.tap(resetButton);
      await tester.pumpAndSettle();
      
      expect(find.text('0'), findsOneWidget);
    });

    testWidgets('verify slider changes step value', (WidgetTester tester) async {
      // Launch the app
      app.main();
      await tester.pumpAndSettle();

      // Wait for the app to load
      await Future.delayed(const Duration(seconds: 2));
      await tester.pumpAndSettle();

      // Tap on Counter App to open it
      final counterAppTile = find.text('Counter App');
      expect(counterAppTile, findsOneWidget);
      await tester.tap(counterAppTile);
      await tester.pumpAndSettle();

      // Wait for bundle to load
      await Future.delayed(const Duration(seconds: 2));
      await tester.pumpAndSettle();

      // Verify initial step is 1
      expect(find.text('Step: 1'), findsOneWidget);
      
      // Find slider
      final slider = find.byType(Slider);
      expect(slider, findsOneWidget);
      
      // Get initial slider value
      final initialSlider = tester.widget<Slider>(slider);
      expect(initialSlider.value, 1.0);
      
      // Drag slider to change value
      await tester.drag(slider, const Offset(100, 0));
      await tester.pumpAndSettle();
      
      // Verify step text changed (value should be greater than 1)
      final newSlider = tester.widget<Slider>(slider);
      expect(newSlider.value, greaterThan(1.0));
      
      // With higher step value, increment should add more
      final incrementButton = find.byIcon(Icons.add);
      
      // Reset counter first
      await tester.tap(find.text('Reset'));
      await tester.pumpAndSettle();
      expect(find.text('0'), findsOneWidget);
      
      // Increment with new step value
      await tester.tap(incrementButton);
      await tester.pumpAndSettle();
      
      // Count should be greater than 1 (since step > 1)
      final newSliderValue = tester.widget<Slider>(slider).value;
      final expectedCount = newSliderValue.round();
      expect(find.text('$expectedCount'), findsOneWidget);
    });

    testWidgets('verify double and set value buttons work', (WidgetTester tester) async {
      // Launch the app
      app.main();
      await tester.pumpAndSettle();

      // Wait for the app to load
      await Future.delayed(const Duration(seconds: 2));
      await tester.pumpAndSettle();

      // Tap on Counter App to open it
      final counterAppTile = find.text('Counter App');
      expect(counterAppTile, findsOneWidget);
      await tester.tap(counterAppTile);
      await tester.pumpAndSettle();

      // Wait for bundle to load
      await Future.delayed(const Duration(seconds: 2));
      await tester.pumpAndSettle();

      // Reset first
      await tester.tap(find.text('Reset'));
      await tester.pumpAndSettle();
      expect(find.text('0'), findsOneWidget);
      
      // Increment a few times
      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();
      expect(find.text('2'), findsOneWidget);
      
      // Tap Double button
      await tester.tap(find.text('Double'));
      await tester.pumpAndSettle();
      expect(find.text('4'), findsOneWidget);
      
      // Tap Set to 100 button
      await tester.tap(find.text('Set to 100'));
      await tester.pumpAndSettle();
      expect(find.text('100'), findsOneWidget);
    });
  });
}
