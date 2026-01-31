import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ui_eval/ui_eval.dart';

void main() {
  group('UIBundleLoader Tests', () {
    const testBundle = '''
{
  "format": "ui_eval_bundle_v1",
  "moduleId": "test_counter",
  "generatedAt": "2024-01-01T00:00:00.000Z",
  "ui": {
    "id": "test_counter",
    "name": "Test Counter",
    "version": "1.0.0",
    "states": [
      {"key": "count", "defaultValue": 0, "type": "int"},
      {"key": "step", "defaultValue": 1, "type": "int"}
    ],
    "root": {
      "type": "column",
      "mainAxisAlignment": "center",
      "crossAxisAlignment": "center",
      "children": [
        {
          "type": "text",
          "text": "{{state.count}}",
          "fontSize": 72
        },
        {
          "type": "row",
          "mainAxisAlignment": "center",
          "children": [
            {
              "type": "iconButton",
              "icon": "remove",
              "onTap": {"action": "decrement"}
            },
            {
              "type": "iconButton",
              "icon": "add",
              "onTap": {"action": "increment"}
            }
          ]
        },
        {
          "type": "text",
          "text": "Step: {{state.step}}"
        },
        {
          "type": "slider",
          "value": "{{state.step}}",
          "min": 1,
          "max": 10,
          "divisions": 9,
          "onChanged": {
            "action": "setStep",
            "params": {"step": "{{value}}"}
          }
        }
      ]
    }
  },
  "logic": "console.log('Test logic loaded');"
}
''';

    setUpAll(() {
      // Setup mock asset bundle
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMessageHandler('flutter/assets', (message) async {
        final key = message?.toString() ?? '';
        if (key.contains('test_bundle.json')) {
          return ByteData.sublistView(
            Uint8List.fromList(testBundle.codeUnits),
          );
        }
        return null;
      });
    });

    tearDownAll(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMessageHandler('flutter/assets', null);
    });

    testWidgets('UIRuntimeWidget updates when initialState changes',
        (WidgetTester tester) async {
      // This test verifies the didUpdateWidget fix
      var currentState = {'count': 0, 'step': 1};
      
      await tester.pumpWidget(
        MaterialApp(
          home: StatefulBuilder(
            builder: (context, setState) {
              return UIRuntimeWidget(
                uiJson: {
                  'type': 'column',
                  'children': [
                    {
                      'type': 'text',
                      'text': '{{state.count}}',
                    },
                    {
                      'type': 'iconButton',
                      'icon': 'add',
                      'onTap': {
                        'action': 'increment',
                      },
                    },
                  ],
                },
                initialState: currentState,
                actions: {
                  'increment': (params) {
                    setState(() {
                      currentState = {
                        ...currentState,
                        'count': (currentState['count'] as int) + 1,
                      };
                    });
                  },
                },
              );
            },
          ),
        ),
      );

      await tester.pump();

      // Verify initial state
      expect(find.text('0'), findsOneWidget);

      // Tap increment
      await tester.tap(find.byIcon(Icons.add));
      await tester.pump();

      // The StatefulBuilder rebuilds with new initialState
      // UIRuntimeWidget should update via didUpdateWidget
      expect(find.text('1'), findsOneWidget);
    });

    testWidgets('Slider template value processing', (WidgetTester tester) async {
      var receivedParams = <String, dynamic>{};
      
      await tester.pumpWidget(
        MaterialApp(
          home: UIRuntimeWidget(
            uiJson: {
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
            initialState: {'step': 5},
            actions: {
              'setStep': (params) {
                receivedParams = params ?? {};
              },
            },
          ),
        ),
      );

      await tester.pump();

      // Find slider and drag it
      final slider = find.byType(Slider);
      expect(slider, findsOneWidget);

      // Get initial slider position
      final initialSlider = tester.widget<Slider>(slider);
      expect(initialSlider.value, 5.0);

      // Drag to change value
      await tester.drag(slider, const Offset(50, 0));
      await tester.pump();

      // Verify that the action was called with the correct params
      // The {{value}} template should have been replaced with actual value
      expect(receivedParams.containsKey('step'), isTrue);
      expect(receivedParams['step'], isA<double>());
    });

    testWidgets('State updates propagate to nested widgets',
        (WidgetTester tester) async {
      var currentState = {'count': 0, 'step': 1};
      
      await tester.pumpWidget(
        MaterialApp(
          home: StatefulBuilder(
            builder: (context, setState) {
              return UIRuntimeWidget(
                uiJson: {
                  'type': 'column',
                  'children': [
                    {
                      'type': 'container',
                      'child': {
                        'type': 'text',
                        'text': 'Count: {{state.count}}',
                      },
                    },
                    {
                      'type': 'container',
                      'padding': {'all': 16.0},
                      'child': {
                        'type': 'row',
                        'children': [
                          {
                            'type': 'iconButton',
                            'icon': 'add',
                            'onTap': {'action': 'increment'},
                          },
                        ],
                      },
                    },
                  ],
                },
                initialState: currentState,
                actions: {
                  'increment': (params) {
                    setState(() {
                      currentState = {
                        ...currentState,
                        'count': (currentState['count'] as int) + 1,
                      };
                    });
                  },
                },
              );
            },
          ),
        ),
      );

      await tester.pump();

      // Verify initial nested text
      expect(find.text('Count: 0'), findsOneWidget);

      // Tap increment button in nested container
      await tester.tap(find.byIcon(Icons.add));
      await tester.pump();

      // Verify nested text updated
      expect(find.text('Count: 1'), findsOneWidget);
    });
  });
}
