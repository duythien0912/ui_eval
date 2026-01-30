// ignore_for_file: avoid_print

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:ui_eval/ui_eval.dart';

/// Counter Mini App using type-safe ui_eval DSL
/// 
/// This demonstrates how developers can build UI using Dart DSL classes
/// which can then be compiled to JSON DSL for runtime loading.
/// 
/// To compile to JSON, run:
/// ```bash
/// cd example/modules/counter_app
/// dart run lib/counter_ui.dart --compile
/// ```
class CounterMiniApp extends StatelessWidget {
  const CounterMiniApp({super.key});

  /// The UI program definition using type-safe DSL
  UIProgram get program => UIProgram(
    id: 'counter_app',
    name: 'Counter App',
    version: '1.0.0',
    states: [
      UIState(key: 'count', defaultValue: 0, type: 'int'),
      UIState(key: 'step', defaultValue: 1, type: 'int'),
      UIState(key: 'history', defaultValue: [], type: 'list'),
    ],
    root: UIScaffold(
      appBar: UIAppBar(
        title: 'Counter',
        backgroundColor: 'blue',
        foregroundColor: 'white',
      ),
      body: UIColumn(
        mainAxisAlignment: UIMainAxisAlignment.center,
        crossAxisAlignment: UICrossAxisAlignment.center,
        children: [
          // Counter display
          UIText(
            text: '{{state.count}}',
            fontSize: 72,
            fontWeight: UIFontWeight.bold,
            color: 'blue',
          ),
          
          UISizedBox(height: 32),
          
          // Control buttons
          UIRow(
            mainAxisAlignment: UIMainAxisAlignment.center,
            children: [
              UIIconButton(
                icon: 'remove',
                size: 48,
                color: 'red',
                onTap: UIActionTrigger(action: 'decrement'),
              ),
              
              UISizedBox(width: 32),
              
              UIButton(
                text: 'Reset',
                buttonType: UIButtonType.outlined,
                onTap: UIActionTrigger(action: 'reset'),
              ),
              
              UISizedBox(width: 32),
              
              UIIconButton(
                icon: 'add',
                size: 48,
                color: 'green',
                onTap: UIActionTrigger(action: 'increment'),
              ),
            ],
          ),
          
          UISizedBox(height: 24),
          
          // Step display
          UIText(
            text: 'Step: {{state.step}}',
            fontSize: 16,
          ),
          
          // Step slider
          UIContainer(
            padding: UIEdgeInsets.symmetric(horizontal: 32),
            child: UISlider(
              value: '{{state.step}}',
              min: 1,
              max: 10,
              divisions: 9,
              onChanged: UIActionTrigger(
                action: 'setStep',
                params: {'step': '{{value}}'},
              ),
            ),
          ),
          
          UISizedBox(height: 24),
          
          // Additional actions
          UIRow(
            mainAxisAlignment: UIMainAxisAlignment.center,
            children: [
              UIButton(
                text: 'Double',
                buttonType: UIButtonType.elevated,
                onTap: UIActionTrigger(action: 'double'),
              ),
              
              UISizedBox(width: 16),
              
              UIButton(
                text: 'Set to 100',
                buttonType: UIButtonType.text,
                onTap: UIActionTrigger(
                  action: 'setValue',
                  params: {'value': 100},
                ),
              ),
            ],
          ),
        ],
      ),
    ).toJson(),
  );

  @override
  Widget build(BuildContext context) {
    // In development mode, we could render directly from DSL
    // For now, we use the bundle loader which loads the compiled version
    return const SizedBox.shrink();
  }
}

/// Extension to compile the DSL program to JSON string
extension CounterMiniAppCompiler on CounterMiniApp {
  /// Compile the DSL program to JSON format
  String compileToJson() {
    final json = program.toJson();
    return const JsonEncoder.withIndent('  ').convert(json);
  }
}

/// Main entry point for compilation
/// Run: dart run lib/counter_ui.dart
void main(List<String> args) {
  if (args.contains('--compile')) {
    final app = CounterMiniApp();
    final json = app.compileToJson();
    
    // Write to file
    final outputFile = 'assets/apps/counter_app.json';
    // Note: In real usage, write to the correct path
    print('Compiled JSON:');
    print(json);
    print('\n// Save this to: $outputFile');
  } else {
    print('Counter Mini App DSL');
    print('');
    print('Usage:');
    print('  dart run lib/counter_ui.dart --compile  # Compile to JSON');
    print('');
    print('The DSL program can be accessed via:');
    print('  CounterMiniApp().program');
  }
}
