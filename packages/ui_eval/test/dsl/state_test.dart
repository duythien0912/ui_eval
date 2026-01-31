import 'package:flutter_test/flutter_test.dart';
import 'package:ui_eval/src/dsl/state.dart';

// Test enum for UIState.fromEnum test
enum AppState { count, step }

void main() {
  group('StateType Enum', () {
    test('has correct string values', () {
      expect(StateType.string.value, equals('string'));
      expect(StateType.int.value, equals('int'));
      expect(StateType.double.value, equals('double'));
      expect(StateType.bool.value, equals('bool'));
      expect(StateType.list.value, equals('list'));
      expect(StateType.map.value, equals('map'));
    });

    test('contains all expected types', () {
      expect(StateType.values.length, equals(6));
    });
  });

  group('UIState', () {
    test('creates state with all fields', () {
      final state = UIState(
        key: 'count',
        defaultValue: 0,
        type: 'int',
        description: 'Counter value',
      );

      expect(state.key, equals('count'));
      expect(state.defaultValue, equals(0));
      expect(state.type, equals('int'));
      expect(state.description, equals('Counter value'));
    });

    test('creates state with minimal fields', () {
      final state = UIState(
        key: 'name',
        defaultValue: 'John',
      );

      expect(state.key, equals('name'));
      expect(state.defaultValue, equals('John'));
      expect(state.type, isNull);
      expect(state.description, isNull);
    });

    test('creates state from enum', () {
      final state = UIState.fromEnum(
        AppState.count,
        defaultValue: 5,
        stateType: StateType.int,
        description: 'Test counter',
      );

      expect(state.key, equals('count'));
      expect(state.defaultValue, equals(5));
      expect(state.type, equals('int'));
      expect(state.description, equals('Test counter'));
    });

    test('supports different default value types', () {
      final stringState = UIState(key: 's', defaultValue: 'text');
      final intState = UIState(key: 'i', defaultValue: 42);
      final doubleState = UIState(key: 'd', defaultValue: 3.14);
      final boolState = UIState(key: 'b', defaultValue: true);
      final listState = UIState(key: 'l', defaultValue: [1, 2, 3]);
      final mapState = UIState(key: 'm', defaultValue: {'key': 'value'});

      expect(stringState.defaultValue, isA<String>());
      expect(intState.defaultValue, isA<int>());
      expect(doubleState.defaultValue, isA<double>());
      expect(boolState.defaultValue, isA<bool>());
      expect(listState.defaultValue, isA<List>());
      expect(mapState.defaultValue, isA<Map>());
    });

    group('toJson', () {
      test('serializes state with all fields', () {
        final state = UIState(
          key: 'count',
          defaultValue: 10,
          type: 'int',
          description: 'Counter',
        );

        final json = state.toJson();

        expect(json, equals({
          'key': 'count',
          'defaultValue': 10,
          'type': 'int',
          'description': 'Counter',
        }));
      });

      test('serializes state with minimal fields', () {
        final state = UIState(
          key: 'name',
          defaultValue: 'Test',
        );

        final json = state.toJson();

        expect(json, equals({
          'key': 'name',
          'defaultValue': 'Test',
        }));
        expect(json.containsKey('type'), isFalse);
        expect(json.containsKey('description'), isFalse);
      });

      test('serializes complex default values', () {
        final listState = UIState(
          key: 'items',
          defaultValue: [1, 2, 3],
          type: 'list',
        );

        final mapState = UIState(
          key: 'user',
          defaultValue: {'name': 'John', 'age': 30},
          type: 'map',
        );

        expect(listState.toJson()['defaultValue'], equals([1, 2, 3]));
        expect(mapState.toJson()['defaultValue'], equals({'name': 'John', 'age': 30}));
      });
    });

    group('fromJson', () {
      test('deserializes state with all fields', () {
        final json = {
          'key': 'count',
          'defaultValue': 5,
          'type': 'int',
          'description': 'Test',
        };

        final state = UIState.fromJson(json);

        expect(state.key, equals('count'));
        expect(state.defaultValue, equals(5));
        expect(state.type, equals('int'));
        expect(state.description, equals('Test'));
      });

      test('deserializes state with minimal fields', () {
        final json = {
          'key': 'name',
          'defaultValue': 'John',
        };

        final state = UIState.fromJson(json);

        expect(state.key, equals('name'));
        expect(state.defaultValue, equals('John'));
        expect(state.type, isNull);
        expect(state.description, isNull);
      });

      test('round-trip serialization', () {
        final original = UIState(
          key: 'test',
          defaultValue: 42,
          type: 'int',
          description: 'Test state',
        );

        final json = original.toJson();
        final deserialized = UIState.fromJson(json);

        expect(deserialized.key, equals(original.key));
        expect(deserialized.defaultValue, equals(original.defaultValue));
        expect(deserialized.type, equals(original.type));
        expect(deserialized.description, equals(original.description));
      });
    });
  });

  group('UIStates', () {
    test('creates with empty list', () {
      final states = UIStates([]);
      expect(states.states.length, equals(0));
    });

    test('creates with multiple states', () {
      final states = UIStates([
        UIState(key: 'count', defaultValue: 0),
        UIState(key: 'name', defaultValue: ''),
      ]);

      expect(states.states.length, equals(2));
      expect(states.states[0].key, equals('count'));
      expect(states.states[1].key, equals('name'));
    });

    group('toDefaults', () {
      test('returns empty map for empty states', () {
        final states = UIStates([]);
        expect(states.toDefaults(), equals({}));
      });

      test('returns map of default values', () {
        final states = UIStates([
          UIState(key: 'count', defaultValue: 0),
          UIState(key: 'name', defaultValue: 'John'),
          UIState(key: 'enabled', defaultValue: true),
        ]);

        final defaults = states.toDefaults();

        expect(defaults, equals({
          'count': 0,
          'name': 'John',
          'enabled': true,
        }));
      });

      test('handles complex default values', () {
        final states = UIStates([
          UIState(key: 'items', defaultValue: [1, 2, 3]),
          UIState(key: 'user', defaultValue: {'id': 1, 'name': 'Test'}),
        ]);

        final defaults = states.toDefaults();

        expect(defaults['items'], equals([1, 2, 3]));
        expect(defaults['user'], equals({'id': 1, 'name': 'Test'}));
      });
    });

    group('toJson', () {
      test('returns empty list for empty states', () {
        final states = UIStates([]);
        expect(states.toJson(), equals([]));
      });

      test('serializes all states', () {
        final states = UIStates([
          UIState(key: 'count', defaultValue: 0, type: 'int'),
          UIState(key: 'name', defaultValue: 'Test', type: 'string'),
        ]);

        final json = states.toJson();

        expect(json.length, equals(2));
        expect(json[0], equals({
          'key': 'count',
          'defaultValue': 0,
          'type': 'int',
        }));
        expect(json[1], equals({
          'key': 'name',
          'defaultValue': 'Test',
          'type': 'string',
        }));
      });
    });
  });
}
