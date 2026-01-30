import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:ui_eval_runtime/ui_eval_runtime.dart';
import 'dart:convert';

void main() {
  runApp(const HostApp());
}

class HostApp extends StatelessWidget {
  const HostApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'UI Eval Host',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      home: const AppLauncherPage(),
    );
  }
}

/// Main page showing available mini apps
class AppLauncherPage extends StatelessWidget {
  const AppLauncherPage({super.key});

  final List<_MiniAppInfo> apps = const [
    _MiniAppInfo(
      name: 'Todo App',
      description: 'Simple todo list with filters',
      assetPath: 'assets/apps/todo_app.json',
      icon: Icons.check_circle,
      color: Colors.teal,
    ),
    _MiniAppInfo(
      name: 'Counter App',
      description: 'Basic counter example',
      assetPath: 'assets/apps/counter_app.json',
      icon: Icons.add_circle,
      color: Colors.blue,
    ),
    _MiniAppInfo(
      name: 'Profile Card',
      description: 'User profile display',
      assetPath: 'assets/apps/profile_app.json',
      icon: Icons.person,
      color: Colors.purple,
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
  final _MiniAppInfo app;
  
  const MiniAppContainer({super.key, required this.app});

  @override
  State<MiniAppContainer> createState() => _MiniAppContainerState();
}

class _MiniAppContainerState extends State<MiniAppContainer> {
  Map<String, dynamic>? _uiJson;
  bool _isLoading = true;
  String? _error;
  
  // App state
  late Map<String, dynamic> _state;
  late Map<String, Function> _actions;
  
  @override
  void initState() {
    super.initState();
    _loadApp();
  }
  
  Future<void> _loadApp() async {
    try {
      // Load UI JSON from assets
      final jsonString = await rootBundle.loadString(widget.app.assetPath);
      _uiJson = jsonDecode(jsonString) as Map<String, dynamic>;
      
      // Initialize state from UI definition
      final states = _uiJson!['states'] as List<dynamic>;
      _state = {
        for (final s in states) 
          s['key'] as String: s['defaultValue'],
      };
      
      // Setup action handlers
      _setupActions();
      
      setState(() => _isLoading = false);
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }
  
  void _setupActions() {
    _actions = {
      // Todo App Actions
      'addTodo': (_) => _handleAddTodo(),
      'toggleTodo': (params) => _handleToggleTodo(params['index'] as int),
      'deleteTodo': (params) => _handleDeleteTodo(params['index'] as int),
      'setFilter': (params) => _handleSetFilter(params['index'] as int),
      'updateTitle': (params) => _handleUpdateTitle(params['value'] as String),
      'clearCompleted': (_) => _handleClearCompleted(),
      
      // Counter App Actions
      'increment': (_) => _handleIncrement(),
      'decrement': (_) => _handleDecrement(),
      'reset': (_) => _handleReset(),
    };
  }
  
  // ==================== Todo App Handlers ====================
  
  void _handleAddTodo() {
    final title = _state['newTodoTitle'] as String? ?? '';
    if (title.trim().isEmpty) return;
    
    setState(() {
      final todos = List<Map<String, dynamic>>.from(_state['todos'] as List? ?? []);
      todos.add({
        'title': title,
        'completed': false,
        'createdAt': DateTime.now().toIso8601String(),
      });
      _state['todos'] = todos;
      _state['newTodoTitle'] = '';
      _updateComputedState();
    });
  }
  
  void _handleToggleTodo(int index) {
    setState(() {
      final todos = List<Map<String, dynamic>>.from(_state['todos'] as List);
      todos[index]['completed'] = !(todos[index]['completed'] as bool);
      _state['todos'] = todos;
      _updateComputedState();
    });
  }
  
  void _handleDeleteTodo(int index) {
    setState(() {
      final todos = List<Map<String, dynamic>>.from(_state['todos'] as List);
      todos.removeAt(index);
      _state['todos'] = todos;
      _updateComputedState();
    });
  }
  
  void _handleSetFilter(int index) {
    setState(() {
      _state['filterIndex'] = index;
    });
  }
  
  void _handleUpdateTitle(String value) {
    setState(() {
      _state['newTodoTitle'] = value;
    });
  }
  
  void _handleClearCompleted() {
    setState(() {
      final todos = List<Map<String, dynamic>>.from(_state['todos'] as List);
      todos.removeWhere((t) => t['completed'] as bool);
      _state['todos'] = todos;
      _updateComputedState();
    });
  }
  
  void _updateComputedState() {
    final todos = List<Map<String, dynamic>>.from(_state['todos'] as List? ?? []);
    final completed = todos.where((t) => t['completed'] as bool).length;
    _state['completedCount'] = completed;
    _state['pendingCount'] = todos.length - completed;
    _state['totalCount'] = todos.length;
  }
  
  // ==================== Counter App Handlers ====================
  
  void _handleIncrement() {
    setState(() {
      _state['count'] = ((_state['count'] as int?) ?? 0) + 1;
    });
  }
  
  void _handleDecrement() {
    setState(() {
      _state['count'] = ((_state['count'] as int?) ?? 0) - 1;
    });
  }
  
  void _handleReset() {
    setState(() {
      _state['count'] = 0;
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

class _MiniAppInfo {
  final String name;
  final String description;
  final String assetPath;
  final IconData icon;
  final Color color;
  
  const _MiniAppInfo({
    required this.name,
    required this.description,
    required this.assetPath,
    required this.icon,
    required this.color,
  });
}
