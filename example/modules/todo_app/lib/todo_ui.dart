// ignore_for_file: avoid_print

import 'dart:convert';
import 'package:ui_eval/dsl_only.dart';

/// Todo Mini App using type-safe ui_eval DSL
/// 
/// This file defines the UI using type-safe Dart DSL classes.
/// 
/// Build command (run from example/ directory):
///   cd scripts && node build.js todo_app
/// 
/// Or build all:
///   cd scripts && node build.js
/// 
/// The DSL is auto-compiled to JSON and bundled with TypeScript logic.
class TodoMiniApp {
  const TodoMiniApp();

  /// The UI program definition using type-safe DSL
  UIProgram get program => UIProgram(
    id: 'todo_app',
    name: 'Todo App',
    version: '1.0.0',
    states: [
      UIState(key: 'todos', defaultValue: [], type: 'list'),
      UIState(key: 'newTodoTitle', defaultValue: '', type: 'string'),
      UIState(key: 'filter', defaultValue: 'all', type: 'string'),
    ],
    root: UIScaffold(
      appBar: UIAppBar(
        title: 'Todo List',
        backgroundColor: 'teal',
        foregroundColor: 'white',
        actions: [
          UIIconButton(
            icon: 'refresh',
            onTap: UIActionTrigger(action: 'fetchTodosFromApi'),
          ),
        ],
      ),
      body: UIColumn(
        children: [
          // Input area
          UIContainer(
            padding: UIEdgeInsets.all(16),
            child: UIRow(
              children: [
                UIExpanded(
                  child: UITextField(
                    value: '{{state.newTodoTitle}}',
                    hint: 'Add a new todo...',
                    onChanged: UIActionTrigger(
                      action: 'updateTitle',
                      params: {'value': '{{value}}'},
                    ),
                  ),
                ),
                
                UISizedBox(width: 8),
                
                UIButton(
                  text: 'Add',
                  buttonType: UIButtonType.elevated,
                  onTap: UIActionTrigger(action: 'addTodo'),
                ),
              ],
            ),
          ),
          
          UIDivider(height: 1),
          
          // Todo list
          UIExpanded(
            child: UIListView(
              shrinkWrap: false,
              itemCount: '{{state.todos.length}}',
              itemBuilder: UIListTile(
                leading: UICheckbox(
                  value: '{{state.todos[index].completed}}',
                  onChanged: UIActionTrigger(
                    action: 'toggleTodo',
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
                    action: 'deleteTodo',
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
  final app = TodoMiniApp();
  final json = app.compileToJson();
  print(json);
}
