// ignore_for_file: avoid_print

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:ui_eval/ui_eval.dart';

/// Todo Mini App using type-safe ui_eval DSL
/// 
/// This demonstrates how developers can build UI using Dart DSL classes
/// which can then be compiled to JSON DSL for runtime loading.
/// 
/// Example usage:
/// ```dart
/// // In development - use DSL directly
/// const TodoMiniApp()
/// 
/// // In production - load from compiled bundle
/// UIBundleLoader(bundlePath: 'assets/logic/todo_app.bundle')
/// ```
class TodoMiniApp extends StatelessWidget {
  const TodoMiniApp({super.key});

  /// The UI program definition using type-safe DSL
  /// This can be compiled to JSON using [toJson()]
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
                  decoration: '{{state.todos[index].completed ? "lineThrough" : "none"}}',
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
          
          // Filter chips
          UIContainer(
            padding: UIEdgeInsets.all(16),
            child: UIWrap(
              spacing: 8,
              children: [
                UIChip(
                  label: 'All',
                  backgroundColor: '{{state.filter == "all" ? "teal" : "grey"}}',
                ),
                UIChip(
                  label: 'Active',
                  backgroundColor: '{{state.filter == "active" ? "teal" : "grey"}}',
                ),
                UIChip(
                  label: 'Completed',
                  backgroundColor: '{{state.filter == "completed" ? "teal" : "grey"}}',
                ),
              ],
            ),
          ),
        ],
      ),
    ).toJson(),
  );

  @override
  Widget build(BuildContext context) {
    // In development mode, we could render directly from DSL
    // For now, we use the bundle loader which loads the compiled version
    return const TodoMiniAppLoader();
  }
}

/// Loader widget that loads the compiled bundle
/// This would be in the host app in production
class TodoMiniAppLoader extends StatelessWidget {
  const TodoMiniAppLoader({super.key});

  @override
  Widget build(BuildContext context) {
    // Use the UIBundleLoader to load the compiled bundle
    // which contains both UI (JSON) and Logic (TypeScript/JS)
    return const SizedBox.shrink(); // Placeholder - actual loader in host app
  }
}

/// Extension to compile the DSL program to JSON string
extension TodoMiniAppCompiler on TodoMiniApp {
  /// Compile the DSL program to JSON format
  String compileToJson() {
    final json = program.toJson();
    // Pretty print JSON
    return const JsonEncoder.withIndent('  ').convert(json);
  }
}
