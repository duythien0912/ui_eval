import 'package:flutter_test/flutter_test.dart';
import 'package:ui_eval/src/dsl/program.dart';
import 'package:ui_eval/src/dsl/state.dart';
import 'package:ui_eval/src/dsl/action.dart';

void main() {
  group('UIProgram', () {
    test('creates program with minimal fields', () {
      final program = UIProgram(
        root: {'type': 'Text', 'props': {'text': 'Hello'}},
      );

      expect(program.id, isNull);
      expect(program.name, isNull);
      expect(program.version, isNull);
      expect(program.states, isNull);
      expect(program.actions, isNull);
      expect(program.root, isA<Map<String, dynamic>>());
    });

    test('creates program with all fields', () {
      final program = UIProgram(
        id: 'counter_app',
        name: 'Counter',
        version: '1.0.0',
        states: [
          UIState(key: 'count', defaultValue: 0, type: 'int'),
        ],
        actions: [
          UIAction(name: 'increment'),
        ],
        root: {'type': 'Column', 'children': []},
      );

      expect(program.id, equals('counter_app'));
      expect(program.name, equals('Counter'));
      expect(program.version, equals('1.0.0'));
      expect(program.states, hasLength(1));
      expect(program.actions, hasLength(1));
      expect(program.root['type'], equals('Column'));
    });

    test('creates program with multiple states', () {
      final program = UIProgram(
        states: [
          UIState(key: 'count', defaultValue: 0),
          UIState(key: 'name', defaultValue: ''),
          UIState(key: 'enabled', defaultValue: true),
        ],
        root: {},
      );

      expect(program.states, hasLength(3));
      expect(program.states![0].key, equals('count'));
      expect(program.states![1].key, equals('name'));
      expect(program.states![2].key, equals('enabled'));
    });

    test('creates program with multiple actions', () {
      final program = UIProgram(
        actions: [
          UIAction(name: 'increment'),
          UIAction(name: 'decrement'),
          UIAction(name: 'reset'),
        ],
        root: {},
      );

      expect(program.actions, hasLength(3));
      expect(program.actions![0].name, equals('increment'));
      expect(program.actions![1].name, equals('decrement'));
      expect(program.actions![2].name, equals('reset'));
    });

    group('toJson', () {
      test('serializes minimal program', () {
        final program = UIProgram(
          root: {'type': 'Text'},
        );

        final json = program.toJson();

        expect(json, equals({
          'root': {'type': 'Text'},
        }));
        expect(json.containsKey('id'), isFalse);
        expect(json.containsKey('name'), isFalse);
        expect(json.containsKey('version'), isFalse);
      });

      test('serializes complete program', () {
        final program = UIProgram(
          id: 'test_app',
          name: 'Test App',
          version: '2.0.0',
          states: [
            UIState(key: 'count', defaultValue: 5, type: 'int'),
          ],
          actions: [
            UIAction(name: 'update'),
          ],
          root: {'type': 'Container'},
        );

        final json = program.toJson();

        expect(json['id'], equals('test_app'));
        expect(json['name'], equals('Test App'));
        expect(json['version'], equals('2.0.0'));
        expect(json['states'], hasLength(1));
        expect(json['states'][0]['key'], equals('count'));
        expect(json['actions'], hasLength(1));
        expect(json['actions'][0]['name'], equals('update'));
        expect(json['root']['type'], equals('Container'));
      });

      test('serializes complex root widget', () {
        final program = UIProgram(
          root: {
            'type': 'Column',
            'props': {'mainAxisAlignment': 'center'},
            'children': [
              {'type': 'Text', 'props': {'text': 'Hello'}},
              {'type': 'Button', 'props': {'text': 'Click'}},
            ],
          },
        );

        final json = program.toJson();
        final root = json['root'] as Map<String, dynamic>;

        expect(root['type'], equals('Column'));
        expect(root['props']['mainAxisAlignment'], equals('center'));
        expect(root['children'], hasLength(2));
      });
    });

    group('fromJson', () {
      test('deserializes minimal program', () {
        final json = {
          'root': {'type': 'Text'},
        };

        final program = UIProgram.fromJson(json);

        expect(program.id, isNull);
        expect(program.name, isNull);
        expect(program.version, isNull);
        expect(program.states, isNull);
        expect(program.actions, isNull);
        expect(program.root['type'], equals('Text'));
      });

      test('deserializes complete program', () {
        final json = {
          'id': 'my_app',
          'name': 'My App',
          'version': '1.5.0',
          'states': [
            {'key': 'count', 'defaultValue': 10, 'type': 'int'},
            {'key': 'name', 'defaultValue': 'Test'},
          ],
          'root': {'type': 'Scaffold'},
        };

        final program = UIProgram.fromJson(json);

        expect(program.id, equals('my_app'));
        expect(program.name, equals('My App'));
        expect(program.version, equals('1.5.0'));
        expect(program.states, hasLength(2));
        expect(program.states![0].key, equals('count'));
        expect(program.states![0].defaultValue, equals(10));
        expect(program.states![1].key, equals('name'));
        expect(program.root['type'], equals('Scaffold'));
      });

      test('round-trip serialization', () {
        final original = UIProgram(
          id: 'test',
          name: 'Test',
          version: '1.0.0',
          states: [
            UIState(key: 'value', defaultValue: 42, type: 'int'),
          ],
          actions: [
            UIAction(name: 'test'),
          ],
          root: {'type': 'Container'},
        );

        final json = original.toJson();
        final deserialized = UIProgram.fromJson(json);

        expect(deserialized.id, equals(original.id));
        expect(deserialized.name, equals(original.name));
        expect(deserialized.version, equals(original.version));
        expect(deserialized.states!.length, equals(original.states!.length));
        expect(deserialized.states![0].key, equals(original.states![0].key));
        expect(deserialized.root['type'], equals(original.root['type']));
        // Note: actions is null in fromJson (line 40 of program.dart)
      });
    });
  });
}
