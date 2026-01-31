import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:ui_eval_example/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Todo App Integration Tests', () {
    testWidgets('verify todo app loads correctly', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      await Future.delayed(const Duration(seconds: 2));
      await tester.pumpAndSettle();

      // Tap on Todo App to open it
      final todoAppTile = find.text('Todo App');
      expect(todoAppTile, findsOneWidget);
      await tester.tap(todoAppTile);
      await tester.pumpAndSettle();

      // Wait for bundle to load
      await Future.delayed(const Duration(seconds: 2));
      await tester.pumpAndSettle();

      // Verify app bar title
      expect(find.text('Todo List'), findsOneWidget);

      // Verify input field exists
      expect(find.byType(TextField), findsOneWidget);

      // Verify Add button exists
      expect(find.text('Add'), findsOneWidget);

      // Verify refresh button exists
      expect(find.byIcon(Icons.refresh), findsOneWidget);
    });

    testWidgets('add new todo item', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      await Future.delayed(const Duration(seconds: 2));
      await tester.pumpAndSettle();

      // Navigate to Todo App
      await tester.tap(find.text('Todo App'));
      await tester.pumpAndSettle();

      await Future.delayed(const Duration(seconds: 2));
      await tester.pumpAndSettle();

      // Enter text in the input field
      final textField = find.byType(TextField);
      expect(textField, findsOneWidget);

      await tester.enterText(textField, 'Buy groceries');
      await tester.pumpAndSettle();

      // Tap Add button
      final addButton = find.text('Add');
      await tester.tap(addButton);
      await tester.pumpAndSettle();

      // Wait for action to execute through JS bridge
      await Future.delayed(const Duration(seconds: 1));
      await tester.pumpAndSettle();
      await tester.pump();

      // Verify todo was added to the list
      expect(find.text('Buy groceries'), findsOneWidget);

      // Verify input field was cleared
      final TextField textFieldWidget = tester.widget(textField);
      expect(textFieldWidget.controller?.text ?? '', isEmpty);
    });

    testWidgets('add multiple todo items', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      await Future.delayed(const Duration(seconds: 2));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Todo App'));
      await tester.pumpAndSettle();

      await Future.delayed(const Duration(seconds: 2));
      await tester.pumpAndSettle();

      final textField = find.byType(TextField);
      final addButton = find.text('Add');

      // Add first todo
      await tester.enterText(textField, 'First task');
      await tester.pumpAndSettle();
      await tester.tap(addButton);
      await tester.pumpAndSettle();
      await Future.delayed(const Duration(seconds: 1));
      await tester.pumpAndSettle();
      await tester.pump();

      // Add second todo
      await tester.enterText(textField, 'Second task');
      await tester.pumpAndSettle();
      await tester.tap(addButton);
      await tester.pumpAndSettle();
      await Future.delayed(const Duration(seconds: 1));
      await tester.pumpAndSettle();
      await tester.pump();

      // Add third todo
      await tester.enterText(textField, 'Third task');
      await tester.pumpAndSettle();
      await tester.tap(addButton);
      await tester.pumpAndSettle();
      await Future.delayed(const Duration(seconds: 1));
      await tester.pumpAndSettle();
      await tester.pump();

      // Verify all todos are displayed
      expect(find.text('First task'), findsOneWidget);
      expect(find.text('Second task'), findsOneWidget);
      expect(find.text('Third task'), findsOneWidget);
    });

    testWidgets('toggle todo completion status', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      await Future.delayed(const Duration(seconds: 2));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Todo App'));
      await tester.pumpAndSettle();

      await Future.delayed(const Duration(seconds: 2));
      await tester.pumpAndSettle();

      // Add a todo
      final textField = find.byType(TextField);
      await tester.enterText(textField, 'Task to complete');
      await tester.pumpAndSettle();
      await tester.tap(find.text('Add'));
      await tester.pumpAndSettle();
      await Future.delayed(const Duration(seconds: 1));
      await tester.pumpAndSettle();
      await tester.pump();

      // Find the checkbox
      final checkbox = find.byType(Checkbox);
      expect(checkbox, findsOneWidget);

      // Verify initial state (unchecked)
      Checkbox checkboxWidget = tester.widget(checkbox);
      expect(checkboxWidget.value, false);

      // Tap checkbox to complete the todo
      await tester.tap(checkbox);
      await tester.pumpAndSettle();
      await Future.delayed(const Duration(seconds: 1));
      await tester.pumpAndSettle();
      await tester.pump();

      // Verify checkbox is now checked
      checkboxWidget = tester.widget(checkbox);
      expect(checkboxWidget.value, true);

      // Tap again to uncomplete
      await tester.tap(checkbox);
      await tester.pumpAndSettle();
      await Future.delayed(const Duration(seconds: 1));
      await tester.pumpAndSettle();
      await tester.pump();

      // Verify checkbox is unchecked again
      checkboxWidget = tester.widget(checkbox);
      expect(checkboxWidget.value, false);
    });

    testWidgets('delete todo item', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      await Future.delayed(const Duration(seconds: 2));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Todo App'));
      await tester.pumpAndSettle();

      await Future.delayed(const Duration(seconds: 2));
      await tester.pumpAndSettle();

      // Add a todo
      final textField = find.byType(TextField);
      await tester.enterText(textField, 'Task to delete');
      await tester.pumpAndSettle();
      await tester.tap(find.text('Add'));
      await tester.pumpAndSettle();
      await Future.delayed(const Duration(seconds: 1));
      await tester.pumpAndSettle();
      await tester.pump();

      // Verify todo exists
      expect(find.text('Task to delete'), findsOneWidget);

      // Find and tap delete button
      final deleteButton = find.byIcon(Icons.delete);
      expect(deleteButton, findsOneWidget);
      await tester.tap(deleteButton);
      await tester.pumpAndSettle();
      await Future.delayed(const Duration(seconds: 1));
      await tester.pumpAndSettle();
      await tester.pump();

      // Verify todo was deleted
      expect(find.text('Task to delete'), findsNothing);
    });

    testWidgets('delete specific todo from multiple items', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      await Future.delayed(const Duration(seconds: 2));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Todo App'));
      await tester.pumpAndSettle();

      await Future.delayed(const Duration(seconds: 2));
      await tester.pumpAndSettle();

      final textField = find.byType(TextField);
      final addButton = find.text('Add');

      // Add three todos
      await tester.enterText(textField, 'Keep this one');
      await tester.pumpAndSettle();
      await tester.tap(addButton);
      await tester.pumpAndSettle();
      await Future.delayed(const Duration(seconds: 1));
      await tester.pumpAndSettle();
      await tester.pump();

      await tester.enterText(textField, 'Delete this one');
      await tester.pumpAndSettle();
      await tester.tap(addButton);
      await tester.pumpAndSettle();
      await Future.delayed(const Duration(seconds: 1));
      await tester.pumpAndSettle();
      await tester.pump();

      await tester.enterText(textField, 'Keep this too');
      await tester.pumpAndSettle();
      await tester.tap(addButton);
      await tester.pumpAndSettle();
      await Future.delayed(const Duration(seconds: 1));
      await tester.pumpAndSettle();
      await tester.pump();

      // Verify all three exist
      expect(find.text('Keep this one'), findsOneWidget);
      expect(find.text('Delete this one'), findsOneWidget);
      expect(find.text('Keep this too'), findsOneWidget);

      // Find all delete buttons (should be 3)
      final deleteButtons = find.byIcon(Icons.delete);
      expect(deleteButtons, findsNWidgets(3));

      // Delete the middle one (index 1)
      await tester.tap(deleteButtons.at(1));
      await tester.pumpAndSettle();
      await Future.delayed(const Duration(seconds: 1));
      await tester.pumpAndSettle();
      await tester.pump();

      // Verify correct item was deleted
      expect(find.text('Keep this one'), findsOneWidget);
      expect(find.text('Delete this one'), findsNothing);
      expect(find.text('Keep this too'), findsOneWidget);

      // Only 2 delete buttons should remain
      expect(find.byIcon(Icons.delete), findsNWidgets(2));
    });

    testWidgets('empty todo title is not added', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      await Future.delayed(const Duration(seconds: 2));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Todo App'));
      await tester.pumpAndSettle();

      await Future.delayed(const Duration(seconds: 2));
      await tester.pumpAndSettle();

      // Try to add empty todo
      final addButton = find.text('Add');
      await tester.tap(addButton);
      await tester.pumpAndSettle();
      await Future.delayed(const Duration(seconds: 1));
      await tester.pumpAndSettle();
      await tester.pump();

      // Verify no checkbox appears (no todo was added)
      expect(find.byType(Checkbox), findsNothing);

      // Try with whitespace only
      final textField = find.byType(TextField);
      await tester.enterText(textField, '   ');
      await tester.pumpAndSettle();
      await tester.tap(addButton);
      await tester.pumpAndSettle();
      await Future.delayed(const Duration(seconds: 1));
      await tester.pumpAndSettle();
      await tester.pump();

      // Still no checkbox
      expect(find.byType(Checkbox), findsNothing);
    });

    testWidgets('fetch todos from API', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      await Future.delayed(const Duration(seconds: 2));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Todo App'));
      await tester.pumpAndSettle();

      await Future.delayed(const Duration(seconds: 2));
      await tester.pumpAndSettle();

      // Find and tap refresh button
      final refreshButton = find.byIcon(Icons.refresh);
      expect(refreshButton, findsOneWidget);
      await tester.tap(refreshButton);
      await tester.pumpAndSettle();

      // Wait for API call to complete
      await Future.delayed(const Duration(seconds: 4));
      await tester.pumpAndSettle();
      await tester.pump();

      // Verify todos were loaded (should be 10 from the API with limit=10)
      final checkboxes = find.byType(Checkbox);
      expect(checkboxes, findsWidgets);

      // API returns 10 todos (we set limit=10 in the request)
      expect(checkboxes, findsNWidgets(10));
    });
  });
}
