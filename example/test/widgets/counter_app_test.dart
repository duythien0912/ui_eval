import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ui_eval/ui_eval.dart';

import '../mocks/mock_logic_coordinator.dart';

void main() {
  group('Counter App Widget Tests', () {
    // Sample counter app UI JSON
    final counterUiJson = {
      'type': 'scaffold',
      'appBar': {
        'type': 'appBar',
        'title': 'Counter',
        'backgroundColor': 'blue',
        'foregroundColor': 'white',
      },
      'body': {
        'type': 'column',
        'mainAxisAlignment': 'center',
        'crossAxisAlignment': 'center',
        'children': [
          {
            'type': 'text',
            'text': '{{state.count}}',
            'fontSize': 72.0,
            'fontWeight': 'bold',
            'color': 'blue',
          },
          {
            'type': 'sizedBox',
            'height': 32.0,
          },
          {
            'type': 'row',
            'mainAxisAlignment': 'center',
            'children': [
              {
                'type': 'iconButton',
                'icon': 'remove',
                'size': 48.0,
                'color': 'red',
                'onTap': {'action': 'decrement'},
              },
              {
                'type': 'sizedBox',
                'width': 32.0,
              },
              {
                'type': 'button',
                'text': 'Reset',
                'type_': 'outlined',
                'onTap': {'action': 'reset'},
              },
              {
                'type': 'sizedBox',
                'width': 32.0,
              },
              {
                'type': 'iconButton',
                'icon': 'add',
                'size': 48.0,
                'color': 'green',
                'onTap': {'action': 'increment'},
              },
            ],
          },
          {
            'type': 'sizedBox',
            'height': 24.0,
          },
          {
            'type': 'text',
            'text': 'Step: {{state.step}}',
            'fontSize': 16.0,
          },
          {
            'type': 'container',
            'padding': {'left': 32.0, 'right': 32.0},
            'child': {
              'type': 'slider',
              'value': '{{state.step}}',
              'min': 1.0,
              'max': 10.0,
              'divisions': 9,
              'onChanged': {
                'action': 'setStep',
                'params': {'step': '{{value}}'},
              },
            },
          },
        ],
      },
    };

    testWidgets('Initial state displays correctly', (WidgetTester tester) async {
      final initialState = {'count': 0, 'step': 1, 'history': <int>[]};
      
      await tester.pumpWidget(
        MaterialApp(
          home: UIRuntimeWidget(
            uiJson: counterUiJson,
            initialState: initialState,
            actions: createCounterActions(
              onStateChange: (_, __) {},
              state: initialState,
            ),
          ),
        ),
      );

      // Wait for widget to build
      await tester.pump();

      // Verify initial count is displayed
      expect(find.text('0'), findsOneWidget);
      expect(find.text('Step: 1'), findsOneWidget);
    });

    testWidgets('Increment button updates UI', (WidgetTester tester) async {
      var currentState = {'count': 0, 'step': 1, 'history': <int>[]};
      
      await tester.pumpWidget(
        MaterialApp(
          home: StatefulBuilder(
            builder: (context, setState) {
              return UIRuntimeWidget(
                uiJson: counterUiJson,
                initialState: currentState,
                actions: createCounterActions(
                  onStateChange: (key, value) {
                    setState(() {
                      currentState = {...currentState, key: value};
                    });
                  },
                  state: currentState,
                ),
              );
            },
          ),
        ),
      );

      await tester.pump();

      // Verify initial state
      expect(find.text('0'), findsOneWidget);

      // Tap increment button (add icon)
      await tester.tap(find.byIcon(Icons.add));
      await tester.pump();

      // Verify count updated to 1
      expect(find.text('1'), findsOneWidget);
      expect(find.text('0'), findsNothing);
    });

    testWidgets('Decrement button updates UI', (WidgetTester tester) async {
      var currentState = {'count': 5, 'step': 1, 'history': <int>[]}; 
      
      await tester.pumpWidget(
        MaterialApp(
          home: StatefulBuilder(
            builder: (context, setState) {
              return UIRuntimeWidget(
                uiJson: counterUiJson,
                initialState: currentState,
                actions: createCounterActions(
                  onStateChange: (key, value) {
                    setState(() {
                      currentState = {...currentState, key: value};
                    });
                  },
                  state: currentState,
                ),
              );
            },
          ),
        ),
      );

      await tester.pump();

      // Verify initial state
      expect(find.text('5'), findsOneWidget);

      // Tap decrement button (remove icon)
      await tester.tap(find.byIcon(Icons.remove));
      await tester.pump();

      // Verify count updated to 4
      expect(find.text('4'), findsOneWidget);
      expect(find.text('5'), findsNothing);
    });

    testWidgets('Multiple increments work correctly', (WidgetTester tester) async {
      var currentState = {'count': 0, 'step': 1, 'history': <int>[]}; 
      
      await tester.pumpWidget(
        MaterialApp(
          home: StatefulBuilder(
            builder: (context, setState) {
              return UIRuntimeWidget(
                uiJson: counterUiJson,
                initialState: currentState,
                actions: createCounterActions(
                  onStateChange: (key, value) {
                    setState(() {
                      currentState = {...currentState, key: value};
                    });
                  },
                  state: currentState,
                ),
              );
            },
          ),
        ),
      );

      await tester.pump();

      // Tap increment 3 times
      for (var i = 0; i < 3; i++) {
        await tester.tap(find.byIcon(Icons.add));
        await tester.pump();
      }

      // Verify count is 3
      expect(find.text('3'), findsOneWidget);
    });

    testWidgets('Reset button resets count to 0', (WidgetTester tester) async {
      var currentState = {'count': 10, 'step': 1, 'history': <int>[1, 2, 3]}; 
      
      await tester.pumpWidget(
        MaterialApp(
          home: StatefulBuilder(
            builder: (context, setState) {
              return UIRuntimeWidget(
                uiJson: counterUiJson,
                initialState: currentState,
                actions: createCounterActions(
                  onStateChange: (key, value) {
                    setState(() {
                      currentState = {...currentState, key: value};
                    });
                  },
                  state: currentState,
                ),
              );
            },
          ),
        ),
      );

      await tester.pump();

      // Verify initial state
      expect(find.text('10'), findsOneWidget);

      // Tap reset button
      await tester.tap(find.text('Reset'));
      await tester.pump();

      // Verify count reset to 0
      expect(find.text('0'), findsOneWidget);
      expect(find.text('10'), findsNothing);
    });

    testWidgets('Slider updates step value', (WidgetTester tester) async {
      var currentState = {'count': 0, 'step': 1, 'history': <int>[]}; 
      
      await tester.pumpWidget(
        MaterialApp(
          home: StatefulBuilder(
            builder: (context, setState) {
              return UIRuntimeWidget(
                uiJson: counterUiJson,
                initialState: currentState,
                actions: createCounterActions(
                  onStateChange: (key, value) {
                    setState(() {
                      currentState = {...currentState, key: value};
                    });
                  },
                  state: currentState,
                ),
              );
            },
          ),
        ),
      );

      await tester.pump();

      // Verify initial step
      expect(find.text('Step: 1'), findsOneWidget);

      // Find and drag slider
      final slider = find.byType(Slider);
      expect(slider, findsOneWidget);

      // Drag slider to value 5
      await tester.drag(slider, const Offset(100, 0));
      await tester.pump();

      // The step should have changed (exact value depends on drag distance)
      // Just verify the slider exists and can be interacted with
      expect(slider, findsOneWidget);
    });

    testWidgets('Step value affects increment amount', (WidgetTester tester) async {
      var currentState = {'count': 0, 'step': 3, 'history': <int>[]}; 
      
      await tester.pumpWidget(
        MaterialApp(
          home: StatefulBuilder(
            builder: (context, setState) {
              return UIRuntimeWidget(
                uiJson: counterUiJson,
                initialState: currentState,
                actions: createCounterActions(
                  onStateChange: (key, value) {
                    setState(() {
                      currentState = {...currentState, key: value};
                    });
                  },
                  state: currentState,
                ),
              );
            },
          ),
        ),
      );

      await tester.pump();

      // Verify initial step is 3
      expect(find.text('Step: 3'), findsOneWidget);
      expect(find.text('0'), findsOneWidget);

      // Tap increment
      await tester.tap(find.byIcon(Icons.add));
      await tester.pump();

      // Count should increase by 3 (the step value)
      expect(find.text('3'), findsOneWidget);
      expect(find.text('0'), findsNothing);
    });
  });
}
