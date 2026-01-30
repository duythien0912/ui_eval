// ignore_for_file: avoid_print

import 'dart:convert';
import 'dart:io';
import 'package:ui_eval/dsl.dart';

/// Todo App Definition
///
/// Run this to generate JSON:
/// ```bash
/// cd example
/// dart lib/mini_apps/todo_app.dart
/// ```

UIProgram buildTodoApp() {
  // Define states
  final todos = states.listOf<Map<String, dynamic>>('todos', defaultValue: []);
  final newTodoTitle = states.string('newTodoTitle', defaultValue: '');

  // Define actions
  final addTodo = actions.action('addTodo');
  final toggleTodo = actions.actionWithParams(
    'toggleTodo',
    params: [UIActionParam(name: 'index', type: 'int', required: true)],
  );
  final deleteTodo = actions.actionWithParams(
    'deleteTodo',
    params: [UIActionParam(name: 'index', type: 'int', required: true)],
  );
  final updateTitle = actions.actionWithParams(
    'updateTitle',
    params: [UIActionParam(name: 'value', type: 'String', required: true)],
  );

  // Build UI
  return UIProgram(
    name: 'TodoApp',
    version: '1.0.0',
    metadata: {
      'title': 'Todo App',
      'description': 'Simple todo list',
    },
    states: [todos, newTodoTitle],
    actions: [addTodo, toggleTodo, deleteTodo, updateTitle],
    root: UIScaffold(
      appBar: UIAppBar(
        title: 'My Todos',
        backgroundColor: UIColor.teal,
        foregroundColor: UIColor.white,
      ),
      body: UIColumn(
        children: [
          // Input section
          UIPadding(
            padding: const UIEdgeInsets.all(16),
            child: UIRow(
              children: [
                UIExpanded(
                  child: UITextField(
                    hint: 'What needs to be done?',
                    onChanged: updateTitle(),
                  ),
                ),
                const UISizedBox(width: 8),
                UIButton(
                  onPressed: addTodo(),
                  backgroundColor: UIColor.teal,
                  child: const UIText('ADD', color: UIColor.white),
                ),
              ],
            ),
          ),
          const UIDivider(),
          // Empty state
          UIExpanded(
            child: UICenter(
              child: UIColumn(
                mainAxisSize: UIMainAxisSize.min,
                children: [
                  const UIIcon(
                    icon: UIIconData.checkCircle,
                    size: 64,
                    color: UIColor.grey,
                  ),
                  const UISizedBox(height: 16),
                  UIText(
                    'All caught up!',
                    fontSize: 18,
                    color: UIColor.grey,
                  ),
                  UIText(
                    'Add a task to get started',
                    color: UIColor.grey,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: UIFloatingActionButton.icon(
        onPressed: addTodo(),
        icon: UIIconData.add,
        backgroundColor: UIColor.teal,
        foregroundColor: UIColor.white,
        tooltip: 'Add Todo',
      ),
    ),
  );
}

// Generate JSON when running this file directly
void main() {
  final app = buildTodoApp();
  final json = const JsonEncoder.withIndent('  ').convert(app.toJson());

  // Save to file
  final outputFile = File('assets/apps/todo_app.json');
  outputFile.createSync(recursive: true);
  outputFile.writeAsStringSync(json);

  print('✅ Todo app JSON generated:');
  print(outputFile.absolute.path);
}
