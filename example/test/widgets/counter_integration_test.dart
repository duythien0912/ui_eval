import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ui_eval/ui_eval.dart';

/// Integration-style tests that verify the full counter app flow
void main() {
  group('Counter App Integration Tests', () {
    
    // Complete counter app UI JSON matching the actual bundle
    final completeCounterUi = {
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
          {
            'type': 'sizedBox',
            'height': 24.0,
          },
          {
            'type': 'row',
            'mainAxisAlignment': 'center',
            'children': [
              {
                'type': 'button',
                'text': 'Double',
                'type_': 'elevated',
                'onTap': {'action': 'double'},
              },
              {
                'type': 'sizedBox',
                'width': 16.0,
              },
              {
                'type': 'button',
                'text': 'Set to 100',
                'type_': 'text',
                'onTap': {
                  'action': 'setValue',
                  'params': {'value': 100},
                },
              },
            ],
          },
        ],
      },
    };

    Map<String, Function(Map<String, dynamic>?)> createActions(
      Map<String, dynamic> state,
      Function(String, dynamic) onStateChange,
    ) {
      return {
        'increment': (_) {
          final step = (state['step'] as num?)?.toInt() ?? 1;
          final count = (state['count'] as num?)?.toInt() ?? 0;
          onStateChange('count', count + step);
        },
        'decrement': (_) {
          final step = (state['step'] as num?)?.toInt() ?? 1;
          final count = (state['count'] as num?)?.toInt() ?? 0;
          onStateChange('count', count - step);
        },
        'reset': (_) {
          onStateChange('count', 0);
          onStateChange('history', <int>[]);
        },
        'setStep': (params) {
          final step = params?['step'] ?? params?['value'] ?? 1;
          if (step is num) {
            onStateChange('step', step.toInt());
          }
        },
        'double': (_) {
          final count = (state['count'] as num?)?.toInt() ?? 0;
          onStateChange('count', count * 2);
        },
        'setValue': (params) {
          final value = params?['value'] ?? 0;
          if (value is num) {
            onStateChange('count', value.toInt());
          }
        },
      };
    }

    testWidgets('Full counter app flow', (WidgetTester tester) async {
      var currentState = <String, dynamic>{
        'count': 0,
        'step': 1,
        'history': <int>[],
      };

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                return UIRuntimeWidget(
                  uiJson: completeCounterUi,
                  initialState: currentState,
                  actions: createActions(
                    currentState,
                    (key, value) {
                      setState(() {
                        currentState = {...currentState, key: value};
                      });
                    },
                  ),
                );
              },
            ),
          ),
        ),
      );

      await tester.pump();

      // Verify initial UI
      expect(find.text('0'), findsOneWidget);
      expect(find.text('Step: 1'), findsOneWidget);
      expect(find.byIcon(Icons.add), findsOneWidget);
      expect(find.byIcon(Icons.remove), findsOneWidget);
      expect(find.text('Reset'), findsOneWidget);
      expect(find.text('Double'), findsOneWidget);
      expect(find.text('Set to 100'), findsOneWidget);
      expect(find.byType(Slider), findsOneWidget);

      // Test increment
      await tester.tap(find.byIcon(Icons.add));
      await tester.pump();
      expect(find.text('1'), findsOneWidget);

      // Test increment again
      await tester.tap(find.byIcon(Icons.add));
      await tester.pump();
      expect(find.text('2'), findsOneWidget);

      // Test decrement
      await tester.tap(find.byIcon(Icons.remove));
      await tester.pump();
      expect(find.text('1'), findsOneWidget);

      // Test double
      await tester.tap(find.text('Double'));
      await tester.pump();
      expect(find.text('2'), findsOneWidget);

      // Test set to 100
      await tester.tap(find.text('Set to 100'));
      await tester.pump();
      expect(find.text('100'), findsOneWidget);

      // Test reset
      await tester.tap(find.text('Reset'));
      await tester.pump();
      expect(find.text('0'), findsOneWidget);
    });

    testWidgets('Step value affects increment/decrement', (WidgetTester tester) async {
      var currentState = <String, dynamic>{
        'count': 0,
        'step': 5,
        'history': <int>[],
      };

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                return UIRuntimeWidget(
                  uiJson: completeCounterUi,
                  initialState: currentState,
                  actions: createActions(
                    currentState,
                    (key, value) {
                      setState(() {
                        currentState = {...currentState, key: value};
                      });
                    },
                  ),
                );
              },
            ),
          ),
        ),
      );

      await tester.pump();

      // Verify initial step
      expect(find.text('Step: 5'), findsOneWidget);

      // Increment with step 5
      await tester.tap(find.byIcon(Icons.add));
      await tester.pump();
      expect(find.text('5'), findsOneWidget);

      // Increment again
      await tester.tap(find.byIcon(Icons.add));
      await tester.pump();
      expect(find.text('10'), findsOneWidget);

      // Decrement with step 5
      await tester.tap(find.byIcon(Icons.remove));
      await tester.pump();
      expect(find.text('5'), findsOneWidget);
    });

    testWidgets('Slider drag triggers action with correct params', (WidgetTester tester) async {
      var capturedParams = <String, dynamic>{};
      var currentState = <String, dynamic>{
        'count': 0,
        'step': 1,
        'history': <int>[],
      };

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                return UIRuntimeWidget(
                  uiJson: {
                    'type': 'column',
                    'children': [
                      {
                        'type': 'text',
                        'text': 'Step: {{state.step}}',
                      },
                      {
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
                    ],
                  },
                  initialState: currentState,
                  actions: {
                    'setStep': (params) {
                      capturedParams = params ?? {};
                      final step = params?['step'] ?? params?['value'] ?? 1;
                      if (step is num) {
                        setState(() {
                          currentState = {...currentState, 'step': step.toInt()};
                        });
                      }
                    },
                  },
                );
              },
            ),
          ),
        ),
      );

      await tester.pump();

      // Verify initial state
      expect(find.text('Step: 1'), findsOneWidget);

      // Get slider
      final slider = find.byType(Slider);
      expect(slider, findsOneWidget);

      // Drag slider to the right
      await tester.drag(slider, const Offset(100, 0));
      await tester.pump();

      // Verify that the action was called with a numeric value (not string template)
      expect(capturedParams.containsKey('step'), isTrue);
      expect(capturedParams['step'], isA<double>());
      
      // The step value should have changed from 1
      expect(capturedParams['step'], greaterThan(1.0));
    });

    testWidgets('State persists across multiple actions', (WidgetTester tester) async {
      var currentState = <String, dynamic>{
        'count': 0,
        'step': 2,
        'history': <int>[],
      };

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                return UIRuntimeWidget(
                  uiJson: completeCounterUi,
                  initialState: currentState,
                  actions: createActions(
                    currentState,
                    (key, value) {
                      setState(() {
                        currentState = {...currentState, key: value};
                      });
                    },
                  ),
                );
              },
            ),
          ),
        ),
      );

      await tester.pump();

      // Perform multiple actions
      await tester.tap(find.byIcon(Icons.add)); // count = 2
      await tester.pump();
      
      await tester.tap(find.byIcon(Icons.add)); // count = 4
      await tester.pump();
      
      await tester.tap(find.text('Double')); // count = 8
      await tester.pump();

      expect(find.text('8'), findsOneWidget);

      // Reset
      await tester.tap(find.text('Reset'));
      await tester.pump();
      expect(find.text('0'), findsOneWidget);

      // Start again
      await tester.tap(find.byIcon(Icons.add)); // count = 2
      await tester.pump();
      expect(find.text('2'), findsOneWidget);
    });
  });
}
