// ignore_for_file: avoid_print

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:ui_eval/runtime.dart';

class TodoMiniApp extends StatefulWidget {
  const TodoMiniApp({super.key});

  @override
  State<TodoMiniApp> createState() => _TodoMiniAppState();
}

class _TodoMiniAppState extends State<TodoMiniApp> {
  Map<String, dynamic>? _uiJson;
  bool _isLoading = true;
  String? _error;
  late Map<String, dynamic> _state;
  late Map<String, Function(Map<String, dynamic>?)> _actions;
  static const String _moduleId = 'todo';

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      await _loadUiDefinition();
      _initializeState();
      _setupActions();
      await _loadTypeScriptLogic();
      setState(() => _isLoading = false);
    } catch (e, stack) {
      print('Error initializing TodoMiniApp: $e');
      print(stack);
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _loadUiDefinition() async {
    try {
      final jsonString = await rootBundle.loadString('assets/apps/todo_app.json');
      _uiJson = jsonDecode(jsonString) as Map<String, dynamic>;
    } catch (_) {
      _uiJson = _getInlineUiDefinition();
    }
  }

  void _initializeState() {
    if (_uiJson?['states'] != null) {
      final states = _uiJson!['states'] as List<dynamic>;
      _state = { for (final s in states) s['key'] as String: s['defaultValue'] };
    } else {
      _state = { 'todos': [], 'newTodoTitle': '', 'filter': 'all' };
    }
    for (final entry in _state.entries) {
      StateManager().set('${_moduleId}:${entry.key}', entry.value);
    }
  }

  void _setupActions() {
    _actions = {
      'addTodo': (_) => _executeTsAction('addTodo'),
      'toggleTodo': (params) => _executeTsAction('toggleTodo', params),
      'deleteTodo': (params) => _executeTsAction('deleteTodo', params),
      'updateTitle': (params) => _executeTsAction('updateTitle', params),
      'setFilter': (params) => _executeTsAction('setFilter', params),
      'clearCompleted': (_) => _executeTsAction('clearCompleted'),
      'fetchTodosFromApi': (_) => _executeTsAction('fetchTodosFromApi'),
    };
  }

  Future<void> _loadTypeScriptLogic() async {
    final container = GlobalLogicContainer();
    if (!container.isInitialized) await container.initialize();
    await container.loadModule(_moduleId, 'assets/logic/todo.js');
    print('[$_moduleId] TypeScript logic loaded');
  }

  Future<void> _executeTsAction(String name, [Map<String, dynamic>? params]) async {
    try {
      await LogicCoordinator().executeAction(_moduleId, name, params);
      await _syncStateFromTs();
    } catch (e) {
      print('[$_moduleId] Error executing $name: $e');
    }
  }

  Future<void> _syncStateFromTs() async {
    final scopedKeys = StateManager().keys.where((k) => k.startsWith('$_moduleId:'));
    final moduleState = <String, dynamic>{};
    for (final key in scopedKeys) {
      final shortKey = key.substring(_moduleId.length + 1);
      moduleState[shortKey] = StateManager().get(key);
    }
    setState(() => _state = moduleState);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (_error != null) {
      return Scaffold(body: Center(child: Text('Error: $_error')));
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('Todo App'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _executeTsAction('fetchTodosFromApi'),
          ),
        ],
      ),
      body: UIRuntimeWidget(
        uiJson: _uiJson!,
        initialState: _state,
        actions: _actions,
      ),
    );
  }

  Map<String, dynamic> _getInlineUiDefinition() {
    return {
      'type': 'scaffold',
      'body': {
        'type': 'column',
        'children': [
          {
            'type': 'container',
            'padding': {'left': 16, 'right': 16, 'top': 16},
            'child': {
              'type': 'row',
              'children': [
                {
                  'type': 'expanded',
                  'child': {
                    'type': 'textField',
                    'value': '{{state.newTodoTitle}}',
                    'hint': 'Add a new todo...',
                    'onChanged': {'action': 'updateTitle', 'params': {'value': '{{value}}'}},
                  },
                },
                {'type': 'sizedBox', 'width': 8},
                {'type': 'button', 'text': 'Add', 'type_': 'primary', 'onTap': {'action': 'addTodo'}},
              ],
            },
          },
          {
            'type': 'listView',
            'shrinkWrap': true,
            'itemCount': '{{state.todos.length}}',
            'itemBuilder': {
              'type': 'listTile',
              'leading': {
                'type': 'checkbox',
                'value': '{{state.todos[{{index}}].completed}}',
                'onChanged': {'action': 'toggleTodo', 'params': {'index': '{{index}}'}},
              },
              'title': {'type': 'text', 'text': '{{state.todos[{{index}}].title}}'},
              'trailing': {
                'type': 'iconButton',
                'icon': 'delete',
                'onTap': {'action': 'deleteTodo', 'params': {'index': '{{index}}'}},
              },
            },
          },
        ],
      },
    };
  }
}
