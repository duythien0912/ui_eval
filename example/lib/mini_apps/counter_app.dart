// ignore_for_file: avoid_print

import 'dart:convert';
import 'dart:io';
import 'package:ui_eval/dsl.dart';

/// Counter App Definition
/// 
/// Run this to generate JSON:
/// ```bash
/// cd example
/// dart lib/mini_apps/counter_app.dart
/// ```

UIProgram buildCounterApp() {
  // Define states
  final count = states.integer('count', defaultValue: 0);

  // Define actions
  final increment = actions.action('increment');
  final decrement = actions.action('decrement');
  final reset = actions.action('reset');

  // Build UI
  return UIProgram(
    name: 'CounterApp',
    version: '1.0.0',
    metadata: {
      'title': 'Counter',
      'description': 'Simple counter example',
    },
    states: [count],
    actions: [increment, decrement, reset],
    root: UIScaffold(
      appBar: UIAppBar(
        title: 'Hiiiii Counter',
        backgroundColor: UIColor.blue,
        foregroundColor: UIColor.white,
      ),
      body: UICenter(
        child: UIColumn(
          mainAxisSize: UIMainAxisSize.min,
          children: [
            UIText(
              'You have pushed the button this many times:',
              color: UIColor.grey,
            ),
            const UISizedBox(height: 16),
            UIText.ref(
              count.ref,
              fontSize: 72,
              fontWeight: UIFontWeight.bold,
              color: UIColor.blue,
            ),
            const UISizedBox(height: 32),
            UIRow(
              mainAxisAlignment: UIMainAxisAlignment.center,
              children: [
                UIButton(
                  onPressed: decrement(),
                  backgroundColor: UIColor.red,
                  child: const UIIcon(
                    icon: UIIconData.clear,
                    color: UIColor.white,
                  ),
                ),
                const UISizedBox(width: 16),
                UIButton(
                  onPressed: reset(),
                  backgroundColor: UIColor.grey,
                  child: const UIText('RESET', color: UIColor.white),
                ),
                const UISizedBox(width: 16),
                UIButton(
                  onPressed: increment(),
                  backgroundColor: UIColor.green,
                  child: const UIIcon(
                    icon: UIIconData.add,
                    color: UIColor.white,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      floatingActionButton: UIFloatingActionButton.icon(
        onPressed: increment(),
        icon: UIIconData.add,
        backgroundColor: UIColor.blue,
        foregroundColor: UIColor.white,
      ),
    ),
  );
}

// Generate JSON when running this file directly
void main() {
  final app = buildCounterApp();
  final json = const JsonEncoder.withIndent('  ').convert(app.toJson());

  // Save to file
  final outputFile = File('assets/apps/counter_app.json');
  outputFile.createSync(recursive: true);
  outputFile.writeAsStringSync(json);

  print('✅ Counter app JSON generated:');
  print(outputFile.absolute.path);
}
