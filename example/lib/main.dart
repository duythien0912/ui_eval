import 'package:flutter/material.dart';
import 'package:ui_eval/ui_eval.dart';
import 'todo_app.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'UI Eval Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('UI Eval Examples'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: ListView(
        children: [
          ListTile(
            title: const Text('Todo App (JSON-based)'),
            subtitle: const Text('Dynamic UI with state and actions'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const TodoApp()),
            ),
          ),
          const Divider(),
          ListTile(
            title: const Text('Todo App with Hot Update'),
            subtitle: const Text('Server-driven UI updates'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const TodoAppWithHotUpdate()),
            ),
          ),
          const Divider(),
          ListTile(
            title: const Text('DSL Builder Demo'),
            subtitle: const Text('Type-safe UI construction'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const DSLDemoPage()),
            ),
          ),
        ],
      ),
    );
  }
}

class DSLDemoPage extends StatelessWidget {
  const DSLDemoPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Build UI using type-safe DSL
    final todoTitle = UIState(key: 'title', defaultValue: '');
    final todoItems = UIState(key: 'items', defaultValue: <Map<String, dynamic>>[]);
    
    final program = UIProgram(
      name: 'TodoPage',
      states: [todoTitle, todoItems],
      actions: [
        const UIAction(name: 'addTodo'),
        const UIAction(name: 'toggleTodo'),
        const UIAction(name: 'deleteTodo'),
      ],
      root: UIScaffold(
        appBar: UIAppBar(
          title: 'DSL Todo App',
          backgroundColor: Colors.deepPurple.value,
          foregroundColor: Colors.white.value,
        ),
        body: UIColumn(
          children: [
            UIPadding(
              padding: const EdgeInsets.all(16),
              child: UIRow(
                children: [
                  UIExpanded(
                    child: UITextField(
                      hint: 'Enter todo...',
                      onChanged: UIActionRef('updateTitle'),
                    ),
                  ),
                  const UISizedBox(width: 8),
                  UIIconButton(
                    icon: Icons.add,
                    onPressed: UIActionRef('addTodo'),
                    color: Colors.deepPurple,
                  ),
                ],
              ),
            ),
            const UIDivider(),
            UIExpanded(
              child: UIListView(
                children: [
                  // Dynamic items would be rendered here
                  UICard(
                    child: UIListTile(
                      leading: UICheckbox(
                        value: const UIStateRef('items.0.completed'),
                        onChanged: UIActionRef('toggleTodo', arguments: {'index': 0}),
                      ),
                      title: UIText.state(const UIStateRef('items.0.title')),
                      trailing: UIIconButton(
                        icon: Icons.delete,
                        onPressed: UIActionRef('deleteTodo', arguments: {'index': 0}),
                        color: Colors.red,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        floatingActionButton: UIFloatingActionButton.icon(
          onPressed: UIActionRef('addTodo'),
          icon: Icons.add,
          tooltip: 'Add Todo',
        ),
      ),
    );
    
    // Show the generated Dart code
    return Scaffold(
      appBar: AppBar(
        title: const Text('DSL Demo'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Generated Dart Code:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[900],
                borderRadius: BorderRadius.circular(8),
              ),
              child: SelectableText(
                program.toDartCode(),
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 12,
                  color: Colors.green,
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'JSON Representation:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[900],
                borderRadius: BorderRadius.circular(8),
              ),
              child: SelectableText(
                const JsonEncoder.withIndent('  ').convert(program.toJson()),
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 12,
                  color: Colors.orange,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
