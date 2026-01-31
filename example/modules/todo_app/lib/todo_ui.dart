// ignore_for_file: avoid_print

import 'dart:convert';
import 'package:ui_eval/dsl_only.dart';

/// ========================================
/// STATE & ACTION ENUMS
/// ========================================
enum State {
  todos,
  newTodoTitle,
  filter,
}

enum Action {
  addTodo,
  toggleTodo,
  deleteTodo,
  updateTitle,
  setFilter,
  clearCompleted,
  fetchTodosFromApi,
}

/// ========================================
/// Todo Mini App using type-safe ui_eval DSL
/// ========================================
class TodoMiniApp {
  const TodoMiniApp();

  /// The UI program definition using type-safe DSL
  UIProgram get program => UIProgram(
    id: 'todo_app',
    name: 'Todo App',
    version: '1.0.0',
    states: [
      UIState.fromEnum(State.todos, defaultValue: [], stateType: StateType.list),
      UIState.fromEnum(State.newTodoTitle, defaultValue: '', stateType: StateType.string),
      UIState.fromEnum(State.filter, defaultValue: 'all', stateType: StateType.string),
    ],
    root: UIScaffold(
      appBar: UIAppBar(
        title: 'Todo List',
        backgroundColor: 'teal',
        foregroundColor: 'white',
        actions: [
          UIIconButton(
            icon: 'refresh',
            onTap: UIActionTrigger(action: Action.fetchTodosFromApi),
          ),
        ],
      ),
      body: UIColumn(
        children: [
          // Input area
          UIContainer(
            padding: const UIEdgeInsets.all(16),
            child: UIRow(
              children: [
                UIExpanded(
                  child: UITextField(
                    value: state[State.newTodoTitle],
                    hint: 'Add a new todo...',
                    onChanged: UIActionTrigger(
                      action: Action.updateTitle,
                      params: {'value': value},
                    ),
                  ),
                ),

                const UISizedBox(width: 8),

                UIButton(
                  text: 'Add',
                  buttonType: UIButtonType.elevated,
                  onTap: UIActionTrigger(action: Action.addTodo),
                ),
              ],
            ),
          ),

          const UIDivider(height: 1),

          // Todo list
          UIExpanded(
            child: UIListView(
              shrinkWrap: false,
              itemCount: '{{state.todos.length}}',
              itemBuilder: UIListTile(
                leading: UICheckbox(
                  value: '{{state.todos[index].completed}}',
                  onChanged: UIActionTrigger(
                    action: Action.toggleTodo,
                    params: {'index': '{{index}}'},
                  ),
                ),
                title: UIText(
                  text: '{{state.todos[index].title}}',
                ),
                trailing: UIIconButton(
                  icon: 'delete',
                  color: 'red',
                  onTap: UIActionTrigger(
                    action: Action.deleteTodo,
                    params: {'index': '{{index}}'},
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    ).toJson(),
  );
}

/// Extension to compile the DSL program to JSON string
extension TodoMiniAppCompiler on TodoMiniApp {
  /// Compile the DSL program to JSON format
  String compileToJson() {
    final json = program.toJson();
    return const JsonEncoder.withIndent('  ').convert(json);
  }
}

/// Main entry point for compilation
/// Run: dart lib/todo_ui.dart
void main() {
  const app = TodoMiniApp();
  final json = app.compileToJson();
  print(json);
}
