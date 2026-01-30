// ignore_for_file: avoid_print

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:ui_eval/runtime.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize TypeScript logic engine
  await GlobalLogicContainer().initialize();
  
  runApp(const ExampleApp());
}

/// Example app demonstrating ui_eval
class ExampleApp extends StatelessWidget {
  const ExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ui_eval Example',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      // Wrap with LogicEngineWidget to enable hidden WebView
      builder: (context, child) => LogicEngineWidget(child: child!),
      home: const AppLauncherPage(),
    );
  }
}

/// Mini app info
class MiniAppInfo {
  final String name;
  final String description;
  final String assetPath;
  final IconData icon;
  final Color color;

  const MiniAppInfo({
    required this.name,
    required this.description,
    required this.assetPath,
    required this.icon,
    required this.color,
  });
}

/// Launcher page showing available mini apps
class AppLauncherPage extends StatelessWidget {
  const AppLauncherPage({super.key});

  final List<MiniAppInfo> apps = const [
    MiniAppInfo(
      name: 'Counter App',
      description: 'Simple counter with increment/decrement',
      assetPath: 'assets/apps/counter_app.json',
      icon: Icons.add_circle,
      color: Colors.blue,
    ),
    MiniAppInfo(
      name: 'Todo App',
      description: 'Todo list with add/delete (TypeScript logic)',
      assetPath: 'assets/apps/todo_app.json',
      icon: Icons.check_circle,
      color: Colors.teal,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mini Apps'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: ListView.builder(
        itemCount: apps.length,
        itemBuilder: (context, index) {
          final app = apps[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: app.color,
                child: Icon(app.icon, color: Colors.white),
              ),
              title: Text(app.name),
              subtitle: Text(app.description),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => MiniAppContainer(app: app),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Container that runs a mini app
class MiniAppContainer extends StatefulWidget {
  final MiniAppInfo app;

  const MiniAppContainer({super.key, required this.app});

  @override
  State<MiniAppContainer> createState() => _MiniAppContainerState();
}

class _MiniAppContainerState extends State<MiniAppContainer> {
  Map<String, dynamic>? _uiJson;
  bool _isLoading = true;
  String? _error;
  late Map<String, dynamic> _state;
  late Map<String, Function(Map<String, dynamic>?)> _actions;
  
  // Toggle between Dart and TypeScript logic
  bool _useTypeScript = true;

  @override
  void initState() {
    super.initState();
    _loadApp();
  }

  Future<void> _loadApp() async {
    try {
      final jsonString = await rootBundle.loadString(widget.app.assetPath);
      _uiJson = jsonDecode(jsonString) as Map<String, dynamic>;

      // Initialize state from UI definition
      final states = _uiJson!['states'] as List<dynamic>;
      _state = {
        for (final s in states) s['key'] as String: s['defaultValue'],
      };

      // Setup action handlers
      _setupActions();

      setState(() => _isLoading = false);
    } catch (e, stack) {
      print('Error loading app: $e');
      print(stack);
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _setupActions() {
    _actions = {
      // Counter App Actions (Dart - working)
      'increment': (_) => setState(() {
            _state['count'] = ((_state['count'] as int?) ?? 0) + 1;
          }),
      'decrement': (_) => setState(() {
            _state['count'] = ((_state['count'] as int?) ?? 0) - 1;
          }),
      'reset': (_) => setState(() => _state['count'] = 0),

      // Todo App Actions
      'addTodo': (_) => _handleAction('addTodo'),
      'toggleTodo': (params) => _handleAction('toggleTodo', params),
      'deleteTodo': (params) => _handleAction('deleteTodo', params),
      'updateTitle': (params) => _useTypeScript
          ? _handleAction('updateTitle', params)
          : setState(() => _state['newTodoTitle'] = params?['value']),
      'setFilter': (params) => _handleAction('setFilter', params),
      'clearCompleted': (_) => _handleAction('clearCompleted'),
      'fetchTodosFromApi': (_) => _handleAction('fetchTodosFromApi'),
    };
  }
  
  Future<void> _handleAction(String name, [Map<String, dynamic>? params]) async {
    if (_useTypeScript) {
      // Use TypeScript logic via WebView
      await LogicCoordinator().executeAction(name, params);
    } else {
      // Use Dart logic (fallback)
      _executeDartAction(name, params);
    }
    // State updates come from TS via state.set which triggers rebuild
    setState(() {});
  }
  
  void _executeDartAction(String name, Map<String, dynamic>? params) {
    // Fallback Dart implementations
    switch (name) {
      case 'addTodo':
        _handleAddTodo();
        break;
      case 'toggleTodo':
        _handleToggleTodo(params?['index'] as int);
        break;
      case 'deleteTodo':
        _handleDeleteTodo(params?['index'] as int);
        break;
      case 'updateTitle':
        setState(() => _state['newTodoTitle'] = params?['value']);
        break;
      case 'setFilter':
        setState(() => _state['filter'] = params?['filter'] ?? 'all');
        break;
      case 'clearCompleted':
        _handleClearCompleted();
        break;
    }
  }

  void _handleAddTodo() {
    final title = _state['newTodoTitle'] as String? ?? '';
    if (title.trim().isEmpty) return;

    setState(() {
      final todos = List<Map<String, dynamic>>.from(
          _state['todos'] as List? ?? []);
      todos.add({
        'title': title,
        'completed': false,
      });
      _state['todos'] = todos;
      _state['newTodoTitle'] = '';
    });
  }

  void _handleToggleTodo(int index) {
    setState(() {
      final todos = List<Map<String, dynamic>>.from(_state['todos'] as List);
      todos[index]['completed'] = !(todos[index]['completed'] as bool);
      _state['todos'] = todos;
    });
  }

  void _handleDeleteTodo(int index) {
    setState(() {
      final todos = List<Map<String, dynamic>>.from(_state['todos'] as List);
      todos.removeAt(index);
      _state['todos'] = todos;
    });
  }
  
  void _handleClearCompleted() {
    setState(() {
      final todos = List<Map<String, dynamic>>.from(_state['todos'] as List);
      todos.removeWhere((t) => t['completed'] as bool);
      _state['todos'] = todos;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.app.name)),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.app.name)),
        body: Center(child: Text('Error: $_error')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.app.name),
        actions: [
          // Toggle for TypeScript/Dart logic
          if (widget.app.name.contains('Todo'))
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _useTypeScript ? 'TS' : 'Dart',
                  style: const TextStyle(fontSize: 12),
                ),
                Switch(
                  value: _useTypeScript,
                  onChanged: (v) => setState(() => _useTypeScript = v),
                ),
              ],
            ),
        ],
      ),
      body: UIRuntimeWidget(
        uiJson: _uiJson!,
        initialState: _state,
        actions: _actions,
        errorBuilder: (error) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 48),
              const SizedBox(height: 16),
              Text('Runtime Error: $error'),
            ],
          ),
        ),
      ),
    );
  }
}
