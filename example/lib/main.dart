// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:ui_eval/runtime.dart';
import 'package:todo_app/todo_ui.dart';
import 'package:counter_app/counter_ui.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GlobalLogicContainer().initialize();
  runApp(const ExampleApp());
}

class ExampleApp extends StatelessWidget {
  const ExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ui_eval Multi-App Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      builder: (context, child) => LogicEngineWidget(child: child!),
      home: const AppLauncherPage(),
    );
  }
}

class MiniAppInfo {
  final String id;
  final String name;
  final String description;
  final IconData icon;
  final Color color;
  final Widget Function() builder;

  const MiniAppInfo({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.color,
    required this.builder,
  });
}

class AppLauncherPage extends StatelessWidget {
  const AppLauncherPage({super.key});

  List<MiniAppInfo> get apps => [
    MiniAppInfo(
      id: 'counter',
      name: 'Counter App',
      description: 'Simple counter with TypeScript logic',
      icon: Icons.add_circle,
      color: Colors.blue,
      builder: () => const CounterMiniApp(),
    ),
    MiniAppInfo(
      id: 'todo',
      name: 'Todo App',
      description: 'Todo list with add/delete (TypeScript)',
      icon: Icons.check_circle,
      color: Colors.teal,
      builder: () => const TodoMiniApp(),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ui_eval Mini Apps'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: apps.length,
        itemBuilder: (context, index) {
          final app = apps[index];
          return Card(
            elevation: 2,
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              leading: CircleAvatar(
                backgroundColor: app.color,
                radius: 28,
                child: Icon(app.icon, color: Colors.white, size: 28),
              ),
              title: Text(
                app.name,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(app.description),
              ),
              trailing: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: app.color.withAlpha(30),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  'BUNDLE',
                  style: TextStyle(color: app.color, fontWeight: FontWeight.bold, fontSize: 12),
                ),
              ),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => app.builder()),
              ),
            ),
          );
        },
      ),
    );
  }
}
