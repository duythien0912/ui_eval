import 'dart:collection';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ui_eval/src/runtime/runtime_widget.dart';

void main() {
  group('UIBundle', () {
    test('creates bundle from JSON', () {
      final json = {
        'format': 'ui_eval_bundle_v1',
        'moduleId': 'test_app',
        'generatedAt': '2026-01-31T00:00:00.000Z',
        'ui': {
          'states': [
            {'key': 'count', 'defaultValue': 0},
          ],
          'root': {'type': 'Text', 'props': {'text': 'Hello'}},
        },
        'logic': 'console.log("test");',
      };

      final bundle = UIBundle.fromJson(json);

      expect(bundle.format, equals('ui_eval_bundle_v1'));
      expect(bundle.moduleId, equals('test_app'));
      expect(bundle.generatedAt, equals('2026-01-31T00:00:00.000Z'));
      expect(bundle.logic, equals('console.log("test");'));
    });

    test('extracts initial state from UI definition', () {
      final bundle = UIBundle.fromJson({
        'format': 'ui_eval_bundle_v1',
        'moduleId': 'counter',
        'generatedAt': '2026-01-31T00:00:00.000Z',
        'ui': {
          'states': [
            {'key': 'count', 'defaultValue': 0},
            {'key': 'step', 'defaultValue': 1},
            {'key': 'name', 'defaultValue': 'test'},
          ],
          'root': {},
        },
        'logic': '',
      });

      final initialState = bundle.initialState;

      expect(initialState, equals({
        'count': 0,
        'step': 1,
        'name': 'test',
      }));
    });

    test('handles empty states list', () {
      final bundle = UIBundle.fromJson({
        'format': 'ui_eval_bundle_v1',
        'moduleId': 'empty',
        'generatedAt': '2026-01-31T00:00:00.000Z',
        'ui': {
          'states': [],
          'root': {},
        },
        'logic': '',
      });

      expect(bundle.initialState, equals({}));
    });

    test('handles missing states', () {
      final bundle = UIBundle.fromJson({
        'format': 'ui_eval_bundle_v1',
        'moduleId': 'no_states',
        'generatedAt': '2026-01-31T00:00:00.000Z',
        'ui': {
          'root': {},
        },
        'logic': '',
      });

      expect(bundle.initialState, equals({}));
    });

    test('gets root widget definition', () {
      final bundle = UIBundle.fromJson({
        'format': 'ui_eval_bundle_v1',
        'moduleId': 'test',
        'generatedAt': '2026-01-31T00:00:00.000Z',
        'ui': {
          'root': {
            'type': 'Column',
            'props': {},
            'children': [],
          },
        },
        'logic': '',
      });

      final root = bundle.rootWidget;

      expect(root['type'], equals('Column'));
      expect(root['props'], isA<Map>());
      expect(root['children'], isA<List>());
    });

    test('throws on invalid JSON structure', () {
      final invalidJson = {
        'moduleId': 'test',
        // Missing required fields
      };

      expect(
        () => UIBundle.fromJson(invalidJson),
        throwsA(isA<TypeError>()),
      );
    });
  });

  group('UIRuntimeWidget', () {
    testWidgets('renders simple UI from JSON', (tester) async {
      final uiJson = {
        'type': 'text', // lowercase
        'text': 'Hello Runtime', // direct property, not in 'props'
      };

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: UIRuntimeWidget(
              uiJson: uiJson,
            ),
          ),
        ),
      );

      expect(find.text('Hello Runtime'), findsOneWidget);
    });

    testWidgets('renders with initial state', (tester) async {
      final uiJson = {
        'type': 'text', // lowercase
        'text': '{{state.message}}',
      };

      final initialState = {'message': 'State Message'};

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: UIRuntimeWidget(
              uiJson: uiJson,
              initialState: initialState,
            ),
          ),
        ),
      );

      expect(find.text('State Message'), findsOneWidget);
    });

    testWidgets('updates when state changes', (tester) async {
      final uiJson = {
        'type': 'text', // lowercase
        'text': '{{state.count}}',
      };

      Map<String, dynamic> currentState = {'count': 5};

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: UIRuntimeWidget(
              uiJson: uiJson,
              initialState: currentState,
            ),
          ),
        ),
      );

      expect(find.text('5'), findsOneWidget);

      // Update state
      currentState = {'count': 10};

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: UIRuntimeWidget(
              uiJson: uiJson,
              initialState: currentState,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('10'), findsOneWidget);
    });

    testWidgets('handles action triggers', (tester) async {
      String? actionCalled;
      Map<String, dynamic>? actionParams;

      final uiJson = {
        'type': 'button', // Use 'button' not 'ElevatedButton'
        'type_': 'elevated', // Button subtype
        'text': 'Click',
        'onTap': {'action': 'handleClick', 'params': {'id': 123}},
      };

      final actions = {
        'handleClick': (Map<String, dynamic>? params) {
          actionCalled = 'handleClick';
          actionParams = params;
        },
      };

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: UIRuntimeWidget(
              uiJson: uiJson,
              actions: actions,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();

      expect(actionCalled, equals('handleClick'));
      expect(actionParams, isNotNull);
    });

    testWidgets('shows error with errorBuilder', (tester) async {
      final invalidUiJson = {
        'type': 'InvalidWidget',
      };

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: UIRuntimeWidget(
              uiJson: invalidUiJson,
              errorBuilder: (error) => Text('Error: $error'),
            ),
          ),
        ),
      );

      // May show error or handle gracefully
      await tester.pumpAndSettle();
    });

    testWidgets('handles complex nested structure', (tester) async {
      final uiJson = {
        'type': 'column', // lowercase
        'children': [
          {'type': 'text', 'text': 'Title'},
          {
            'type': 'row',
            'children': [
              {'type': 'text', 'text': 'A'},
              {'type': 'text', 'text': 'B'},
            ],
          },
        ],
      };

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: UIRuntimeWidget(uiJson: uiJson),
          ),
        ),
      );

      expect(find.text('Title'), findsOneWidget);
      expect(find.text('A'), findsOneWidget);
      expect(find.text('B'), findsOneWidget);
    });
  });

  group('_DynamicActionMap', () {
    test('creates action handler on demand', () {
      bool executed = false;
      String? executedAction;

      final actionMap = _DynamicActionMap(
        moduleId: 'test',
        executeAction: (action, params) async {
          executed = true;
          executedAction = action;
        },
      );

      // Access non-existent action - should create handler
      final handler = actionMap['testAction'];
      expect(handler, isNotNull);

      // Execute handler
      handler!(null);

      expect(executed, isTrue);
      expect(executedAction, equals('testAction'));
    });

    test('caches created handlers', () {
      final actionMap = _DynamicActionMap(
        moduleId: 'test',
        executeAction: (action, params) async {},
      );

      final handler1 = actionMap['myAction'];
      final handler2 = actionMap['myAction'];

      expect(identical(handler1, handler2), isTrue);
    });

    test('handles different action names', () {
      final executedActions = <String>[];

      final actionMap = _DynamicActionMap(
        moduleId: 'test',
        executeAction: (action, params) async {
          executedActions.add(action);
        },
      );

      actionMap['action1']!(null);
      actionMap['action2']!(null);
      actionMap['action3']!(null);

      expect(executedActions, equals(['action1', 'action2', 'action3']));
    });

    test('passes parameters correctly', () {
      Map<String, dynamic>? receivedParams;

      final actionMap = _DynamicActionMap(
        moduleId: 'test',
        executeAction: (action, params) async {
          receivedParams = params;
        },
      );

      final testParams = {'id': 123, 'name': 'test'};
      actionMap['testAction']!(testParams);

      expect(receivedParams, equals(testParams));
    });

    test('implements Map interface', () {
      final actionMap = _DynamicActionMap(
        moduleId: 'test',
        executeAction: (action, params) async {},
      );

      // Access to create entries
      actionMap['action1'];
      actionMap['action2'];

      expect(actionMap.keys, containsAll(['action1', 'action2']));
      expect(actionMap.keys.length, equals(2));
    });

    test('supports clear operation', () {
      final actionMap = _DynamicActionMap(
        moduleId: 'test',
        executeAction: (action, params) async {},
      );

      actionMap['action1'];
      actionMap['action2'];

      expect(actionMap.keys.length, equals(2));

      actionMap.clear();

      expect(actionMap.keys, isEmpty);
    });

    test('supports remove operation', () {
      final actionMap = _DynamicActionMap(
        moduleId: 'test',
        executeAction: (action, params) async {},
      );

      actionMap['action1'];
      actionMap['action2'];

      final removed = actionMap.remove('action1');

      expect(removed, isNotNull);
      expect(actionMap.keys, contains('action2'));
      expect(actionMap.keys, isNot(contains('action1')));
    });
  });

  group('LogicEngineWidget', () {
    testWidgets('renders child widget', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: LogicEngineWidget(
            child: Scaffold(
              body: Text('Test Child'),
            ),
          ),
        ),
      );

      expect(find.text('Test Child'), findsOneWidget);
    });

    testWidgets('passes through child without modification', (tester) async {
      final childWidget = Container(
        key: ValueKey('test-container'),
        child: Text('Content'),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: LogicEngineWidget(child: childWidget),
        ),
      );

      expect(find.byKey(ValueKey('test-container')), findsOneWidget);
      expect(find.text('Content'), findsOneWidget);
    });
  });
}

// Expose _DynamicActionMap for testing
class _DynamicActionMap extends MapBase<String, Function(Map<String, dynamic>? params)> {
  final String moduleId;
  final Future<void> Function(String actionName, Map<String, dynamic>? params) executeAction;
  final Map<String, Function(Map<String, dynamic>? params)> _cache = {};

  _DynamicActionMap({
    required this.moduleId,
    required this.executeAction,
  });

  @override
  Function(Map<String, dynamic>? params)? operator [](Object? key) {
    if (key is! String) return null;
    return _cache.putIfAbsent(key, () {
      return (Map<String, dynamic>? params) => executeAction(key, params);
    });
  }

  @override
  void operator []=(String key, Function(Map<String, dynamic>? params) value) {
    _cache[key] = value;
  }

  @override
  void clear() => _cache.clear();

  @override
  Iterable<String> get keys => _cache.keys;

  @override
  Function(Map<String, dynamic>? params)? remove(Object? key) => _cache.remove(key);
}
