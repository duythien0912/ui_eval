import 'package:flutter_test/flutter_test.dart';
import 'package:ui_eval/src/widgets/template_processor.dart';

void main() {
  late TemplateProcessor processor;

  setUp(() {
    processor = TemplateProcessor();
    processor.initialize();
  });

  group('TemplateProcessor - Basic Templates', () {
    test('returns non-string values unchanged', () {
      expect(processor.processRefs(42, {}), equals(42));
      expect(processor.processRefs(3.14, {}), equals(3.14));
      expect(processor.processRefs(true, {}), equals(true));
      expect(processor.processRefs(null, {}), isNull);
      expect(processor.processRefs([1, 2, 3], {}), equals([1, 2, 3]));
    });

    test('returns strings without templates unchanged', () {
      expect(processor.processRefs('Hello', {}), equals('Hello'));
      expect(processor.processRefs('No template here', {}), equals('No template here'));
      expect(processor.processRefs('', {}), equals(''));
    });

    test('processes simple state reference', () {
      final state = {'count': 5};
      final result = processor.processRefs('{{state.count}}', state);

      expect(result, equals(5)); // Auto-converted to number
    });

    test('processes state reference in text', () {
      final state = {'name': 'John'};
      final result = processor.processRefs('Hello {{state.name}}', state);

      expect(result, equals('Hello John'));
    });

    test('processes multiple state references', () {
      final state = {'first': 'John', 'last': 'Doe'};
      final result = processor.processRefs('{{state.first}} {{state.last}}', state);

      expect(result, equals('John Doe'));
    });

    test('handles missing state keys gracefully', () {
      final state = {'count': 5};
      final result = processor.processRefs('{{state.missing}}', state);

      // Should return original or empty string depending on Jinja behavior
      expect(result, isA<String>());
    });
  });

  group('TemplateProcessor - Nested Paths', () {
    test('processes array index access', () {
      final state = {
        'items': ['apple', 'banana', 'orange'],
      };
      final result = processor.processRefs('{{state.items[0]}}', state);

      expect(result, equals('apple'));
    });

    test('processes map property access', () {
      final state = {
        'user': {'name': 'John', 'age': 30},
      };
      final result = processor.processRefs('{{state.user.name}}', state);

      expect(result, equals('John'));
    });

    test('processes bracket notation for maps', () {
      final state = {
        'user': {'name': 'Jane'},
      };
      final result = processor.processRefs("{{state.user['name']}}", state);

      expect(result, equals('Jane'));
    });

    test('processes complex nested path - array of maps', () {
      final state = {
        'todos': [
          {'id': 1, 'title': 'First task'},
          {'id': 2, 'title': 'Second task'},
        ],
      };
      final result = processor.processRefs("{{state.todos[0]['title']}}", state);

      expect(result, equals('First task'));
    });

    test('processes deeply nested structure', () {
      final state = {
        'data': {
          'users': [
            {
              'profile': {'name': 'Alice'}
            }
          ]
        }
      };
      final result = processor.processRefs("{{state.data.users[0].profile.name}}", state);

      expect(result, equals('Alice'));
    });
  });

  group('TemplateProcessor - Type Conversion', () {
    test('converts numeric string to number', () {
      final state = {'count': 42};
      final result = processor.processRefs('{{state.count}}', state);

      expect(result, equals(42));
      expect(result, isA<num>());
    });

    test('converts float string to number', () {
      final state = {'price': 3.14};
      final result = processor.processRefs('{{state.price}}', state);

      expect(result, equals(3.14));
      expect(result, isA<num>());
    });

    test('converts "true" to boolean true', () {
      final state = {'enabled': true};
      final result = processor.processRefs('{{state.enabled}}', state);

      expect(result, equals(true));
      expect(result, isA<bool>());
    });

    test('converts "false" to boolean false', () {
      final state = {'enabled': false};
      final result = processor.processRefs('{{state.enabled}}', state);

      expect(result, equals(false));
      expect(result, isA<bool>());
    });

    test('keeps non-numeric strings as strings', () {
      final state = {'name': 'John'};
      final result = processor.processRefs('{{state.name}}', state);

      expect(result, equals('John'));
      expect(result, isA<String>());
    });

    test('does not convert when embedded in text', () {
      final state = {'count': 5};
      final result = processor.processRefs('Count: {{state.count}}', state);

      expect(result, equals('Count: 5'));
      expect(result, isA<String>()); // Stays string when embedded
    });
  });

  group('TemplateProcessor - Special Variables', () {
    test('processes index variable in loop context', () {
      final state = {
        'index': 2,
        'items': ['a', 'b', 'c'],
      };
      final result = processor.processRefs('{{state.items[index]}}', state);

      expect(result, equals('c'));
    });

    test('makes top-level variables available', () {
      final state = {
        'index': 0,
        'items': ['first', 'second'],
      };
      // Should be accessible both as state.index and just index
      final result = processor.processRefs('{{index}}', state);

      expect(result, equals(0));
    });

    test('processes value variable', () {
      final state = {
        'value': 'test_value',
      };
      final result = processor.processRefs('{{value}}', state);

      expect(result, equals('test_value'));
    });
  });

  group('TemplateProcessor - Error Handling', () {
    test('returns original value on malformed template', () {
      final state = {'count': 5};
      final malformed = '{{state.count';
      final result = processor.processRefs(malformed, state);

      // Should gracefully handle error and return original
      expect(result, equals(malformed));
    });

    test('handles empty state gracefully', () {
      final result = processor.processRefs('{{state.count}}', {});

      expect(result, isA<String>());
    });

    test('handles null state values', () {
      final state = {'value': null};
      final result = processor.processRefs('{{state.value}}', state);

      // Should handle null gracefully
      expect(result, anyOf(isNull, equals(''), equals('{{state.value}}')));
    });

    test('handles complex template errors gracefully', () {
      final state = {'items': []};
      // Accessing out of bounds
      final result = processor.processRefs('{{state.items[99]}}', state);

      // Should not throw, should handle gracefully
      expect(result, isA<Object>());
    });
  });

  group('TemplateProcessor - Action Params', () {
    test('processes null params', () {
      final result = processor.processActionParams(null, {});
      expect(result, isNull);
    });

    test('processes empty params', () {
      final result = processor.processActionParams({}, {});
      expect(result, equals({}));
    });

    test('processes params with templates', () {
      final state = {'count': 10, 'name': 'Test'};
      final params = {
        'value': '{{state.count}}',
        'label': 'Name: {{state.name}}',
      };

      final result = processor.processActionParams(params, state);

      expect(result!['value'], equals(10)); // Converted to number
      expect(result['label'], equals('Name: Test'));
    });

    test('processes params without templates', () {
      final params = {
        'id': 42,
        'name': 'Static',
        'enabled': true,
      };

      final result = processor.processActionParams(params, {});

      expect(result!['id'], equals(42));
      expect(result['name'], equals('Static'));
      expect(result['enabled'], equals(true));
    });

    test('processes mixed params', () {
      final state = {'userId': 123};
      final params = {
        'id': '{{state.userId}}',
        'action': 'delete',
        'confirm': true,
      };

      final result = processor.processActionParams(params, state);

      expect(result!['id'], equals(123)); // Template processed and converted
      expect(result['action'], equals('delete')); // Static string
      expect(result['confirm'], equals(true)); // Static bool
    });
  });

  group('TemplateProcessor - Singleton Pattern', () {
    test('returns same instance', () {
      final instance1 = TemplateProcessor();
      final instance2 = TemplateProcessor();

      expect(identical(instance1, instance2), isTrue);
    });

    test('initialization is idempotent', () {
      final instance = TemplateProcessor();
      instance.initialize();
      instance.initialize();
      instance.initialize();

      // Should not throw or cause issues
      final result = instance.processRefs('{{state.test}}', {'test': 'value'});
      expect(result, equals('value'));
    });
  });

  group('TemplateProcessor - Real-World Scenarios', () {
    test('counter app scenario', () {
      final state = {'count': 5, 'step': 1};

      final displayText = processor.processRefs('Count: {{state.count}}', state);
      final buttonDisabled = processor.processRefs('{{state.count}}', state);

      expect(displayText, equals('Count: 5'));
      expect(buttonDisabled, equals(5));
    });

    test('todo app scenario', () {
      final state = {
        'todos': [
          {'id': 1, 'title': 'Buy milk', 'completed': false},
          {'id': 2, 'title': 'Walk dog', 'completed': true},
        ],
        'index': 0,
      };

      final title = processor.processRefs("{{state.todos[index]['title']}}", state);
      final completed = processor.processRefs("{{state.todos[index]['completed']}}", state);

      expect(title, equals('Buy milk'));
      expect(completed, equals(false));
    });

    test('user profile scenario', () {
      final state = {
        'user': {
          'name': 'Alice',
          'email': 'alice@example.com',
          'settings': {
            'theme': 'dark',
            'notifications': true,
          }
        }
      };

      final greeting = processor.processRefs('Hello, {{state.user.name}}!', state);
      final theme = processor.processRefs('{{state.user.settings.theme}}', state);
      final notifications = processor.processRefs('{{state.user.settings.notifications}}', state);

      expect(greeting, equals('Hello, Alice!'));
      expect(theme, equals('dark'));
      expect(notifications, equals(true));
    });
  });
}
