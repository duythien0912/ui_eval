import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:ui_eval/src/runtime/runtime_widget.dart';

void main() {
  group('Bundle Format Tests', () {
    late File counterBundle;
    late File todoBundle;

    setUpAll(() {
      counterBundle = File('test/fixtures/counter_app.bundle');
      todoBundle = File('test/fixtures/todo_app.bundle');
    });

    test('counter_app.bundle file exists', () {
      expect(counterBundle.existsSync(), isTrue,
          reason: 'counter_app.bundle should exist in test/fixtures/');
    });

    test('todo_app.bundle file exists', () {
      expect(todoBundle.existsSync(), isTrue,
          reason: 'todo_app.bundle should exist in test/fixtures/');
    });

    test('inspect counter_app.bundle content format', () {
      final content = counterBundle.readAsStringSync();

      print('\n=== Counter App Bundle Content (first 500 chars) ===');
      print(content.substring(0, content.length > 500 ? 500 : content.length));
      print('\n=== End of Sample ===\n');

      // Check if it starts with JSON or JavaScript
      final trimmed = content.trim();
      if (trimmed.startsWith('{')) {
        print('✓ Bundle appears to be JSON format');
      } else if (trimmed.startsWith('//') || trimmed.startsWith('(') || trimmed.contains('use strict')) {
        print('✗ Bundle appears to be JavaScript format');
      }
    });

    test('attempt to parse counter_app.bundle as JSON', () {
      final content = counterBundle.readAsStringSync();

      expect(
        () => jsonDecode(content),
        throwsA(isA<FormatException>()),
        reason: 'Current bundle format is JavaScript, not JSON, so jsonDecode should fail',
      );
    });

    test('demonstrate expected UIBundle JSON structure', () {
      final expectedFormat = {
        'format': 'ui_eval_bundle_v1',
        'moduleId': 'counter_app',
        'generatedAt': DateTime.now().toIso8601String(),
        'ui': {
          'states': [
            {'key': 'count', 'defaultValue': 0},
            {'key': 'step', 'defaultValue': 1},
          ],
          'root': {
            'type': 'Column',
            'props': {},
            'children': [],
          }
        },
        'logic': 'console.log("Counter app logic");',
      };

      print('\n=== Expected UIBundle JSON Structure ===');
      print(const JsonEncoder.withIndent('  ').convert(expectedFormat));
      print('\n=== End of Expected Structure ===\n');

      // This should parse successfully
      final bundle = UIBundle.fromJson(expectedFormat);
      expect(bundle.moduleId, equals('counter_app'));
      expect(bundle.format, equals('ui_eval_bundle_v1'));
      expect(bundle.initialState['count'], equals(0));
      expect(bundle.logic, contains('Counter app logic'));
    });

    test('check bundle file sizes', () {
      final counterSize = counterBundle.lengthSync();
      final todoSize = todoBundle.lengthSync();

      print('\nBundle Sizes:');
      print('  counter_app.bundle: ${(counterSize / 1024).toStringAsFixed(2)} KB');
      print('  todo_app.bundle: ${(todoSize / 1024).toStringAsFixed(2)} KB');

      expect(counterSize, greaterThan(0));
      expect(todoSize, greaterThan(0));
    });

    test('analyze bundle content - check for JavaScript patterns', () {
      final content = counterBundle.readAsStringSync();

      final jsPatterns = {
        'IIFE wrapper': content.contains('(() =>'),
        'use strict': content.contains('"use strict"'),
        'esbuild artifacts': content.contains('__PURE__'),
        'class definitions': content.contains('class '),
        'arrow functions': content.contains('=>'),
        'module.exports': content.contains('module.exports'),
        'ES6 syntax': content.contains('const ') || content.contains('let '),
      };

      print('\nJavaScript Pattern Detection:');
      jsPatterns.forEach((pattern, found) {
        print('  $pattern: ${found ? "✓ Found" : "✗ Not found"}');
      });

      final isJavaScript = jsPatterns.values.where((v) => v).length >= 3;
      print('\nConclusion: Bundle is ${isJavaScript ? "JavaScript" : "JSON"} format');
    });

    test('compare current vs expected format', () {
      final currentContent = counterBundle.readAsStringSync();
      final currentFormat = currentContent.startsWith('{') ? 'JSON' : 'JavaScript';

      final expectedFormat = 'JSON'; // UIBundle.fromJson expects JSON

      print('\n=== Format Comparison ===');
      print('Current bundle format: $currentFormat');
      print('Expected bundle format: $expectedFormat');
      print('Match: ${currentFormat == expectedFormat ? "✓ Yes" : "✗ No"}');
      print('=========================\n');

      expect(currentFormat, isNot(equals(expectedFormat)),
          reason: 'This test documents the format mismatch issue');
    });
  });

  group('UIBundle Class Tests', () {
    test('UIBundle.fromJson parses valid JSON', () {
      final validJson = {
        'format': 'ui_eval_bundle_v1',
        'moduleId': 'test_module',
        'generatedAt': '2026-01-31T00:00:00.000Z',
        'ui': {
          'states': [
            {'key': 'count', 'defaultValue': 0},
          ],
          'root': {
            'type': 'Text',
            'props': {'text': 'Hello'},
          }
        },
        'logic': 'console.log("test");',
      };

      final bundle = UIBundle.fromJson(validJson);

      expect(bundle.moduleId, equals('test_module'));
      expect(bundle.format, equals('ui_eval_bundle_v1'));
      expect(bundle.logic, equals('console.log("test");'));
      expect(bundle.initialState, equals({'count': 0}));
      expect(bundle.rootWidget['type'], equals('Text'));
    });

    test('UIBundle.fromJson throws on invalid format', () {
      final invalidJson = {
        // Missing required fields
        'moduleId': 'test',
      };

      expect(
        () => UIBundle.fromJson(invalidJson),
        throwsA(isA<TypeError>()),
        reason: 'Missing required fields should cause type error',
      );
    });
  });
}
