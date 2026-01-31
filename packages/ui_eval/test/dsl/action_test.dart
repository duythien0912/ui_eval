import 'package:flutter_test/flutter_test.dart';
import 'package:ui_eval/src/dsl/action.dart';

void main() {
  group('UIActionParam', () {
    test('creates param with all fields', () {
      final param = UIActionParam(
        name: 'value',
        type: 'int',
        required: true,
        defaultValue: 10,
      );

      expect(param.name, equals('value'));
      expect(param.type, equals('int'));
      expect(param.required, isTrue);
      expect(param.defaultValue, equals(10));
    });

    test('creates param with minimal fields', () {
      final param = UIActionParam(
        name: 'name',
        type: 'string',
      );

      expect(param.name, equals('name'));
      expect(param.type, equals('string'));
      expect(param.required, isTrue); // default
      expect(param.defaultValue, isNull);
    });

    test('creates optional param', () {
      final param = UIActionParam(
        name: 'count',
        type: 'int',
        required: false,
        defaultValue: 0,
      );

      expect(param.required, isFalse);
      expect(param.defaultValue, equals(0));
    });

    group('toJson', () {
      test('serializes param with all fields', () {
        final param = UIActionParam(
          name: 'value',
          type: 'int',
          required: false,
          defaultValue: 5,
        );

        final json = param.toJson();

        expect(json, equals({
          'name': 'value',
          'type': 'int',
          'required': false,
          'defaultValue': 5,
        }));
      });

      test('serializes param without defaultValue', () {
        final param = UIActionParam(
          name: 'name',
          type: 'string',
          required: true,
        );

        final json = param.toJson();

        expect(json, equals({
          'name': 'name',
          'type': 'string',
          'required': true,
        }));
        expect(json.containsKey('defaultValue'), isFalse);
      });
    });
  });

  group('UIAction', () {
    test('creates action with name only', () {
      final action = UIAction(name: 'submit');

      expect(action.name, equals('submit'));
      expect(action.params, isEmpty);
    });

    test('creates action with parameters', () {
      final action = UIAction(
        name: 'setValue',
        params: [
          UIActionParam(name: 'key', type: 'string'),
          UIActionParam(name: 'value', type: 'int'),
        ],
      );

      expect(action.name, equals('setValue'));
      expect(action.params.length, equals(2));
      expect(action.params[0].name, equals('key'));
      expect(action.params[1].name, equals('value'));
    });

    group('toJson', () {
      test('serializes action without params', () {
        final action = UIAction(name: 'refresh');
        final json = action.toJson();

        expect(json, equals({
          'name': 'refresh',
          'params': [],
        }));
      });

      test('serializes action with params', () {
        final action = UIAction(
          name: 'update',
          params: [
            UIActionParam(name: 'id', type: 'int', required: true),
            UIActionParam(name: 'name', type: 'string', required: false, defaultValue: ''),
          ],
        );

        final json = action.toJson();

        expect(json['name'], equals('update'));
        expect(json['params'], hasLength(2));
        expect(json['params'][0]['name'], equals('id'));
        expect(json['params'][1]['defaultValue'], equals(''));
      });
    });
  });

  group('UICommonActions', () {
    test('has predefined back action', () {
      expect(UICommonActions.back.name, equals('back'));
      expect(UICommonActions.back.params, isEmpty);
    });

    test('has predefined refresh action', () {
      expect(UICommonActions.refresh.name, equals('refresh'));
      expect(UICommonActions.refresh.params, isEmpty);
    });

    test('has predefined close action', () {
      expect(UICommonActions.close.name, equals('close'));
      expect(UICommonActions.close.params, isEmpty);
    });

    test('has predefined submit action', () {
      expect(UICommonActions.submit.name, equals('submit'));
      expect(UICommonActions.submit.params, isEmpty);
    });

    test('has predefined cancel action', () {
      expect(UICommonActions.cancel.name, equals('cancel'));
      expect(UICommonActions.cancel.params, isEmpty);
    });

    test('all common actions are const', () {
      // Should be compile-time constants
      const action1 = UICommonActions.back;
      const action2 = UICommonActions.refresh;

      expect(action1.name, equals('back'));
      expect(action2.name, equals('refresh'));
    });
  });
}
