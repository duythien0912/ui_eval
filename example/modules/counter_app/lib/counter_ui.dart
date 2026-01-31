// ignore_for_file: avoid_print

import 'dart:convert';
import 'package:ui_eval/dsl_only.dart';

/// ========================================
/// STATE & ACTION ENUMS
/// ========================================
enum State {
  count,
  step,
  history,
}

enum Action {
  increment,
  decrement,
  reset,
  double,
  setValue,
  setStep,
}

/// ========================================
/// Counter Mini App using type-safe ui_eval DSL
/// ========================================
class CounterMiniApp {
  const CounterMiniApp();

  /// The UI program definition using type-safe DSL
  UIProgram get program => UIProgram(
        id: 'counter_app',
        name: 'Counter App',
        version: '1.0.0',
        states: [
          UIState.fromEnum(State.count,
              defaultValue: 0, stateType: StateType.int),
          UIState.fromEnum(State.step,
              defaultValue: 1, stateType: StateType.int),
          UIState.fromEnum(State.history,
              defaultValue: [], stateType: StateType.list),
        ],
        root: UIScaffold(
          appBar: const UIAppBar(
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
                text: state[State.count].toString(),
                fontSize: 72,
                fontWeight: UIFontWeight.bold,
                color: 'blue',
              ),

              const UISizedBox(height: 32),

              // Control buttons
              UIRow(
                mainAxisAlignment: UIMainAxisAlignment.center,
                children: [
                  UIIconButton(
                    icon: 'remove',
                    size: 48,
                    color: 'red',
                    onTap: UIActionTrigger(action: Action.decrement),
                  ),
                  const UISizedBox(width: 32),
                  UIButton(
                    text: 'Reset',
                    buttonType: UIButtonType.outlined,
                    onTap: UIActionTrigger(action: Action.reset),
                  ),
                  const UISizedBox(width: 32),
                  UIIconButton(
                    icon: 'add',
                    size: 48,
                    color: 'green',
                    onTap: UIActionTrigger(action: Action.increment),
                  ),
                ],
              ),

              const UISizedBox(height: 24),

              // Step display
              UIText(
                text: 'Step: ${state[State.step]}',
                fontSize: 16,
              ),

              // Step slider
              UIContainer(
                padding: const UIEdgeInsets.symmetric(horizontal: 32),
                child: UISlider(
                  value: state[State.step].toString(),
                  min: 1,
                  max: 10,
                  divisions: 9,
                  onChanged: UIActionTrigger(
                    action: Action.setStep,
                    params: {'step': value},
                  ),
                ),
              ),

              const UISizedBox(height: 24),

              // Additional actions
              UIRow(
                mainAxisAlignment: UIMainAxisAlignment.center,
                children: [
                  UIButton(
                    text: 'Double',
                    buttonType: UIButtonType.elevated,
                    onTap: UIActionTrigger(action: Action.double),
                  ),
                  const UISizedBox(width: 16),
                  UIButton(
                    text: 'Set to 100',
                    buttonType: UIButtonType.text,
                    onTap: UIActionTrigger(
                      action: Action.setValue,
                      params: {'value': 100},
                    ),
                  ),
                ],
              ),
            ],
          ),
        ).toJson(),
      );
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
/// Run: dart lib/counter_ui.dart
void main() {
  const app = CounterMiniApp();
  final json = app.compileToJson();
  print(json);
}
