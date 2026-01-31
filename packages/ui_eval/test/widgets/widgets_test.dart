import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ui_eval/src/widgets/widgets.dart';

void main() {
  group('UIWidgets.build - Basic Widgets', () {
    testWidgets('builds Text widget', (tester) async {
      final widget = UIWidgets.build(
        type: 'text', // lowercase
        def: {
          'type': 'text',
          'text': 'Hello World', // Direct property, not in 'props'
        },
        state: {},
        onAction: (name, params) async {},
        onStateChange: (key, value) {},
        getState: (key) => null,
      );

      await tester.pumpWidget(MaterialApp(home: Scaffold(body: widget)));

      expect(find.text('Hello World'), findsOneWidget);
    });

    testWidgets('builds Text with state reference', (tester) async {
      final widget = UIWidgets.build(
        type: 'text', // lowercase
        def: {
          'type': 'text',
          'text': '{{state.message}}',
        },
        state: {'message': 'Dynamic Text'},
        onAction: (name, params) async {},
        onStateChange: (key, value) {},
        getState: (key) => null,
      );

      await tester.pumpWidget(MaterialApp(home: Scaffold(body: widget)));

      expect(find.text('Dynamic Text'), findsOneWidget);
    });

    testWidgets('builds Container', (tester) async {
      final widget = UIWidgets.build(
        type: 'container', // lowercase
        def: {
          'type': 'container',
          'width': 100.0,
          'height': 100.0,
        },
        state: {},
        onAction: (name, params) async {},
        onStateChange: (key, value) {},
        getState: (key) => null,
      );

      await tester.pumpWidget(MaterialApp(home: Scaffold(body: widget)));

      final containerFinder = find.byType(Container);
      expect(containerFinder, findsWidgets);
    });

    testWidgets('builds SizedBox', (tester) async {
      final widget = UIWidgets.build(
        type: 'sizedBox', // camelCase
        def: {
          'type': 'sizedBox',
          'width': 50.0,
          'height': 50.0,
        },
        state: {},
        onAction: (name, params) async {},
        onStateChange: (key, value) {},
        getState: (key) => null,
      );

      await tester.pumpWidget(MaterialApp(home: Scaffold(body: widget)));

      expect(find.byType(SizedBox), findsWidgets);
    });
  });

  group('UIWidgets.build - Layout Widgets', () {
    testWidgets('builds Column with children', (tester) async {
      final widget = UIWidgets.build(
        type: 'column', // lowercase
        def: {
          'type': 'column',
          'children': [
            {'type': 'text', 'text': 'First'},
            {'type': 'text', 'text': 'Second'},
          ],
        },
        state: {},
        onAction: (name, params) async {},
        onStateChange: (key, value) {},
        getState: (key) => null,
      );

      await tester.pumpWidget(MaterialApp(home: Scaffold(body: widget)));

      expect(find.text('First'), findsOneWidget);
      expect(find.text('Second'), findsOneWidget);
      expect(find.byType(Column), findsOneWidget);
    });

    testWidgets('builds Row with children', (tester) async {
      final widget = UIWidgets.build(
        type: 'row', // lowercase
        def: {
          'type': 'row',
          'children': [
            {'type': 'text', 'text': 'A'},
            {'type': 'text', 'text': 'B'},
          ],
        },
        state: {},
        onAction: (name, params) async {},
        onStateChange: (key, value) {},
        getState: (key) => null,
      );

      await tester.pumpWidget(MaterialApp(home: Scaffold(body: widget)));

      expect(find.text('A'), findsOneWidget);
      expect(find.text('B'), findsOneWidget);
      expect(find.byType(Row), findsOneWidget);
    });

    testWidgets('builds Center with child', (tester) async {
      final widget = UIWidgets.build(
        type: 'center', // lowercase
        def: {
          'type': 'center',
          'child': {'type': 'text', 'text': 'Centered'},
        },
        state: {},
        onAction: (name, params) async {},
        onStateChange: (key, value) {},
        getState: (key) => null,
      );

      await tester.pumpWidget(MaterialApp(home: Scaffold(body: widget)));

      expect(find.text('Centered'), findsOneWidget);
      expect(find.byType(Center), findsOneWidget);
    });
  });

  group('UIWidgets.build - Button Widgets', () {
    testWidgets('builds ElevatedButton', (tester) async {
      bool actionCalled = false;

      final widget = UIWidgets.build(
        type: 'button', // Use 'button' not 'ElevatedButton'
        def: {
          'type': 'button',
          'type_': 'elevated', // Button subtype
          'text': 'Click Me',
          'onTap': {'action': 'testAction'},
        },
        state: {},
        onAction: (name, params) async {
          actionCalled = true;
        },
        onStateChange: (key, value) {},
        getState: (key) => null,
      );

      await tester.pumpWidget(MaterialApp(home: Scaffold(body: widget)));

      expect(find.text('Click Me'), findsOneWidget);

      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();

      expect(actionCalled, isTrue);
    });

    testWidgets('builds TextButton', (tester) async {
      final widget = UIWidgets.build(
        type: 'button', // Use 'button'
        def: {
          'type': 'button',
          'type_': 'text', // Button subtype
          'text': 'Text Button',
        },
        state: {},
        onAction: (name, params) async {},
        onStateChange: (key, value) {},
        getState: (key) => null,
      );

      await tester.pumpWidget(MaterialApp(home: Scaffold(body: widget)));

      expect(find.text('Text Button'), findsOneWidget);
      expect(find.byType(TextButton), findsOneWidget);
    });
  });

  group('UIWidgets.build - State Integration', () {
    testWidgets('reflects state changes in Text', (tester) async {
      Map<String, dynamic> currentState = {'count': 5};

      Widget buildWithState(Map<String, dynamic> state) {
        return UIWidgets.build(
          type: 'text',
          def: {
            'type': 'text',
            'text': 'Count: {{state.count}}',
          },
          state: state,
          onAction: (name, params) async {},
          onStateChange: (key, value) {
            currentState[key] = value;
          },
          getState: (key) => currentState[key],
        );
      }

      await tester.pumpWidget(MaterialApp(home: Scaffold(body: buildWithState(currentState))));
      expect(find.text('Count: 5'), findsOneWidget);

      // Update state and rebuild
      currentState = {'count': 10};
      await tester.pumpWidget(MaterialApp(home: Scaffold(body: buildWithState(currentState))));

      expect(find.text('Count: 10'), findsOneWidget);
    });
  });

  group('UIWidgets.build - Error Handling', () {
    testWidgets('returns SizedBox for unknown widget type', (tester) async {
      final widget = UIWidgets.build(
        type: 'UnknownWidget',
        def: {'type': 'UnknownWidget'},
        state: {},
        onAction: (name, params) async {},
        onStateChange: (key, value) {},
        getState: (key) => null,
      );

      await tester.pumpWidget(MaterialApp(home: Scaffold(body: widget)));

      expect(find.byType(SizedBox), findsWidgets);
    });

    testWidgets('handles missing text prop gracefully', (tester) async {
      final widget = UIWidgets.build(
        type: 'text',
        def: {
          'type': 'text',
          // No text prop - should use empty string
        },
        state: {},
        onAction: (name, params) async {},
        onStateChange: (key, value) {},
        getState: (key) => null,
      );

      await tester.pumpWidget(MaterialApp(home: Scaffold(body: widget)));

      // Should render Text widget with empty string
      expect(find.byType(Text), findsOneWidget);
    });
  });

  group('UIWidgets.build - Scaffold', () {
    testWidgets('builds Scaffold with AppBar', (tester) async {
      final widget = UIWidgets.build(
        type: 'scaffold', // lowercase
        def: {
          'type': 'scaffold',
          'appBar': {
            // Nested appBar definition
            'title': 'Test App',
          },
        },
        state: {},
        onAction: (name, params) async {},
        onStateChange: (key, value) {},
        getState: (key) => null,
      );

      await tester.pumpWidget(MaterialApp(home: widget));

      expect(find.text('Test App'), findsOneWidget);
      expect(find.byType(AppBar), findsOneWidget);
    });

    testWidgets('builds Scaffold with body', (tester) async {
      final widget = UIWidgets.build(
        type: 'scaffold', // lowercase
        def: {
          'type': 'scaffold',
          'body': {
            'type': 'text',
            'text': 'Body Content',
          },
        },
        state: {},
        onAction: (name, params) async {},
        onStateChange: (key, value) {},
        getState: (key) => null,
      );

      await tester.pumpWidget(MaterialApp(home: widget));

      expect(find.text('Body Content'), findsOneWidget);
    });
  });
}
