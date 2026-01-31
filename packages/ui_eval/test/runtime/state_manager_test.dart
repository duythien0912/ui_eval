import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ui_eval/src/runtime/state_manager.dart';

void main() {
  group('RiverpodStateManager', () {
    late RiverpodStateManager manager;
    late ProviderContainer container;

    setUp(() {
      manager = RiverpodStateManager();
      container = ProviderContainer();
      manager.initialize(container);
    });

    tearDown(() {
      manager.clear();
      container.dispose();
    });

    group('Initialization', () {
      test('initializes with ProviderContainer', () {
        final newManager = RiverpodStateManager();
        final newContainer = ProviderContainer();

        newManager.initialize(newContainer);

        // Should not throw
        newManager.set('test', 'value');
        expect(newManager.get('test'), equals('value'));

        newContainer.dispose();
      });

      test('operations fail gracefully without initialization', () {
        final uninitializedManager = RiverpodStateManager();

        // Should not throw, should return defaultValue
        expect(uninitializedManager.get('key', defaultValue: 'default'), equals('default'));

        // Should not throw, should do nothing
        uninitializedManager.set('key', 'value');
      });
    });

    group('Get and Set Operations', () {
      test('sets and gets string value', () {
        manager.set('name', 'John');
        expect(manager.get('name'), equals('John'));
      });

      test('sets and gets number value', () {
        manager.set('count', 42);
        expect(manager.get('count'), equals(42));
      });

      test('sets and gets boolean value', () {
        manager.set('enabled', true);
        expect(manager.get('enabled'), equals(true));
      });

      test('sets and gets list value', () {
        final list = [1, 2, 3];
        manager.set('items', list);
        expect(manager.get('items'), equals(list));
      });

      test('sets and gets map value', () {
        final map = {'key': 'value', 'count': 42};
        manager.set('data', map);
        expect(manager.get('data'), equals(map));
      });

      test('sets and gets null value', () {
        manager.set('nullable', null);
        expect(manager.get('nullable'), isNull);
      });

      test('returns default value for non-existent key', () {
        expect(manager.get('missing', defaultValue: 'default'), equals('default'));
      });

      test('updates existing value', () {
        manager.set('count', 5);
        expect(manager.get('count'), equals(5));

        manager.set('count', 10);
        expect(manager.get('count'), equals(10));
      });

      test('handles multiple keys independently', () {
        manager.set('key1', 'value1');
        manager.set('key2', 'value2');
        manager.set('key3', 'value3');

        expect(manager.get('key1'), equals('value1'));
        expect(manager.get('key2'), equals('value2'));
        expect(manager.get('key3'), equals('value3'));
      });
    });

    group('Update Operation', () {
      test('updates value with updater function', () {
        manager.set('count', 5);

        manager.update('count', (prev) => prev + 1);

        expect(manager.get('count'), equals(6));
      });

      test('updates from default value if key does not exist', () {
        manager.update('count', (prev) => (prev ?? 0) + 1, defaultValue: 0);

        expect(manager.get('count'), equals(1));
      });

      test('updates complex value', () {
        manager.set('items', [1, 2, 3]);

        manager.update('items', (prev) => [...prev, 4]);

        expect(manager.get('items'), equals([1, 2, 3, 4]));
      });

      test('updates map value', () {
        manager.set('user', {'name': 'John', 'age': 30});

        manager.update('user', (prev) => {...prev, 'age': 31});

        expect(manager.get('user')['age'], equals(31));
      });

      test('handles null previous value in updater', () {
        manager.update('value', (prev) => prev ?? 'default', defaultValue: null);

        expect(manager.get('value'), equals('default'));
      });
    });

    group('Has and Keys Operations', () {
      test('has returns false for non-existent key', () {
        expect(manager.has('missing'), isFalse);
      });

      test('has returns true after setting key', () {
        manager.set('exists', 'value');
        expect(manager.has('exists'), isTrue);
      });

      test('keys returns empty for new manager', () {
        expect(manager.keys, isEmpty);
      });

      test('keys returns all set keys', () {
        manager.set('key1', 'value1');
        manager.set('key2', 'value2');
        manager.set('key3', 'value3');

        final keys = manager.keys.toList();
        expect(keys, hasLength(3));
        expect(keys, containsAll(['key1', 'key2', 'key3']));
      });

      test('has reflects provider creation', () {
        expect(manager.has('test'), isFalse);

        manager.set('test', 'value');

        expect(manager.has('test'), isTrue);
      });
    });

    group('ToMap Operation', () {
      test('returns empty map for new manager', () {
        expect(manager.toMap(), equals({}));
      });

      test('returns all state as map', () {
        manager.set('count', 5);
        manager.set('name', 'John');
        manager.set('enabled', true);

        final map = manager.toMap();

        expect(map, equals({
          'count': 5,
          'name': 'John',
          'enabled': true,
        }));
      });

      test('toMap reflects current state', () {
        manager.set('value', 1);
        expect(manager.toMap()['value'], equals(1));

        manager.set('value', 2);
        expect(manager.toMap()['value'], equals(2));
      });

      test('toMap returns without container', () {
        final uninitializedManager = RiverpodStateManager();
        expect(uninitializedManager.toMap(), equals({}));
      });
    });

    group('Clear Operation', () {
      test('clears all state', () {
        manager.set('key1', 'value1');
        manager.set('key2', 'value2');

        expect(manager.keys, hasLength(2));

        manager.clear();

        expect(manager.keys, isEmpty);
      });

      test('state is reset after clear', () {
        manager.set('count', 5);
        manager.clear();

        expect(manager.has('count'), isFalse);
        expect(manager.get('count', defaultValue: 0), equals(0));
      });

      test('can set values after clear', () {
        manager.set('old', 'value');
        manager.clear();

        manager.set('new', 'value');

        expect(manager.has('new'), isTrue);
        expect(manager.get('new'), equals('value'));
      });
    });

    group('Listen Operation', () {
      test('listen is called when state changes', () {
        final values = <dynamic>[];

        manager.listen('count', (value) {
          values.add(value);
        }, defaultValue: 0);

        manager.set('count', 1);
        manager.set('count', 2);
        manager.set('count', 3);

        // Riverpod listeners may be async, so we test that it doesn't throw
        expect(values, isNotEmpty);
      });

      test('listen does nothing without container', () {
        final uninitializedManager = RiverpodStateManager();

        // Should not throw
        uninitializedManager.listen('key', (value) {
          fail('Should not be called');
        });
      });
    });

    group('Singleton Pattern', () {
      test('returns same instance', () {
        final instance1 = RiverpodStateManager();
        final instance2 = RiverpodStateManager();

        expect(identical(instance1, instance2), isTrue);
      });

      test('state persists across instance references', () {
        final instance1 = RiverpodStateManager();
        instance1.clear();
        final container1 = ProviderContainer();
        instance1.initialize(container1);
        instance1.set('test', 'value');

        final instance2 = RiverpodStateManager();
        expect(instance2.get('test'), equals('value'));

        container1.dispose();
      });
    });
  });

  group('StateManager (Legacy Wrapper)', () {
    late StateManager manager;
    late ProviderContainer container;

    setUp(() {
      manager = StateManager();
      container = ProviderContainer();
      manager.initialize(container);
    });

    tearDown(() {
      manager.clear();
      container.dispose();
    });

    test('delegates get to RiverpodStateManager', () {
      manager.set('key', 'value');
      expect(manager.get('key'), equals('value'));
    });

    test('delegates set to RiverpodStateManager', () {
      manager.set('count', 10);
      expect(manager.get('count'), equals(10));
    });

    test('delegates update to RiverpodStateManager', () {
      manager.set('count', 5);
      manager.update('count', (prev) => prev + 1);
      expect(manager.get('count'), equals(6));
    });

    test('delegates has to RiverpodStateManager', () {
      expect(manager.has('missing'), isFalse);
      manager.set('exists', 'value');
      expect(manager.has('exists'), isTrue);
    });

    test('delegates keys to RiverpodStateManager', () {
      manager.set('key1', 'value1');
      manager.set('key2', 'value2');

      expect(manager.keys.toList(), containsAll(['key1', 'key2']));
    });

    test('delegates toMap to RiverpodStateManager', () {
      manager.set('count', 5);
      manager.set('name', 'Test');

      expect(manager.toMap(), equals({
        'count': 5,
        'name': 'Test',
      }));
    });

    test('delegates clear to RiverpodStateManager', () {
      manager.set('key', 'value');
      manager.clear();

      expect(manager.keys, isEmpty);
    });

    test('singleton pattern works', () {
      final instance1 = StateManager();
      final instance2 = StateManager();

      expect(identical(instance1, instance2), isTrue);
    });

    test('backward compatible API', () {
      // All legacy API methods should work
      manager.set('test', 'value');
      expect(manager.get('test'), equals('value'));
      expect(manager.has('test'), isTrue);

      manager.update('test', (prev) => 'updated');
      expect(manager.get('test'), equals('updated'));

      expect(manager.keys, contains('test'));
      expect(manager.toMap()['test'], equals('updated'));

      manager.clear();
      expect(manager.has('test'), isFalse);
    });
  });

  group('StateManager - Real-World Scenarios', () {
    late StateManager manager;
    late ProviderContainer container;

    setUp(() {
      manager = StateManager();
      manager.clear(); // Clear singleton state
      container = ProviderContainer();
      manager.initialize(container);
    });

    tearDown(() {
      manager.clear();
      container.dispose();
    });

    test('counter app state management', () {
      manager.set('count', 0);
      manager.set('step', 1);

      // Increment
      manager.update('count', (prev) {
        final step = manager.get('step');
        return prev + step;
      });

      expect(manager.get('count'), equals(1));
    });

    test('todo app state management', () {
      manager.set('todos', <Map<String, dynamic>>[]);

      // Add todo
      manager.update('todos', (prev) => [
        ...prev,
        {'id': 1, 'title': 'Test', 'completed': false}
      ]);

      expect(manager.get('todos'), hasLength(1));

      // Toggle todo
      manager.update('todos', (prev) {
        final todos = List<Map<String, dynamic>>.from(prev);
        todos[0]['completed'] = true;
        return todos;
      });

      expect(manager.get('todos')[0]['completed'], isTrue);
    });

    test('module-scoped state', () {
      // Different modules can have isolated state
      manager.set('counter_app:count', 5);
      manager.set('todo_app:count', 10);

      expect(manager.get('counter_app:count'), equals(5));
      expect(manager.get('todo_app:count'), equals(10));

      // They don't interfere
      manager.set('counter_app:count', 6);
      expect(manager.get('todo_app:count'), equals(10));
    });
  });
}
