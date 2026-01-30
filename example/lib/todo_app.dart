import 'package:flutter/material.dart';
import 'package:ui_eval/ui_eval.dart';

/// Todo App using JSON-based dynamic UI
class TodoApp extends StatefulWidget {
  const TodoApp({super.key});

  @override
  State<TodoApp> createState() => _TodoAppState();
}

class _TodoAppState extends State<TodoApp> {
  final List<Map<String, dynamic>> _todos = [];
  String _newTodoTitle = '';
  
  late final Map<String, dynamic> _uiJson;
  late final Map<String, Function> _actions;
  
  @override
  void initState() {
    super.initState();
    _initializeUI();
  }
  
  void _initializeUI() {
    // Define action handlers
    _actions = {
      'addTodo': (_) => _addTodo(),
      'toggleTodo': (params) => _toggleTodo(params['index'] as int),
      'deleteTodo': (params) => _deleteTodo(params['index'] as int),
      'updateTitle': (params) => _updateTitle(params['value'] as String),
    };
    
    // Build UI JSON dynamically based on current state
    _updateUIJson();
  }
  
  void _updateUIJson() {
    _uiJson = _buildTodoUI();
  }
  
  Map<String, dynamic> _buildTodoUI() {
    return {
      'version': '1.0.0',
      'name': 'TodoPage',
      'states': [
        {'key': 'todos', 'type': 'List', 'defaultValue': _todos},
        {'key': 'newTitle', 'type': 'String', 'defaultValue': _newTodoTitle},
      ],
      'root': {
        'type': 'Scaffold',
        'appBar': {
          'type': 'AppBar',
          'title': 'Todo App',
          'backgroundColor': Colors.deepPurple.value,
          'foregroundColor': Colors.white.value,
        },
        'body': {
          'type': 'Column',
          'children': [
            // Input section
            {
              'type': 'Padding',
              'padding': {'left': 16, 'top': 16, 'right': 16, 'bottom': 16},
              'child': {
                'type': 'Row',
                'children': [
                  {
                    'type': 'Expanded',
                    'child': {
                      'type': 'TextField',
                      'hint': 'What needs to be done?',
                      'onChanged': '@updateTitle',
                    },
                  },
                  {'type': 'SizedBox', 'width': 8},
                  {
                    'type': 'ElevatedButton',
                    'onPressed': '@addTodo',
                    'child': {'type': 'Text', 'data': 'ADD'},
                  },
                ],
              },
            },
            {'type': 'Divider'},
            // Todo list
            {
              'type': 'Expanded',
              'child': _todos.isEmpty
                  ? {
                      'type': 'Center',
                      'child': {
                        'type': 'Text',
                        'data': 'No todos yet. Add one above!',
                        'color': Colors.grey.value,
                      },
                    }
                  : {
                      'type': 'ListView',
                      'children': _todos.asMap().entries.map((entry) {
                        final index = entry.key;
                        final todo = entry.value;
                        return {
                          'type': 'Card',
                          'margin': {'left': 16, 'top': 4, 'right': 16, 'bottom': 4},
                          'child': {
                            'type': 'ListTile',
                            'leading': {
                              'type': 'Checkbox',
                              'value': '{{todos.$index.completed}}',
                              'onChanged': '@toggleTodo',
                            },
                            'title': {
                              'type': 'Text',
                              'data': todo['title'] as String,
                              'color': todo['completed'] ? Colors.grey.value : Colors.black.value,
                            },
                            'trailing': {
                              'type': 'IconButton',
                              'icon': Icons.delete.codePoint,
                              'onPressed': '@deleteTodo',
                              'color': Colors.red.value,
                            },
                          },
                        };
                      }).toList(),
                    },
            },
          ],
        },
        'floatingActionButton': {
          'type': 'FloatingActionButton',
          'onPressed': '@addTodo',
          'tooltip': 'Add Todo',
          'child': {'type': 'Text', 'data': '+'},
        },
      },
    };
  }
  
  void _addTodo() {
    if (_newTodoTitle.trim().isEmpty) return;
    
    setState(() {
      _todos.add({
        'title': _newTodoTitle,
        'completed': false,
        'createdAt': DateTime.now().toIso8601String(),
      });
      _newTodoTitle = '';
      _updateUIJson();
    });
  }
  
  void _toggleTodo(int index) {
    setState(() {
      _todos[index]['completed'] = !(_todos[index]['completed'] as bool);
      _updateUIJson();
    });
  }
  
  void _deleteTodo(int index) {
    setState(() {
      _todos.removeAt(index);
      _updateUIJson();
    });
  }
  
  void _updateTitle(String value) {
    setState(() {
      _newTodoTitle = value;
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return UIJsonWidget(
      json: _uiJson,
      initialState: {
        'todos': _todos,
        'newTitle': _newTodoTitle,
      },
      actions: _actions,
    );
  }
}

/// Todo App with hot update support
class TodoAppWithHotUpdate extends StatefulWidget {
  const TodoAppWithHotUpdate({super.key});

  @override
  State<TodoAppWithHotUpdate> createState() => _TodoAppWithHotUpdateState();
}

class _TodoAppWithHotUpdateState extends State<TodoAppWithHotUpdate> {
  final List<Map<String, dynamic>> _todos = [];
  String _newTodoTitle = '';
  
  late final Map<String, Function> _actions;
  
  // Server URL - change this to your update server
  final String _updateServerUrl = 'http://localhost:8080';
  
  @override
  void initState() {
    super.initState();
    _actions = {
      'addTodo': (_) => _addTodo(),
      'toggleTodo': (params) => _toggleTodo(params['index'] as int),
      'deleteTodo': (params) => _deleteTodo(params['index'] as int),
      'updateTitle': (params) => _updateTitle(params['value'] as String),
      'clearCompleted': (_) => _clearCompleted(),
    };
  }
  
  Map<String, dynamic> _buildTodoUI() {
    final completedCount = _todos.where((t) => t['completed'] as bool).length;
    final pendingCount = _todos.length - completedCount;
    
    return {
      'version': '1.0.0',
      'name': 'TodoPage',
      'states': [
        {'key': 'todos', 'type': 'List', 'defaultValue': _todos},
        {'key': 'newTitle', 'type': 'String', 'defaultValue': _newTodoTitle},
        {'key': 'completedCount', 'type': 'int', 'defaultValue': completedCount},
        {'key': 'pendingCount', 'type': 'int', 'defaultValue': pendingCount},
      ],
      'root': {
        'type': 'Scaffold',
        'appBar': {
          'type': 'AppBar',
          'title': 'Todo App (Hot Update)',
          'backgroundColor': Colors.teal.value,
          'foregroundColor': Colors.white.value,
          'actions': [
            {
              'type': 'TextButton',
              'onPressed': '@clearCompleted',
              'child': {'type': 'Text', 'data': 'Clear Done'},
            },
          ],
        },
        'body': {
          'type': 'Column',
          'children': [
            // Stats section
            {
              'type': 'Container',
              'color': Colors.teal[50]?.value,
              'padding': {'left': 16, 'top': 8, 'right': 16, 'bottom': 8},
              'child': {
                'type': 'Row',
                'mainAxisAlignment': 2, // spaceEvenly
                'children': [
                  {
                    'type': 'Column',
                    'children': [
                      {'type': 'Text', 'data': '$pendingCount', 'fontSize': 24, 'fontWeight': 1, 'color': Colors.teal.value},
                      {'type': 'Text', 'data': 'Pending', 'color': Colors.grey[600]?.value},
                    ],
                  },
                  {
                    'type': 'Column',
                    'children': [
                      {'type': 'Text', 'data': '$completedCount', 'fontSize': 24, 'fontWeight': 1, 'color': Colors.green.value},
                      {'type': 'Text', 'data': 'Done', 'color': Colors.grey[600]?.value},
                    ],
                  },
                ],
              },
            },
            {'type': 'Divider'},
            // Input section
            {
              'type': 'Padding',
              'padding': {'left': 16, 'top': 16, 'right': 16, 'bottom': 16},
              'child': {
                'type': 'Row',
                'children': [
                  {
                    'type': 'Expanded',
                    'child': {
                      'type': 'TextField',
                      'hint': 'Add a new task...',
                      'onChanged': '@updateTitle',
                    },
                  },
                  {'type': 'SizedBox', 'width': 8},
                  {
                    'type': 'ElevatedButton',
                    'onPressed': '@addTodo',
                    'backgroundColor': Colors.teal.value,
                    'child': {'type': 'Text', 'data': 'ADD', 'color': Colors.white.value},
                  },
                ],
              },
            },
            {'type': 'Divider'},
            // Todo list
            {
              'type': 'Expanded',
              'child': _todos.isEmpty
                  ? {
                      'type': 'Center',
                      'child': {
                        'type': 'Column',
                        'mainAxisSize': 0, // min
                        'children': [
                          {'type': 'Icon', 'icon': Icons.check_circle_outline.codePoint, 'size': 64, 'color': Colors.grey[400]?.value},
                          {'type': 'SizedBox', 'height': 16},
                          {'type': 'Text', 'data': 'All caught up!', 'fontSize': 18, 'color': Colors.grey[600]?.value},
                          {'type': 'Text', 'data': 'Add a task to get started', 'color': Colors.grey[400]?.value},
                        ],
                      },
                    }
                  : {
                      'type': 'ListView',
                      'children': _todos.asMap().entries.map((entry) {
                        final index = entry.key;
                        final todo = entry.value;
                        final isCompleted = todo['completed'] as bool;
                        return {
                          'type': 'Card',
                          'margin': {'left': 16, 'top': 4, 'right': 16, 'bottom': 4},
                          'elevation': isCompleted ? 0.0 : 2.0,
                          'color': isCompleted ? Colors.grey[100]?.value : Colors.white.value,
                          'child': {
                            'type': 'ListTile',
                            'leading': {
                              'type': 'Checkbox',
                              'value': '{{todos.$index.completed}}',
                              'activeColor': Colors.teal.value,
                              'onChanged': '@toggleTodo',
                            },
                            'title': {
                              'type': 'Text',
                              'data': todo['title'] as String,
                              'color': isCompleted ? Colors.grey.value : Colors.black87.value,
                            },
                            'subtitle': isCompleted
                                ? {'type': 'Text', 'data': 'Completed', 'fontSize': 12, 'color': Colors.green.value}
                                : null,
                            'trailing': {
                              'type': 'IconButton',
                              'icon': Icons.delete_outline.codePoint,
                              'onPressed': '@deleteTodo',
                              'color': Colors.red[300]?.value,
                            },
                          },
                        };
                      }).toList(),
                    },
            },
          ],
        },
        'floatingActionButton': {
          'type': 'FloatingActionButton',
          'onPressed': '@addTodo',
          'backgroundColor': Colors.teal.value,
          'tooltip': 'Add Todo',
          'child': {'type': 'Icon', 'icon': Icons.add.codePoint, 'color': Colors.white.value},
        },
      },
    };
  }
  
  void _addTodo() {
    if (_newTodoTitle.trim().isEmpty) return;
    
    setState(() {
      _todos.add({
        'title': _newTodoTitle,
        'completed': false,
        'createdAt': DateTime.now().toIso8601String(),
      });
      _newTodoTitle = '';
    });
  }
  
  void _toggleTodo(int index) {
    setState(() {
      _todos[index]['completed'] = !(_todos[index]['completed'] as bool);
    });
  }
  
  void _deleteTodo(int index) {
    setState(() {
      _todos.removeAt(index);
    });
  }
  
  void _updateTitle(String value) {
    setState(() {
      _newTodoTitle = value;
    });
  }
  
  void _clearCompleted() {
    setState(() {
      _todos.removeWhere((t) => t['completed'] as bool);
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return UIEvalWidget(
      json: _buildTodoUI(),
      initialState: {
        'todos': _todos,
        'newTitle': _newTodoTitle,
      },
      actions: _actions,
      updateUrl: _updateServerUrl,
      version: '1.0.0',
      loadingWidget: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Loading dynamic UI...'),
          ],
        ),
      ),
      errorBuilder: (error) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 48),
            const SizedBox(height: 16),
            Text('Error: $error'),
          ],
        ),
      ),
    );
  }
}
