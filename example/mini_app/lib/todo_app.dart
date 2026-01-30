/// Mini Todo App - Built with pure ui_eval (no Flutter dependencies)
/// This file can be compiled to JSON and served to any Flutter host app

import 'dart:convert';
import 'package:ui_eval/ui_eval.dart';

/// The Todo App UI Program
class TodoApp {
  // Define states
  late final UIState<List<Map<String, dynamic>>> todos;
  late final UIState<String> newTodoTitle;
  
  TodoApp() {
    todos = UIState<List<Map<String, dynamic>>>(
      key: 'todos',
      defaultValue: [],
      type: 'List<Map>',
    );
    
    newTodoTitle = UIState<String>(
      key: 'newTodoTitle',
      defaultValue: '',
      type: 'String',
    );
  }
  
  /// Build the complete UI program
  UIProgram build() {
    return UIProgram(
      name: 'TodoApp',
      version: '1.0.0',
      metadata: {
        'title': 'Todo App',
        'description': 'A simple todo list app',
        'author': 'Mini App Developer',
      },
      states: [todos, newTodoTitle],
      actions: [
        const UIAction(name: 'addTodo'),
        const UIAction(name: 'toggleTodo', params: [UIActionParam(name: 'index', type: 'int')]),
        const UIAction(name: 'deleteTodo', params: [UIActionParam(name: 'index', type: 'int')]),
        const UIAction(name: 'updateTitle', params: [UIActionParam(name: 'value', type: 'String')]),
      ],
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
              padding: UIEdgeInsets.all(16),
              child: UIRow(
                children: [
                  UIExpanded(
                    child: UITextField(
                      hint: 'What needs to be done?',
                      onChanged: UIActionRef('updateTitle'),
                    ),
                  ),
                  UISizedBox(width: 8),
                  UIButton(
                    onPressed: UIActionRef('addTodo'),
                    backgroundColor: UIColor.teal,
                    child: UIText('ADD', color: UIColor.white),
                  ),
                ],
              ),
            ),
            UIDivider(),
            
            // Todo list
            UIExpanded(
              child: UICenter(
                child: UIColumn(
                  mainAxisSize: UIMainAxisSize.min,
                  children: [
                    UIIcon(icon: UIIconData.checkCircle, size: 64, color: UIColor.grey),
                    UISizedBox(height: 16),
                    UIText('All caught up!', fontSize: 18, color: UIColor.grey),
                    UIText('Add a task to get started', color: UIColor.grey),
                  ],
                ),
              ),
            ),
          ],
        ),
        floatingActionButton: UIFloatingActionButton.icon(
          onPressed: UIActionRef('addTodo'),
          icon: UIIconData.add,
          backgroundColor: UIColor.teal,
          foregroundColor: UIColor.white,
          tooltip: 'Add Todo',
        ),
      ),
    );
  }
}

/// Build and export the app
void main() {
  final app = TodoApp();
  final program = app.build();
  
  // Print JSON output (would be saved to file by build script)
  print('--- UI JSON ---');
  print(const JsonEncoder.withIndent('  ').convert(program.toJson()));
}
